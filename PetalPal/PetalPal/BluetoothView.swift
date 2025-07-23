//
//  BluetoothView.swift
//  PetalPal
//
//  Created by Adishree Das on 7/22/25.
//

import SwiftUI
import CoreBluetooth // Import CoreBluetooth for Bluetooth functionality

// MARK: - BluetoothManager
// This class manages all Core Bluetooth interactions.
class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    // MARK: - Published Properties
    // These properties will automatically notify SwiftUI views of changes.
    @Published var centralManager: CBCentralManager! // The central manager to manage Bluetooth operations.
    @Published var discoveredPeripherals: [CBPeripheral] = [] // List of discovered Bluetooth peripherals.
    @Published var connectedPeripheral: CBPeripheral? // The currently connected peripheral.
    @Published var isScanning: Bool = false // Indicates if the central manager is currently scanning.
    @Published var connectionStatus: String = "Disconnected" // Current connection status.
    @Published var errorMessage: String? // To display any error messages.

    // MARK: - Initialization
    // Initializes the BluetoothManager and sets up the central manager.
    override init() {
        super.init()
        // Initialize the central manager with this class as its delegate.
        // The queue is nil, meaning it will use the main dispatch queue.
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - Bluetooth State Handling
    // Called when the central manager's state changes (e.g., Bluetooth is powered on/off).
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is Powered On and ready to use.")
            connectionStatus = "Ready to Scan"
            // Optionally start scanning immediately if desired, or wait for user action.
            // startScanning()
        case .poweredOff:
            print("Bluetooth is Powered Off. Please turn it on.")
            connectionStatus = "Bluetooth Off"
            stopScanning()
            discoveredPeripherals.removeAll()
            connectedPeripheral = nil
        case .resetting:
            print("Bluetooth is Resetting.")
            connectionStatus = "Resetting"
        case .unauthorized:
            print("Bluetooth is Unauthorized. Check app permissions.")
            connectionStatus = "Unauthorized"
            errorMessage = "Bluetooth permissions denied. Please enable them in Settings."
        case .unsupported:
            print("Bluetooth is Unsupported on this device.")
            connectionStatus = "Unsupported"
            errorMessage = "This device does not support Bluetooth Low Energy."
        case .unknown:
            print("Bluetooth state is Unknown.")
            connectionStatus = "Unknown State"
        @unknown default:
            print("A new, unknown Bluetooth state occurred.")
            connectionStatus = "Unknown State"
        }
    }

    // MARK: - Scanning Operations
    // Starts scanning for Bluetooth peripherals.
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            errorMessage = "Bluetooth is not powered on."
            return
        }
        print("Starting scan for peripherals...")
        discoveredPeripherals.removeAll() // Clear previous scan results
        // Scan for all peripherals (passing nil for services)
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        isScanning = true
        connectionStatus = "Scanning..."
    }

    // Stops scanning for Bluetooth peripherals.
    func stopScanning() {
        print("Stopping scan for peripherals.")
        centralManager.stopScan()
        isScanning = false
        if connectedPeripheral == nil {
            connectionStatus = "Scan Stopped"
        }
    }

    // Called when a peripheral is discovered.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Ensure the peripheral is not already in our list (based on identifier).
        if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredPeripherals.append(peripheral)
            print("Discovered peripheral: \(peripheral.name ?? "Unknown Device") (\(peripheral.identifier.uuidString))")
        }
    }

    // MARK: - Connection Operations
    // Connects to a specific peripheral.
    func connect(peripheral: CBPeripheral) {
        guard centralManager.state == .poweredOn else {
            errorMessage = "Bluetooth is not powered on to connect."
            return
        }
        stopScanning() // Stop scanning before connecting to save power.
        centralManager.connect(peripheral, options: nil)
        connectionStatus = "Connecting to \(peripheral.name ?? "Unknown Device")..."
        print("Attempting to connect to \(peripheral.name ?? "Unknown Device")...")
    }

    // Called when a peripheral successfully connects.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        peripheral.delegate = self // Set the peripheral's delegate to this manager for further interactions.
        connectionStatus = "Connected to \(peripheral.name ?? "Unknown Device")"
        print("Successfully connected to \(peripheral.name ?? "Unknown Device").")
        // Now you can discover services and characteristics if needed:
        // peripheral.discoverServices(nil)
    }

    // Called when a peripheral fails to connect.
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil
        connectionStatus = "Connection Failed"
        errorMessage = "Failed to connect to \(peripheral.name ?? "Unknown Device"): \(error?.localizedDescription ?? "Unknown error")"
        print("Failed to connect to \(peripheral.name ?? "Unknown Device"): \(error?.localizedDescription ?? "Unknown error")")
    }

    // Called when a peripheral disconnects.
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil
        connectionStatus = "Disconnected"
        if let error = error {
            errorMessage = "Disconnected from \(peripheral.name ?? "Unknown Device") with error: \(error.localizedDescription)"
            print("Disconnected from \(peripheral.name ?? "Unknown Device") with error: \(error.localizedDescription)")
        } else {
            print("Disconnected from \(peripheral.name ?? "Unknown Device").")
        }
        // Optionally restart scanning after disconnection.
        // startScanning()
    }

    // Disconnects from the currently connected peripheral.
    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            connectionStatus = "Disconnecting..."
            print("Attempting to disconnect from \(peripheral.name ?? "Unknown Device")...")
        }
    }

    // MARK: - CBPeripheralDelegate (Optional, for service/characteristic discovery)
    // You would implement these methods if you need to interact with services and characteristics
    // on the connected peripheral (e.g., read sensor data, send commands).
    /*
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        guard let services = peripheral.services else { return }
        for service in services {
            print("Discovered service: \(service.uuid)")
            // Discover characteristics for each service
            // peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print("Discovered characteristic: \(characteristic.uuid)")
            // You can read, write, or subscribe to notifications for characteristics here
            // if characteristic.properties.contains(.read) {
            //     peripheral.readValue(for: characteristic)
            // }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error updating characteristic value: \(error.localizedDescription)")
            return
        }
        // Handle incoming data from the characteristic
        if let value = characteristic.value {
            let dataString = String(data: value, encoding: .utf8) ?? value.description
            print("Received data from \(characteristic.uuid): \(dataString)")
            // Update UI or process data
        }
    }
    */
}

// MARK: - BluetoothView
// The SwiftUI view for displaying and interacting with Bluetooth devices.
struct BluetoothView: View {
    // State object to observe changes in the BluetoothManager.
    @StateObject private var bluetoothManager = BluetoothManager()

    // MARK: - Body
    var body: some View {
        NavigationStack {
            // Top Navigation Bar
            HStack {
                Text("Petal Pal")
                    .font(.custom("MadimiOne-Regular", size: 28)) // Ensure this font is available in your project
                    .foregroundColor(.black)
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
            .background(Color(red: 195/255, green: 225/255, blue: 243/255))
            .padding(.bottom, 15)

            // Main Content Area
            ScrollView {
                VStack {
                    Text("Bluetooth Devices")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    
                    // Bluetooth Status
                    Text("Status: \(bluetoothManager.connectionStatus)")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                    
                    // Error Message Display
                    if let errorMessage = bluetoothManager.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                    }
                    
                    // Scan/Stop Scan Button
                    Button(action: {
                        if bluetoothManager.isScanning {
                            bluetoothManager.stopScanning()
                        } else {
                            bluetoothManager.startScanning()
                        }
                    }) {
                        Text(bluetoothManager.isScanning ? "Stop Scanning" : "Start Scanning")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(bluetoothManager.isScanning ? Color.red : Color.blue)
                            .cornerRadius(15)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                    
                    // Discovered Devices List
                    List {
                        Section(header: Text("Discovered Devices").font(.title3)) {
                            if bluetoothManager.discoveredPeripherals.isEmpty {
                                Text(bluetoothManager.isScanning ? "Searching for devices..." : "No devices found. Tap 'Start Scanning'.")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(bluetoothManager.discoveredPeripherals, id: \.identifier) { peripheral in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(peripheral.name ?? "Unknown Device")
                                                .font(.headline)
                                            Text(peripheral.identifier.uuidString)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        if bluetoothManager.connectedPeripheral?.identifier == peripheral.identifier {
                                            // Connected state
                                            Text("Connected")
                                                .font(.subheadline)
                                                .foregroundColor(.green)
                                            Button(action: {
                                                bluetoothManager.disconnect()
                                            }) {
                                                Text("Disconnect")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                    .padding(.vertical, 5)
                                                    .padding(.horizontal, 10)
                                                    .background(Color.orange)
                                                    .cornerRadius(10)
                                            }
                                        } else {
                                            // Not connected state
                                            Button(action: {
                                                bluetoothManager.connect(peripheral: peripheral)
                                            }) {
                                                Text("Connect")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                    .padding(.vertical, 5)
                                                    .padding(.horizontal, 10)
                                                    .background(Color.green)
                                                    .cornerRadius(10)
                                            }
                                            .disabled(bluetoothManager.connectedPeripheral != nil) // Disable if another device is connected
                                        }
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        }
                    }
                    .listStyle(.plain) // Use plain list style for better control
                }
            }
            Spacer() // Pushes content to the top

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
                } label: {
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                NavigationLink{
                    BluetoothView()
                } label: {
                    Image(systemName: "plus.app.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color(red: 0/255, green: 122/255, blue: 69/255))
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
            .background(Color(red: 195/255, green: 225/255, blue: 243/255))
        }
    }
}

#Preview {
    BluetoothView()
}
