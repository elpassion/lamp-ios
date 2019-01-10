import CoreBluetooth

class BluetoothConnector: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    lazy var centralManager: CBCentralManager = {
        CBCentralManager(delegate: nil, queue: nil)
    }()

    func connect(_ completionHandler: ((HM10Device) -> Void)?) {
        centralManager.delegate = self
        completion = completionHandler
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        default:
            fatalError("Unhandled error")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name, name == nameHM10 {
            connected = peripheral
            centralManager.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceHM10])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let services = peripheral.services ?? []
        services.forEach { peripheral.discoverCharacteristics([characteristicHM10], for: $0) }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let characteristics = service.characteristics ?? []
        writeCharacteristic = characteristics.first { $0.uuid == characteristicHM10 }

        if let device = HM10Device(peripheral: connected, writeCharacteristic: writeCharacteristic) {
            completion?(device)
        }
    }

    private let nameHM10 = "BT05"
    private let serviceHM10 = CBUUID(string: "FFE0")
    private let characteristicHM10 = CBUUID(string: "FFE1")

    var connected: CBPeripheral?
    var writeCharacteristic: CBCharacteristic?
    private var completion: ((HM10Device) -> Void)?

}
