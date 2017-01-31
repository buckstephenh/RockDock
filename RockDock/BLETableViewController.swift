//
//  BLETableViewController.swift
//  RockDock
//
//  Created by Stephen Buck on 11/17/16.
//  Copyright © 2016 Stephen Buck. All rights reserved.
//

import CoreBluetooth
import Foundation
import UIKit

class BLETableViewController : UIViewController, CBPeripheralManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    //MARK: Bluetooth Peripheral Properties
    var peripheralManager: CBPeripheralManager!
    var centralManager: CBCentralManager!
    var discoveredPeripherals : [CBPeripheral] = []
    
    let NOTIFY_MTU = 20
    
    let TRANSFER_CHARACTERISTIC_UUID = "3519B967-2CD8-4B61-85B2-3D399DE3674B"
    let tcUUID = CBUUID.init(string: "3519B967-2CD8-4B61-85B2-3D399DE3674B")
    
    weak var transferCharacteristic: CBMutableCharacteristic!
    
    let TRANSFER_SERVICE_UUID = "917F9E97-2A09-4DD1-BEC2-429E46AAED82"
    let tsUUID = CBUUID.init(string: "917F9E97-2A09-4DD1-BEC2-429E46AAED82")
    
    var dataToSend: Data!
    var dataToReceive: Data = Data()
    var sendDataIndex: Int = 0
    
    //MARK: View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Start up the CBPeripheralManager
        let options: Dictionary<String, AnyObject> = [ CBPeripheralManagerOptionShowPowerAlertKey:true as AnyObject ]
        peripheralManager = CBPeripheralManager.init(delegate: self, queue: nil, options: options)
        
        // Start up the CBCentralManager
        centralManager = CBCentralManager.init(delegate: self, queue: nil, options: nil)
        
//        if ((peripheralManager) != nil) {
//            tradeSwitch.isEnabled = true
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if (centralManager.state == CBManagerState.poweredOn){
            peripheralManager?.stopAdvertising()
            print ("Bluetooth advertising deactivated")
            centralManager.stopScan()
            print ("Bluetooth scanning deactivated")
        }
        super.viewWillDisappear(animated)
    }


    
    //MARK: Bluetooth Central

/** centralManagerDidUpdateState is a required protocol method.
 *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
 *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
 *
 */
func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if(central.state != CBManagerState.poweredOn){
        
        return
    }
    
    // The state must be CBManagerState.poweredOn
    // Start scanning
    scan()
}

func scan(){
    
    //    centralManager.scanForPeripherals(withServices: [tsUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    
    centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    
    print("Scanning Started")
}

/** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    
    //Reject any where the value is above reasonable range
    //if(RSSI.intValue > -15){
    //    return
    //}
    
    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
    //if(RSSI.intValue < -35){
    //    return
    //}
    
    print("Discovered \(peripheral.name) at \(RSSI)")
    
    // have we already seen it?
    if !(discoveredPeripherals.contains(peripheral)){
        
        
        // And connect
        print("Connecting to peripheral \(peripheral)")
        
        centralManager.connect(peripheral, options: nil)
        
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        discoveredPeripherals.append(peripheral)
        
    }
}

/** If the connection fails for whatever reason, we need to deal with it.
 */
func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    print("Failed to connect to \(peripheral), \(error)")
    
    cleanup()
}

 
    func startAdvertising(){
        if peripheralManager.state == CBManagerState.poweredOn {
            // All we advertise is our service's UUID
        let advertisingData: Dictionary = [CBAdvertisementDataServiceUUIDsKey:[tsUUID], CBAdvertisementDataLocalNameKey:"RockDock"] as [String : Any]
        peripheralManager.startAdvertising(advertisingData)
        print ("started advertising")
        }
    }
    
    func stopAdvertising(){
        if peripheralManager.state == CBManagerState.poweredOn {
            peripheralManager.stopAdvertising()
        print ("stopped advertising")
        }
    }
    /** Call this when things either go wrong, or you're done with the connection.
     *  This cancels any subscriptions if there are any, or straight disconnects if not.
     *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
     */

func cleanup(){
    for discoveredPeripheral in discoveredPeripherals {
        
        // Don't do anything if we're not connected
        if !(discoveredPeripheral.state == CBPeripheralState.connected) {
            return
        }
        
        // See if we are subscribed to a characteristic on the peripheral
        if discoveredPeripheral.services != nil{
            for service in discoveredPeripheral.services! {
                if service.characteristics != nil {
                    for characteristic in service.characteristics! {
                        if characteristic.uuid == tcUUID {
                            if characteristic.isNotifying {
                                // It is notifying so unsubscribe
                                discoveredPeripheral.setNotifyValue(false, for: characteristic)
                                
                                // And we're done.
                                return
                            }
                        }
                    }
                }
            }
        }
        
        // if we've gone this far, we're connected but we're not subscribed, so we just disconnect
        centralManager.cancelPeripheralConnection(discoveredPeripheral)
    }
    
}

//MARK: Bluetooth Peripheral

func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
    print("in peripheralManagerDidStartAdvertising \(peripheral)) error: \(error)")
}

func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
    print ("in peripheralManager.didReceiveRead for peripheral \(peripheral) and request \(request)")
}

func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
    print ("in peripheralManager.didAdd service \(service) error:\(error)")
}

func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
    print (" in peripheralManager.didReceiveWrite peripheral \(peripheral) requests \(requests)")
}

func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    
    if(peripheral.state != CBManagerState.poweredOn){
        //We're not on...
//        tradeSwitch.isEnabled = false
//        tradeLabel.text = "To trade turn Bluetooth on!"
        NSLog("\(self.peripheralManager) not powered on.")
        return;
    }
    
    //We're in CBManagerSTate.poweredOn state...
    NSLog("\(self.peripheralManager) powered on.")
    
    // ... so build our service
    
    //Start with the CBMutableCharacteristic
    
    transferCharacteristic = CBMutableCharacteristic.init(type: tcUUID, properties: CBCharacteristicProperties.notify, value: nil, permissions: CBAttributePermissions.readable)
    
    
    
    //Then the service
    let transferService = CBMutableService(type: tsUUID, primary: true)
    
    
    //Add the characteristic to the service
    transferService.characteristics?.append(transferCharacteristic)
    
    //And add it to the peripheral manager
    peripheralManager.add(transferService)
    
    //tradeSwitch.isEnabled = true
    //tradeLabel.text = "Trade"
}

/** Catch when someone subscribes to our characteristic, then start sending them data
 */
func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
    
    NSLog("Central subscribed to characteristic")
    
    // Get the data
//    dataToSend = NSKeyedArchiver.archivedData(withRootObject: rock)
    
    // Reset the index
    sendDataIndex = 0
    
    //Start sending
    sendData()
    
    
}

func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
    NSLog("in CBPeripheralManager.willRestoreState")
}

/** Recognise when the central unsubscribes
 */
func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
    
    NSLog("Central unsubscribed from characteristic")
}

/** Sends the next amount of data to the connected central
 */
func sendData(){
    
    struct SendStatus {
        static var sendingEOM =  false
    }
    
    var didSend: Bool
    
    // First up, check if we're meant to be sending an EOM
    if SendStatus.sendingEOM {
        //send it
        didSend = peripheralManager.updateValue("EOM".data(using: .utf8)!, for: transferCharacteristic, onSubscribedCentrals: nil)
        
        // Did it send?
        if (didSend) {
            
            // It did, so mark it as sent
            SendStatus.sendingEOM = false
            
            NSLog("sent: EOM")
        }
        
        // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return
    }
    
    // We're not sending an EOM, so we're sending data
    
    // Is there any left to send?
    
    if(sendDataIndex >= dataToSend.count){
        
        // No data left.  Do nothing
        return
    }
    
    //There's data left, so send until the callback fails, or we're done.
    
    didSend = true
    
    while (didSend) {
        
        // Make the next chunk
        
        //Work out how big it should be
        var amountToSend = dataToSend.count
        
        // Can't be longer than 20 bytes
        if(amountToSend > NOTIFY_MTU) {
            amountToSend = NOTIFY_MTU
        }
        
        //Copy out the data we want
        let chunk = dataToSend.subdata(in: Range(sendDataIndex...sendDataIndex+amountToSend))
        
        
        
        // Send it
        didSend = peripheralManager.updateValue(chunk, for: transferCharacteristic, onSubscribedCentrals: nil)
        
        // If it didn't work, drop out and wait for the callback
        if !didSend {
            return
        }
        
        NSLog("Sent: \(chunk)")
        
        // It did send, so update our index
        sendDataIndex += amountToSend
        
        // Was it the last one?
        if sendDataIndex >= dataToSend.count{
            // It was - end an EOM
            
            // Set this so if the send fails, we'll send it next time
            SendStatus.sendingEOM = true
            
            // Send it
            let eomSent = peripheralManager.updateValue("EOM".data(using: .utf8)!, for: transferCharacteristic, onSubscribedCentrals: nil)
            
            if(eomSent){
                // It sent, we're all done
                SendStatus.sendingEOM = false;
                
                NSLog("Sent: EOM")
            }
            
            return
        }
    }
}

/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */

func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
    // Start sending again
    sendData()
}


/** Start advertising
 */

func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
    print("peripheral \(peripheral) invalidatedServices \(invalidatedServices)")
    cleanup()
    scan()
}

/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    
    print("Peripheral Connected")
    
    // Stop scanning
    //centralManager.stopScan()
    //print("Scanning Stopped")
    
    // Clear the data that we may already have
    //dataToReceive = Data()
    
    //Make sure we get the discovery callbacks
    peripheral.delegate = self
    
    // Search only for services that match our UUID
    //peripheral.discoverServices([tsUUID])
    peripheral.discoverServices(nil)
    
}

/** The Transfer Service was discovered
 */
func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    
    if ((error) != nil) {
        print("error discovering services: \(error)")
        print("didDiscoverServices calling cleanup()")
        cleanup()
        return
    }
    
    // Discover the characteristic we want...
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    
    for service in peripheral.services! {
        //peripheral.discoverCharacteristics([tcUUID], for: service)
        peripheral.discoverCharacteristics(nil, for: service)
        
    }
}

/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    
    print("Found characteriscs for service:\(service)")
    
    // Deal with errors (if any)
    if error != nil {
        print("Error discovering characteristics: \(error)")
        print("Exiting didDiscoverCharateristicsFor: Calling cleanup() now")
        cleanup()
        return
    }
    
    //Again we loop through the array, just in case
    for characteristic in service.characteristics!{
        print(characteristic.uuid.uuidString)
        print("Found characteristic:\(characteristic)")
        print("value \(characteristic.value)")
        print("descriptors \(characteristic.descriptors)")
        print("properties \(characteristic.properties)")
        
        
        print("Reading value for characteristic: \(characteristic)")
        
        if(characteristic.properties.contains(CBCharacteristicProperties.read)){
            //ask to read the value --should show up in the callback
            peripheral.readValue(for: characteristic)
        }
        
        if(characteristic.properties.contains(CBCharacteristicProperties.indicate) || characteristic.properties.contains(CBCharacteristicProperties.notify)){
            
            peripheral.setNotifyValue(true, for: characteristic)
            
        }
        
        // And check if it's the right one
        //if characteristic.properties.rawValue > 2 {
        
        // If it is, subscribe to it...how do we know we can subscribe?
        //what do we mean the "right one"?
        //peripheral.setNotifyValue(true, for: characteristic)
        //}
        
        //Once this is complete, we just need to wait for the data to come in.
    }
}

/** This callback lets us know more data has arrived via notification on the characteristic
 */
func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    
    if error != nil {
        print("Error discovering characteristics: \(error)")
        return
    }
    
    let stringFromData = String.init(data: characteristic.value!, encoding: .utf8)
    
    // Have we got everything we need?
    if stringFromData == "EOM" {
        
        // We have, so show the data
        // should be a rock
        print("got EOM, we're done")
        print("dataToReceive:\(dataToReceive)")
        
        
        if let inboundRock = NSKeyedUnarchiver.unarchiveObject(with: dataToReceive) as! Rock? {
            navigationItem.title = inboundRock.name
//            rockName.text   = inboundRock.name
//            imageView.image = inboundRock.photo
//            ratingControl.rating = inboundRock.rating
//            ratingControl.updateButtonSelectionStates()
        }
        
        // Cancel our subscription to the characteristic
        //peripheral.setNotifyValue(false, for: characteristic)
        
        // and disconnect from the peripheral
        //centralManager.cancelPeripheralConnection(peripheral)
        
    }
    
    // Otherwise, just add the data onto what we already have
    dataToReceive.append((characteristic.value)!)
    
    print("peripheral \(peripheral) characteristic \(characteristic) received: \(stringFromData) error: \(error)")
    
}

func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    
    if error != nil {
        print("Error changing notification state for peripheral \(peripheral) characteristic \(characteristic) error \(error)")
    }
    
    // Exit if it's not the transfer characteristic
    //if characteristic.uuid != tcUUID {
    //    return
    //}
    
    // Notification has started
    if(characteristic.isNotifying){
        print("Notification began on \(characteristic)")
    }
        
        // Notification has stopped
    else {
        // so disconnnect from the peripheral
        print("Notification stopped on \(characteristic). Disconnecting")
        
        //centralManager.cancelPeripheralConnection(peripheral)
    }
}

/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    
    print("Peripheral Disconnected")
    discoveredPeripherals.remove(at: discoveredPeripherals.index(of:peripheral)!)
    
    // We're disconnected, so start scanning again
    scan()
}
    

}
