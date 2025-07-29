//
// WifiView.swift
// PetalPal
//
// Created by Adishree Das on 7/22/25.
//

import SwiftUI

// WifiManager Class
// This class will handle network requests to the smart pot.
// It assumes the smart pot has a known IP address or hostname and exposes an HTTP API.
class WifiManager: ObservableObject {

    // Published properties to update the UI
    @Published var connectionStatus: String = "Disconnected"
    @Published var errorMessage: String?
    @Published var deviceAddress: String = "http://192.168.1.100"
    @Published var lastReceivedData: String = "N/A"
    @Published var isConnecting: Bool = false

    // Function to simulate connection (e.g., pinging the device or fetching a status)
    func connect() {
        guard !deviceAddress.isEmpty else {
            errorMessage = "Please enter a device address."
            return
        }

        isConnecting = true
        connectionStatus = "Connecting..."
        errorMessage = nil

        // Simulate a network request to check connectivity
        // In a real scenario, you would make an actual HTTP GET request to a known endpoint
        // on your smart pot to verify its presence and connectivity.
        // For example: URLSession.shared.dataTask(with: URL(string: "\(deviceAddress)/status")!)
        
        // Simulating a delay for connection attempt
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            // For demonstration, let's assume successful connection if the address is not empty
            if !self.deviceAddress.isEmpty {
                self.connectionStatus = "Connected to \(self.deviceAddress)"
                self.isConnecting = false
                self.fetchSmartPotData() // Automatically fetch data after connection
            } else {
                self.errorMessage = "Failed to connect to \(self.deviceAddress). Check the address or network."
                self.connectionStatus = "Disconnected"
                self.isConnecting = false
            }
        }
    }

    // Function to disconnect (conceptual for HTTP; mainly stops attempts)
    func disconnect() {
        connectionStatus = "Disconnected"
        lastReceivedData = "N/A"
        errorMessage = nil
        isConnecting = false
    }

    // Function to send data to the smart pot (e.g., water command)
    func sendCommand(command: String, value: String? = nil) {
        guard !deviceAddress.isEmpty else {
            errorMessage = "Not connected to a device."
            return
        }

        // Construct the URL for the command
        var urlString = "\(deviceAddress)/command?action=\(command)"
        if let value = value {
            urlString += "&value=\(value)"
        }

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid command URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Or POST, depending on your smart pot's API

        // Perform the network request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to send command: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    self?.errorMessage = "Failed to send command: Invalid server response."
                    return
                }

                self?.errorMessage = nil
                self?.connectionStatus = "Command '\(command)' sent successfully!"
                self?.fetchSmartPotData() // Refresh data after sending command
            }
        }.resume()
    }

    // Function to fetch data from the smart pot (e.g., sensor readings)
    func fetchSmartPotData() {
        guard !deviceAddress.isEmpty else {
            errorMessage = "Not connected to a device."
            return
        }

        guard let url = URL(string: "\(deviceAddress)/data") else { // Assuming a /data endpoint
            errorMessage = "Invalid data URL."
            return
        }

        connectionStatus = "Fetching data..."

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to fetch data: \(error.localizedDescription)"
                    self?.lastReceivedData = "Error"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    self?.errorMessage = "Failed to fetch data: Invalid server response."
                    self?.lastReceivedData = "Error"
                    return
                }

                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    self?.lastReceivedData = dataString
                    self?.connectionStatus = "Data received."
                    self?.errorMessage = nil
                } else {
                    self?.lastReceivedData = "No data"
                    self?.errorMessage = "No data received or unable to decode."
                }
            }
        }.resume()
    }
}

// WifiView
struct WifiView: View {
    @StateObject private var wifiManager = WifiManager()
    @State private var newDeviceAddress: String = ""

    var body: some View {
        NavigationStack {
            // Top Navigation Bar (similar to original)
            HStack {
                Text("Petal Pal")
                    .font(.custom("Prata-Regular", size: 28))
                    .foregroundColor(Color(red: 67/255, green: 137/255, blue: 124/255))
                    .padding(.leading, 20)
                Spacer()
                NavigationLink {
                    HelpbotView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                        .padding(.trailing, 20)
                }
            }
            .frame(height: 56)
            .background(Color(red: 174/255, green: 213/255, blue: 214/255))
            .padding(.bottom, 15)

            // Main Content Area
            ScrollView {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundColor(Color(red: 216/255, green: 232/255, blue: 202/255))

                    VStack(alignment: .leading, spacing: 15) {
                        Text("Connect a Smart Pot (Wi-Fi)")
                            .font(.custom("Lato-Bold", size: 25))

                        Text("Status: \(wifiManager.connectionStatus)")
                            .font(.custom("Lato-Regular", size: 18))
                            .foregroundColor(.black.opacity(0.7))

                        if let errorMessage = wifiManager.errorMessage {
                            Text(errorMessage)
                                .font(.custom("Lato-Regular", size: 16))
                                .foregroundColor(.red)
                        }

                        // Input for Device Address
                        TextField("Enter Smart Pot IP Address or Hostname", text: $newDeviceAddress)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: newDeviceAddress) { newValue in
                                wifiManager.deviceAddress = newValue // Update manager's address
                            }
                            .onAppear {
                                newDeviceAddress = wifiManager.deviceAddress // Initialize from manager
                            }

                        HStack {
                            Button(action: {
                                wifiManager.connect()
                            }) {
                                Text("Connect")
                                    .font(.custom("Lato-Bold", size: 20))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 82/255, green: 166/255, blue: 69/255))
                                    .cornerRadius(15)
                            }
                            .disabled(wifiManager.isConnecting || wifiManager.connectionStatus.contains("Connected"))

                            Button(action: {
                                wifiManager.disconnect()
                            }) {
                                Text("Disconnect")
                                    .font(.custom("Lato-Bold", size: 20))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.orange)
                                    .cornerRadius(15)
                            }
                            .disabled(!wifiManager.connectionStatus.contains("Connected"))
                        }

                        Button(action: {
                            wifiManager.fetchSmartPotData()
                        }) {
                            Text("Fetch Latest Data")
                                .font(.custom("Lato-Bold", size: 20))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 67/255, green: 137/255, blue: 124/255))
                                .cornerRadius(15)
                        }
                        .disabled(!wifiManager.connectionStatus.contains("Connected"))

                        Text("Last Received Data:")
                            .font(.custom("Lato-Bold", size: 18))
                            .padding(.top, 10)
                        Text(wifiManager.lastReceivedData)
                            .font(.custom("Lato-Regular", size: 16))
                            .foregroundColor(.black.opacity(0.8))
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)

                        // Example controls for smart pot (assuming simple commands)
                        Text("Smart Pot Controls:")
                            .font(.custom("Lato-Bold", size: 18))
                            .padding(.top, 10)

                        HStack {
                            Button(action: {
                                wifiManager.sendCommand(command: "water")
                            }) {
                                Text("Water Plant")
                                    .font(.custom("Lato-Regular", size: 16))
                                    .foregroundColor(.white)
                                    .padding(.init(top: 8, leading: 15, bottom: 8, trailing: 15))
                                    .background(Color(red: 40/255, green: 120/255, blue: 200/255))
                                    .cornerRadius(10)
                            }
                            .disabled(!wifiManager.connectionStatus.contains("Connected"))

                            Button(action: {
                                wifiManager.sendCommand(command: "light_on")
                            }) {
                                Text("Lights On")
                                    .font(.custom("Lato-Regular", size: 16))
                                    .foregroundColor(.white)
                                    .padding(.init(top: 8, leading: 15, bottom: 8, trailing: 15))
                                    .background(Color(red: 255/255, green: 165/255, blue: 0/255))
                                    .cornerRadius(10)
                            }
                            .disabled(!wifiManager.connectionStatus.contains("Connected"))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                }
                .padding(.horizontal)
            }
            Spacer()

            // Bottom Navigation Bar (update the link for "Connect a Device")
            HStack {
                NavigationLink{
                    ContentView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Image(systemName: "house.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                NavigationLink{
                    PlantsView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                NavigationLink{
                    WifiView() // Changed to WifiView
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Image(systemName: "plus.app.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color(red: 82/255, green: 166/255, blue: 69/255))
                        .frame(maxWidth: .infinity)
                }
                NavigationLink{
                    JournalView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Image(systemName: "book.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                NavigationLink {
                    SettingsView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: 56)
            .background(Color(red: 174/255, green: 213/255, blue: 214/255))
        }
        .foregroundStyle(Color(red: 13/255, green: 47/255, blue: 68/255))
        .font(.custom("Lato-Regular", size: 20))
        .background(Color(red: 249/255, green: 248/255, blue: 241/255))
    }
}

#Preview {
    WifiView()
}
