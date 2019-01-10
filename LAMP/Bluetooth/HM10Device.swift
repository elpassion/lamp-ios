import CoreBluetooth
import UIKit

struct HM10Device {
    let peripheral: CBPeripheral
    let writeCharacteristic: CBCharacteristic

    init?(peripheral: CBPeripheral?, writeCharacteristic: CBCharacteristic?) {
        guard let peripheral = peripheral, let writeCharacteristic = writeCharacteristic else {
            return nil
        }

        self.peripheral = peripheral
        self.writeCharacteristic = writeCharacteristic
    }
}

extension HM10Device {

    func send(data: Data) {
        peripheral.writeValue(data, for: writeCharacteristic, type: .withoutResponse)
    }

}
