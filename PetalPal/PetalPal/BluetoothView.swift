//
//  BluetoothView.swift
//  PetalPal
//
//  Created by Adishree Das on 7/22/25.
//

import SwiftUI
import CoreBluetooth

// Bluetooth Manager Class
class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    @Published var centralManager: CBCentralManager!
    @Published var discoveredPeripherals: [(peripheral: CBPeripheral, advertisedName: String)] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var isScanning: Bool = false
    @Published var connectionStatus: String = "Disconnected"
    @Published var errorMessage: String?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            connectionStatus = "Ready to Scan"
        case .poweredOff:
            connectionStatus = "Bluetooth Off"
            stopScanning()
            discoveredPeripherals.removeAll()
            connectedPeripheral = nil
        case .unauthorized:
            connectionStatus = "Unauthorized"
            errorMessage = "Bluetooth permissions denied. Please enable them in Settings."
        default:
            connectionStatus = "Error"
        }
    }

    func startScanning() {
        guard centralManager.state == .poweredOn else {
            errorMessage = "Bluetooth is not powered on."
            return
        }
        discoveredPeripherals.removeAll()
        let options: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: true
        ]
        centralManager.scanForPeripherals(withServices: nil, options: options)
        isScanning = true
        connectionStatus = "Scanning..."
    }

    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        if connectedPeripheral == nil {
            connectionStatus = "Scan Stopped"
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Get the actual advertised name of the device
        let advertisedName = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? peripheral.name ?? "Unknown Device"
        
        if let existingIndex = discoveredPeripherals.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }) {
            // Update existing peripheral if name changed
            if discoveredPeripherals[existingIndex].advertisedName != advertisedName {
                discoveredPeripherals[existingIndex] = (peripheral: peripheral, advertisedName: advertisedName)
            }
        } else {
            // Add new peripheral
            discoveredPeripherals.append((peripheral: peripheral, advertisedName: advertisedName))
        }
    }

    func connect(peripheral: CBPeripheral) {
        guard centralManager.state == .poweredOn else { return }
        stopScanning()
        centralManager.connect(peripheral, options: nil)
        connectionStatus = "Connecting..."
    }

    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            connectionStatus = "Disconnecting..."
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        connectionStatus = "Connected to \(peripheral.name ?? "Device")"
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionStatus = "Connection Failed"
        errorMessage = error?.localizedDescription ?? "Unknown error"
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil
        connectionStatus = "Disconnected"
        if let error = error {
            errorMessage = "Disconnected with error: \(error.localizedDescription)"
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
}

struct AddPlantSheet: View {
    @Binding var isPresented: Bool
    @State private var plantName = ""
    @State private var selectedType = PlantType.flower
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 249/255, green: 248/255, blue: 241/255)
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // Title
                    Text("Add New Plant")
                        .font(.custom("KaushanScript-Regular", size: 50))
                        .foregroundColor(Color(red: 67/255, green: 137/255, blue: 124/255))
                        .padding(.top, 20)
                    
                    // Plant Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Plant Name")
                            .font(.custom("Lato-Bold", size: 16))
                            .foregroundColor(.black.opacity(0.7))
                        TextField("Enter plant name", text: $plantName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.custom("Lato-Regular", size: 18))
                            .background(Color.pink.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 25)
                    
                    // Plant Type Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Plant Type")
                            .font(.custom("Lato-Bold", size: 16))
                            .foregroundColor(.black.opacity(0.7))
                        Picker("Type", selection: $selectedType) {
                            Text("Flower").tag(PlantType.flower)
                            Text("Herb").tag(PlantType.herb)
                            Text("Vegetable").tag(PlantType.vegetable)
                            Text("Fruit").tag(PlantType.fruit)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 5)
                        .background(Color(red: 174/255, green: 213/255, blue: 214/255))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 25)
                    
                    Spacer()
                    
                    // Add Button
                    Button(action: {
                        let newPlant = Plant(name: plantName, type: selectedType)
                        PlantData.samplePlants.append(newPlant)
                        isPresented = false
                    }) {
                        Text("Add Plant")
                            .font(.custom("Lato-Bold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(red: 67/255, green: 137/255, blue: 124/255))
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            )
                    }
                    .disabled(plantName.isEmpty)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarItems(
                trailing: Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(red: 67/255, green: 137/255, blue: 124/255))
                        .font(.system(size: 24))
                }
            )
        }
    }
}

// Bluetooth View
struct BluetoothView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var showAddPlant = false

    var body: some View {
        NavigationStack {
            // Top Navigation Bar
            HStack {
                Text("Petal Pal")
                    .font(.custom("KaushanScript-Regular", size: 28))
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
                        Text("Connect a Device")
                            .font(.custom("Lato-Bold", size: 25))
                        
                        Text("Status: \(bluetoothManager.connectionStatus)")
                            .font(.custom("Lato-Regular", size: 18))
                            .foregroundColor(.black.opacity(0.7))
                        
                        if let errorMessage = bluetoothManager.errorMessage {
                            Text(errorMessage)
                                .font(.custom("Lato-Regular", size: 16))
                                .foregroundColor(.red)
                        }
                        
                        Button(action: {
                            if bluetoothManager.isScanning {
                                bluetoothManager.stopScanning()
                            } else {
                                bluetoothManager.startScanning()
                            }
                        }) {
                            Text(bluetoothManager.isScanning ? "Stop Scanning" : "Scan for Devices")
                                .font(.custom("Lato-Bold", size: 20))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(bluetoothManager.isScanning ? Color.red : Color(red: 82/255, green: 166/255, blue: 69/255))
                                .cornerRadius(15)
                        }
                        
                        // Discovered Devices List
                        List {
                            if !bluetoothManager.discoveredPeripherals.isEmpty {
                                ForEach(bluetoothManager.discoveredPeripherals, id: \.peripheral.identifier) { device in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(device.advertisedName)
                                                .font(.custom("Lato-Bold", size: 18))
                                            Text(device.peripheral.identifier.uuidString)
                                                .font(.custom("Lato-Regular", size: 12))
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        if bluetoothManager.connectedPeripheral?.identifier == device.peripheral.identifier {
                                            Button(action: {
                                                showAddPlant = true
                                            }) {
                                                Text("Add Plant")
                                                    .font(.custom("Lato-Regular", size: 16))
                                                    .foregroundColor(.white)
                                                    .padding(.init(top: 6, leading: 12, bottom: 6, trailing: 12))
                                                    .background(Color(red: 82/255, green: 166/255, blue: 69/255))
                                                    .cornerRadius(10)
                                            }
                                        } else {
                                            Button(action: { bluetoothManager.connect(peripheral: device.peripheral) }) {
                                                Text("Connect")
                                                    .font(.custom("Lato-Regular", size: 16))
                                                    .foregroundColor(.white)
                                                    .padding(.init(top: 6, leading: 12, bottom: 6, trailing: 12))
                                                    .background(Color(red: 82/255, green: 166/255, blue: 69/255))
                                                    .cornerRadius(10)
                                            }
                                            .disabled(bluetoothManager.connectedPeripheral != nil)
                                        }
                                    }
                                    .listRowBackground(Color.clear)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .background(Color.clear)
                        .frame(height: 350) // Adjust height as needed
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                }
                .padding(.horizontal)
            }
            Spacer()

            // Bottom Navigation Bar
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
                    BluetoothView()
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
        .sheet(isPresented: $showAddPlant) {
            AddPlantSheet(isPresented: $showAddPlant)
        }
    }
}

#Preview {
    BluetoothView()
}
