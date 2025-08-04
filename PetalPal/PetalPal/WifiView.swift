//
//  WifiView.swift
//  PetalPal
//
//  Created by Adishree Das on 7/22/25.
//

import SwiftUI
import SwiftData

class WifiManager: ObservableObject {
    @Published var connectionStatus: String = "Disconnected"
    @Published var errorMessage: String?
    @Published var deviceAddress: String = "http://192.168.1.100"
    @Published var lastReceivedData: String = "N/A"
    @Published var isConnecting: Bool = false
    
    func connect() {
        guard !deviceAddress.isEmpty else {
            errorMessage = "Please enter a device address."
            return
        }
        
        let fullAddress = deviceAddress.hasPrefix("http://") ? deviceAddress : "http://" + deviceAddress
        
        isConnecting = true
        connectionStatus = "Connecting..."
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            if !fullAddress.isEmpty {
                self.deviceAddress = fullAddress
                self.connectionStatus = "Connected: You can now connect another pot"
                self.isConnecting = false
                self.lastReceivedData = "Temperature: 22°C\nHumidity: 65%\nSoil Moisture: 80%"
                // Reset device address for next connection
                self.deviceAddress = "http://192.168.1.100"
            } else {
                self.errorMessage = "Failed to connect to \(fullAddress). Check the address or network."
                self.connectionStatus = "Disconnected"
                self.isConnecting = false
            }
        }
    }
    
    func fetchSmartPotData() {
        guard !deviceAddress.isEmpty else {
            errorMessage = "Not connected to a device."
            return
        }
        
        connectionStatus = "Fetching data..."
        
        // Simulate data fetch
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.lastReceivedData = "Temperature: 22°C\nHumidity: 65%\nSoil Moisture: 80%"
            self?.connectionStatus = "Connected: You can now connect another pot"
        }
    }
}

struct WifiView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var wifiManager = WifiManager()
    @State private var newDeviceAddress: String = ""
    @State private var plantName = ""
    @State private var selectedType = PlantType.flower
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Navigation Bar
                appHeader
                
                // Main Content Area
                ScrollView {
                    connectSmartPotSection
                }
                Spacer()
            }
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .foregroundStyle(Color(red: 13/255, green: 47/255, blue: 68/255))
            .scaledFont("Lato-Regular", size: 20)
            .background(Color(red: 249/255, green: 248/255, blue: 241/255))
        }
    }
    
    private var appHeader: some View {
        HStack {
            Text("PetalPal")
                .scaledFont("Prata-Regular", size: 28)
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
                    .foregroundColor(Color(red: 0/255, green: 122/255, blue: 69/255))
                    .padding(.trailing, 20)
            }
        }
        .frame(height: 56)
        .background(Color(red: 174/255, green: 213/255, blue: 214/255))
        .padding(.bottom, 15)
    }
    
    private var connectSmartPotSection: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(Color(red: 216/255, green: 232/255, blue: 202/255))
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Connect a Smart Pot (Wi-Fi)")
                    .scaledFont("Lato-Bold", size: 25)
                
                Text("Status: \(wifiManager.connectionStatus)")
                    .scaledFont("Lato-Regular", size: 18)
                    .foregroundColor(.black.opacity(0.7))
                
                if let errorMessage = wifiManager.errorMessage {
                    Text(errorMessage)
                        .scaledFont("Lato-Regular", size: 16)
                        .foregroundColor(.red)
                }
                
                deviceAddressInput
                plantInfoInput
                connectionButtons
                fetchDataButton
                lastReceivedDataDisplay
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .padding(.horizontal)
    }
    
    private var deviceAddressInput: some View {
        TextField("Enter Smart Pot IP Address or Hostname", text: $newDeviceAddress)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .keyboardType(.URL)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .onChange(of: newDeviceAddress) { newValue in
                wifiManager.deviceAddress = newValue
            }
            .onAppear {
                newDeviceAddress = wifiManager.deviceAddress
            }
    }
    
    private var plantInfoInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Plant Name")
                .scaledFont("Lato-Bold", size: 16)
                .foregroundColor(.black.opacity(0.7))
            TextField("Enter plant name", text: $plantName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .scaledFont("Lato-Regular", size: 18)
                .background(Color.white)
                .cornerRadius(8)
            
            Text("Plant Type")
                .scaledFont("Lato-Bold", size: 16)
                .foregroundColor(.black.opacity(0.7))
                .padding(.top, 8)
            Picker("Type", selection: $selectedType) {
                ForEach(PlantType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.vertical, 5)
            .background(Color(red: 174/255, green: 213/255, blue: 214/255))
            .cornerRadius(8)
        }
        .padding(.vertical, 15)
    }
    
    private var connectionButtons: some View {
        Button(action: {
            if !plantName.isEmpty {
                wifiManager.connect()
            }
        }) {
            Text("Connect")
                .scaledFont("Lato-Bold", size: 20)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(red: 82/255, green: 166/255, blue: 69/255))
                .cornerRadius(15)
        }
        .disabled(wifiManager.isConnecting || plantName.isEmpty)
        .onChange(of: wifiManager.connectionStatus) { newStatus in
            if newStatus.contains("Connected") && !plantName.isEmpty {
                // Create and save new plant
                let newPlant = Plant(name: plantName, type: selectedType)
                modelContext.insert(newPlant)
                
                // Reset form for next plant
                plantName = ""
                selectedType = .flower
            }
        }
    }
    
    private var fetchDataButton: some View {
        Button(action: {
            wifiManager.fetchSmartPotData()
        }) {
            Text("Fetch Latest Data")
                .scaledFont("Lato-Bold", size: 20)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(red: 67/255, green: 137/255, blue: 124/255))
                .cornerRadius(15)
        }
    }
    
    private var lastReceivedDataDisplay: some View {
        VStack(alignment: .leading) {
            Text("Last Received Data:")
                .scaledFont("Lato-Bold", size: 18)
                .padding(.top, 10)
            Text(wifiManager.lastReceivedData)
                .scaledFont("Lato-Regular", size: 16)
                .foregroundColor(.black.opacity(0.8))
                .padding(.horizontal)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.7))
                .cornerRadius(10)
        }
    }
}

#Preview {
    WifiView()
        .modelContainer(for: Plant.self, inMemory: true)
}