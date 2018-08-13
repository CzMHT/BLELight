//
//  BLEConnect.swift
//  BLELight
//
//  Created by YuanGu on 2018/8/8.
//  Copyright © 2018年 YuanGu. All rights reserved.
//

import UIKit
import CoreBluetooth

@objc protocol BLEConnectProtocol: NSObjectProtocol {
    
    @objc optional func connectResult(_ success: Bool)
    @objc optional func updateLists(_ result: CBPeripheral! ,rssi: Int)
    @objc optional func updateService(_ results: CBService!)
    @objc optional func updateReadValue(_ read: String?)
}

class BLEConnect: NSObject {

    static let shared = BLEConnect()
    
    var codeType: String.Encoding = .utf8
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var characterWrite: CBCharacteristic!
    var characterNoti: CBCharacteristic!
    var receiveData: Data!
    var drivingDis: Bool = true //是否主动断开
    var isWithoutResponse: Bool = true
    var mutex: pthread_mutex_t = pthread_mutex_t() //初始化pthread_mutex_t类型变量
    
    weak var delegate: BLEConnectProtocol?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil,
                                          options: [CBCentralManagerOptionShowPowerAlertKey : true])
        // 初始化
        pthread_mutex_init(&mutex, nil)
    }
    
    public func centralScan(_ isStop: Bool){
        
        if isStop {
            centralManager.stopScan()
        } else {
            centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        }
    }
    
    public func connect(_ peripheral: CBPeripheral) {
        drivingDis = false
        centralManager.connect(peripheral, options: nil)
    }
    
    public func discoverService() {
        self.peripheral.discoverServices(nil)
    }
    
    public func disConnect() {
        guard peripheral != nil else {
            return
        }
        drivingDis = true
        centralManager.cancelPeripheralConnection(peripheral)
    }
        
    public func sendData(_ data: Data) -> (){
        guard data.count != 0 else {
            return
        }
        guard (self.peripheral) != nil else {
            return
        }
        guard (self.characterWrite) != nil else {
            return
        }
        
        //TimeLog("发送数据")
        
        //读取数据
        self.peripheral?.writeValue(data,
                                    for: self.characterWrite!,
                                    type: isWithoutResponse ? .withoutResponse : .withResponse)
    }
}

extension BLEConnect: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
            break
        case .poweredOff:
            print("蓝牙未开启")
            break
        default:
            alert("蓝牙不支持")
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        guard peripheral.name != nil else {
            return
        }
        
        print("Name: \(peripheral.name ?? "")")
        print("count: \(advertisementData.count)")
        
        self.delegate?.updateLists?(peripheral, rssi: RSSI.intValue)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("didConnect")
        self.centralManager?.stopScan()
        self.peripheral = peripheral
        self.peripheral?.delegate = self
        self.peripheral?.discoverServices(nil)
        self.delegate?.connectResult?(true)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        self.peripheral = nil
        self.delegate?.connectResult?(false)
        
        print("FailToConnect")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        print("didDisconnectPeripheral")
        self.delegate?.connectResult?(false)
        
        if !drivingDis {
            centralManager.connect(peripheral, options: nil)
        } else {
            
            drivingDis = false
            
            self.characterWrite = nil
            self.peripheral = nil
            
            //继续扫描
            centralScan(false)
        }
    }
}

extension BLEConnect: CBPeripheralDelegate {
    //发现 服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        //遍历所有的服务
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    //发现 特征值
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        for character in service.characteristics! {
            
            //print("character: \(character)")
            
            peripheral.setNotifyValue(true, for: character)
            
            if characterWrite != nil, characterWrite == character {
                characterWrite = character
            }
        }
        
        self.delegate?.updateService?(service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard error != nil else { return }
        
        if characteristic.value != nil {
            
            if let content: String = String(data: characteristic.value!, encoding: .utf16) {
                
                TimeLog("write with response: \(content)")
            }
        }
    }
    
    //收到 通知 setNotifyValue
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil{
            return
        }
        
        print("蓝牙状态变化")
    }
    //获取 收到的 数据
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil { return }
        
        let data: Data = characteristic.value! as Data
        
        if let content: String = String(data: data, encoding: codeType) {
            
            print("监听接收:content: \(content)")
            
            self.delegate?.updateReadValue?(content)
        }
    }
}
