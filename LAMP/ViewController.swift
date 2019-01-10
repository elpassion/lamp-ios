//
//  ViewController.swift
//  LAMP
//
//  Created by Jakub Turek on 10/01/2019.
//  Copyright © 2019 EL Passion. All rights reserved.
//

import CoreBluetooth
import UIKit

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    lazy var centralManager: CBCentralManager = {
        CBCentralManager(delegate: self, queue: nil)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Manager: \(centralManager)")
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Did update state?")
        switch central.state {
        case .poweredOn:
            print("Scanning")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        default:
            print("Fucked up state: \(central.state)")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name, name == "BT05" {
            connected = peripheral
            centralManager.connect(peripheral, options: nil)
        }
    }

    var connected: CBPeripheral?
    var writeCharacteristic: CBCharacteristic?

    let serviceUUID = CBUUID(string: "FFE0")
    let characteristicUUID = CBUUID(string: "FFE1")

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let services = peripheral.services ?? []

        print("Did discover services")

        for service in services {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let characteristics = service.characteristics ?? []

        print("Did discover chars")

        guard let writeCharacteristic = characteristics.first(where: { $0.uuid == characteristicUUID }) else {
            return
        }

        self.writeCharacteristic = writeCharacteristic

        let dates: [String] = ["r", "g", "b"]
        sendNext(dates, iteration: 0)
    }

    private func sendNext(_ values: [String], iteration: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let connected = self?.connected, let write = self?.writeCharacteristic else {
                return
            }
            let value = values[iteration % 3]
            let data = Data(value.utf8)

            print("Sending value: \(value)")

            connected.writeValue(data, for: write, type: .withoutResponse)

            self?.sendNext(values, iteration: iteration + 1)
        }
    }




}

