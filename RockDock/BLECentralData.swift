//
//  BLECentral.swift
//  RockDock
//
//  Created by Stephen Buck on 10/26/16.
//  Copyright © 2016 Stephen Buck. All rights reserved.
//

import Foundation
import CoreBluetooth

// A data class to represent BLE Central point of view.  This is used to record the Peripherals discovered and their data
// Peripherals have services have characteristics
class Service {
    var service: CBService!
    var characteristics: [CBCharacteristic]!
    var values: [Data]!
}

class Peripheral {
    var peripheral: CBPeripheral!
    var advertisementData: [String : Any]!
    var rssi: [NSNumber]!
    var errors: [Error]!
    var services: [Service]!
}


        
