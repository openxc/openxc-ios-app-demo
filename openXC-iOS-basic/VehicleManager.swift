//
//  VehicleManager.swift
//  openXCSwift
//
//  Created by Tim Buick on 2016-06-16.
//  Copyright © 2016 BugLabs. All rights reserved.
//

import Foundation
import CoreBluetooth


enum VehicleMessageType: NSString {
  case MeasurementResponse
  case CommandResponse
  case DiagnosticRequest
  case DiagnosticResponse
  case CanResponse
}

enum VehicleCommandType: NSString {
  case version
  case device_id
}


class VehicleBaseMessage {
  var timestamp: NSInteger = 0
  var type: VehicleMessageType = .MeasurementResponse
  func traceOutput() -> NSString {
    return "{}"
  }
}


class VehicleMeasurementResponse : VehicleBaseMessage {
  override init() {
    value = NSNull()
    event = NSNull()
    super.init()
    type = .MeasurementResponse
  }
  var name : NSString = ""
  var value : AnyObject
  var isEvented : Bool = false
  var event : AnyObject
  override func traceOutput() -> NSString {
    var out : String = ""
    if value is String {
      out = "{\"timestamp\":\(timestamp),\"name\":\"\(name)\",\"value\":\"\(value)\""
    } else {
      out = "{\"timestamp\":\(timestamp),\"name\":\"\(name)\",\"value\":\(value)"
    }
    if isEvented {
      if event is String {
        out.appendContentsOf(",\"event\":\"\(event)\"")
      } else {
        out.appendContentsOf(",\"event\":\(event)")
      }
    }
    out.appendContentsOf("}")
    return out
  }
}


class VehicleCommandResponse : VehicleBaseMessage {
  override init() {
    super.init()
    type = .CommandResponse
  }
  var command_response : NSString = ""
  var message : NSString = ""
  var status : Bool = false
  override func traceOutput() -> NSString {
    return "{\"timestamp\":\(timestamp),\"command_response\":\"\(command_response)\",\"message\":\"\(message)\",\"status\":\(status)}"
  }
}



class VehicleDiagnosticRequest : VehicleBaseMessage {
  override init() {
    super.init()
    type = .DiagnosticRequest
  }
  var bus : NSInteger = 0
  var message_id : NSInteger = 0
  var mode : NSInteger = 0
  var pid : NSInteger = 0
  var payload : NSString = ""
  var name : NSString = ""
  var multiple_responses : Bool = false
  var frequency : NSInteger = 0
  var decoded_type : NSString = ""
}



class VehicleDiagnosticResponse : VehicleBaseMessage {
  override init() {
    super.init()
    type = .DiagnosticResponse
  }
  var bus : NSInteger = 0
  var message_id : NSInteger = 0
  var mode : NSInteger = 0
  var pid : NSInteger = 0
  var success : Bool = false
  var negative_response_code : NSInteger = 0
  var payload : NSString = ""
  var value : NSInteger = 0
}


class VehicleCanResponse : VehicleBaseMessage {
  override init() {
    super.init()
    type = .CanResponse
  }
  var bus : NSInteger = 0
  var id : NSInteger = 0
  var data : NSString = ""
  var format : NSString = "standard"
}




protocol TargetAction {
  func performAction(rsp:NSDictionary)
  func returnKey() -> NSString
}

struct TargetActionWrapper<T: AnyObject> : TargetAction {
  var key : NSString
  weak var target: T?
  let action: (T) -> (NSDictionary) -> ()
  
  func performAction(rsp:NSDictionary) -> () {
    if let t = target {
      action(t)(rsp)
    }
  }
  func returnKey() -> NSString {
    return key
  }
}



class VehicleManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

  
  
  // MARK : Singleton Init
  
  static let sharedInstance: VehicleManager = {
    let instance = VehicleManager()
    // TODO do we want to autoconnect?
    // probably not because the client app will need to 
    // setup delegates and such
    // instance.connect()
    //////////////////
    return instance
  }()
  private override init() {
  }
  
  
  
  // MARK : Class Vars

  private var centralManager: CBCentralManager!
  private var openXCPeripheral: CBPeripheral!
  private var openXCService: CBService!
  private var openXCNotifyChar: CBCharacteristic!
  private var openXCWriteChar: CBCharacteristic!

  private var managerDebug : Bool = false
  private var managerCallback: TargetAction?
  
  private var BLERxDataBuffer: NSMutableData! = NSMutableData()
  
  private var BLETxDataBuffer: NSMutableArray! = NSMutableArray()
  private var BLETxWriteCount: Int = 0
  private var BLETxSendToken: Int = 0
  
  private var BLETxCommandCallback = [TargetAction]()
  private var BLETxCommandToken = [String]()

  private var measurementCallbacks = [NSString:TargetAction]()
  private var defaultMeasurementCallback : TargetAction?

  private var traceFileEnabled: Bool = false
  private var traceFileName: NSString = ""
  

  private var connectionState: VehicleManagerConnectionState! = .NotConnected

  private var latestVehicleMeasurements: NSMutableDictionary! = NSMutableDictionary()
  
  private var registeredCallbacks: NSMutableDictionary! = NSMutableDictionary()
  
  
  
  
  // MARK : Class Defines
  
  enum VehicleManagerConnectionState: Int {
    case NotConnected=0
    case ConnectionInProgress=1
    case Connected=2
  }


  
  
  
  
  // MARK : Class Functions
  
  func setManagerCallbackTarget<T: AnyObject>(target: T, action: (T) -> (NSDictionary) -> ()) {
    managerCallback = TargetActionWrapper(key:"", target: target, action: action)
  }
  
  func setManagerDebug(on:Bool) {
    managerDebug = on
  }
  
  private func vmlog(strings:Any...) {
    if managerDebug {
      for string in strings {
        print(string,terminator:"")
      }
      print("")
    }
  }
  
  
  func connect() {
    // TODO allow VI to be chosen from a list
    
    // TODO handle already connected!
    if connectionState != .NotConnected {
      vmlog("VehicleManager already connected! Sorry!")
      return
    }
    
    let cbqueue: dispatch_queue_t = dispatch_queue_create("CBQ", DISPATCH_QUEUE_SERIAL)

    
    vmlog("VehicleManager connect started")
    connectionState = .ConnectionInProgress
    openXCPeripheral=nil
    centralManager = CBCentralManager(delegate: self, queue: cbqueue, options:nil)
    
  }
  
  
  
  func enableTraceFileSink(filename:NSString) -> Bool {
    
    if let fs : Bool? = NSBundle.mainBundle().infoDictionary?["UIFileSharingEnabled"] as? Bool {
      if fs == true {
        vmlog("file sharing ok!")
      } else {
        vmlog("file sharing false!")
        return false
      }
    } else {
      vmlog("no file sharing key!")
      return false
    }

    traceFileEnabled = true
    traceFileName = filename
  
    
    if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
                                                     NSSearchPathDomainMask.AllDomainsMask, true).first {
      
      let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(traceFileName as String).path!

      vmlog("checking for file")
      if NSFileManager.defaultManager().fileExistsAtPath(path) {
        vmlog("file detected")
        do {
          try NSFileManager.defaultManager().removeItemAtPath(path)
          vmlog("file deleted")
        } catch {
          vmlog("could not delete file")
        }
      }
    }

    
    
    return true
    
  }
  
  
  func disableTraceFileSink() {
  
    traceFileEnabled = false
    
  }
  
  
  
  func getLatest(key:NSString) -> VehicleMeasurementResponse {
    if let entry = latestVehicleMeasurements[key] {
     return entry as! VehicleMeasurementResponse
    }
    return VehicleMeasurementResponse()
  }
  
  
  
  func addMeasurementTarget<T: AnyObject>(key: NSString, target: T, action: (T) -> (NSDictionary) -> ()) {
    measurementCallbacks[key] = TargetActionWrapper(key:key, target: target, action: action)
  }
  
  func clearMeasurementTarget(key: NSString) {
    measurementCallbacks.removeValueForKey(key)
  }
  
  func setMeasurementDefaultTarget<T: AnyObject>(target: T, action: (T) -> (NSDictionary) -> ()) {
    defaultMeasurementCallback = TargetActionWrapper(key:"", target: target, action: action)
  }
  
  func clearMeasurementDefaultTarget() {
    defaultMeasurementCallback = TargetActionWrapper(key: "", target: VehicleManager.sharedInstance, action: VehicleManager.CallbackNull)
  }
  
  
  
  
  func sendCommand(cmd:VehicleCommandType) {
    vmlog("in sendCommand")

    
    BLETxSendToken += 1
    let key : String = String(BLETxSendToken)
    let act : TargetAction = TargetActionWrapper(key: "", target: VehicleManager.sharedInstance, action: VehicleManager.CallbackNull)
    BLETxCommandCallback.append(act)
    BLETxCommandToken.append(key)
    
    sendCommandCommon(cmd)
    
  }
  
  func sendCommand<T: AnyObject>(cmd:VehicleCommandType, target: T, action: (T) -> (NSDictionary) -> ()) -> String {
    vmlog("in sendCommand:target")
    
    BLETxSendToken += 1
    let key : String = String(BLETxSendToken)
    let act : TargetAction = TargetActionWrapper(key:key, target: target, action: action)
    BLETxCommandCallback.append(act)
    BLETxCommandToken.append(key)

    sendCommandCommon(cmd)
    
    return key
    
  }
  
  
  
  func sendDiagReq(cmd:VehicleDiagnosticRequest) -> String {
    vmlog("in sendDiagReq")
    
    BLETxSendToken += 1
    let key : String = String(BLETxSendToken)
    let act : TargetAction = TargetActionWrapper(key: "", target: VehicleManager.sharedInstance, action: VehicleManager.CallbackNull)
    BLETxCommandCallback.append(act)
    BLETxCommandToken.append(key)

    sendDiagCommon(cmd)
    
    return key
    
  }
  
  func sendDiagReq<T: AnyObject>(cmd:VehicleDiagnosticRequest, target: T, action: (T) -> (NSDictionary) -> ()) -> String {
    vmlog("in sendDiagReq:target")
    
    BLETxSendToken += 1
    let key : String = String(BLETxSendToken)
    let act : TargetAction = TargetActionWrapper(key:key, target: target, action: action)
    BLETxCommandCallback.append(act)
    BLETxCommandToken.append(key)
    
    sendDiagCommon(cmd)
    
    return key
    
  }

  
  
  
  
  
  
  
  ////////////////
  // private functions
  
  
  private func sendCommandCommon(cmd:VehicleCommandType) {
    vmlog("in sendCommandCommon")

    var doSend = true
    if BLETxDataBuffer.count == 0 {
      doSend = true
    }
    
    if (cmd == .version || cmd == .device_id) {
      let cmd = "{\"command\":\"\(cmd.rawValue)\"}\0"
      BLETxDataBuffer.addObject(cmd.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
    }
    

    if doSend {
      BLESendFunction()
    }
    
    // wait for BLE acknowledgement
    while (BLETxWriteCount>0) {
      NSThread.sleepForTimeInterval(0.05)
    }
  }
  
  
  private func sendDiagCommon(cmd:VehicleDiagnosticRequest) {
    vmlog("in sendDiagCommon")
    
    var doSend = true
    if BLETxDataBuffer.count == 0 {
      doSend = true
    }
    
    let cmdjson = "{\"command\":\"diagnostic_request\",\"action\":\"add\",\"diagnostic_request\":{\"bus\":1,\"message_id\":1234,\"mode\":1,\"pid\":5}}\0"
    BLETxDataBuffer.addObject(cmdjson.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
    
    if doSend {
      BLESendFunction()
    }
    
    // wait for BLE acknowledgement
    while (BLETxWriteCount>0) {
      NSThread.sleepForTimeInterval(0.05)
    }
  
  }
  
  
  
  private func CallbackNull(o:AnyObject) {
//    vmlog("in CallbackNull")
  }
  
  
  private func BLESendFunction() {
    
    vmlog("in BLESendFunction")
    
    var sendBytes: NSData
    
//    vmlog (BLETxDataBuffer)
    
    if BLETxDataBuffer.count == 0 {
      return
    }
    
    var cmdToSend : NSMutableData = BLETxDataBuffer[0] as! NSMutableData
    BLETxDataBuffer.removeObjectAtIndex(0)
    
    let rangedata = NSMakeRange(0, 20)
    while cmdToSend.length > 0 {
      if (cmdToSend.length<=20) {
        sendBytes = cmdToSend
        cmdToSend = NSMutableData()
      } else {
        sendBytes = cmdToSend.subdataWithRange(rangedata)
        
        let leftdata = NSMakeRange(20,cmdToSend.length-20)
        cmdToSend = NSMutableData(data: cmdToSend.subdataWithRange(leftdata))
      }
      
      openXCPeripheral.writeValue(sendBytes, forCharacteristic: openXCWriteChar, type: CBCharacteristicWriteType.WithResponse)

      BLETxWriteCount += 1
//      vmlog("sent:",sendBytes)
    }
    
    

  }
  
  
  
  // MARK : Core Bluetooth Manager
  
  func centralManagerDidUpdateState(central: CBCentralManager) {
    vmlog("in centralManagerDidUpdateState:")
    if central.state == .PoweredOff {
      vmlog(" PoweredOff")
    } else if central.state == .PoweredOn {
      vmlog(" PoweredOn")
    } else {
      vmlog(" Other")
    }
    
    if central.state == CBCentralManagerState.PoweredOn && connectionState == .ConnectionInProgress {
      centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }

    
  }
  
  
  func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
    vmlog("in centralManager:didDiscover")
    
    if openXCPeripheral == nil {
      vmlog("FOUND:")
      vmlog(peripheral.name)
      vmlog(advertisementData["kCBAdvDataLocalName"])
      // TODO look at advData, or just either possible name, confirm with Ford
      if peripheral.name=="OpenXC_C5_BTLE" {
        openXCPeripheral = peripheral
        openXCPeripheral.delegate = self
        centralManager.connectPeripheral(openXCPeripheral, options:nil)
      }
      if peripheral.name=="CrossChasm" {
        openXCPeripheral = peripheral
        openXCPeripheral.delegate = self
        centralManager.connectPeripheral(openXCPeripheral, options:nil)
      }
      if let act = managerCallback {
        act.performAction(["status":"C5DETECTED"] as NSDictionary)
      }

    }
  }
  
  func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
    vmlog("in centralManager:didConnectPeripheral:")
    vmlog(peripheral.name!)
    connectionState = .Connected
    peripheral.discoverServices(nil)
    if let act = managerCallback {
      act.performAction(["status":"C5CONNECTED"] as NSDictionary)
    }
  }
  
  
  func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
    vmlog("in centralManager:didFailToConnectPeripheral:")
    vmlog(peripheral.name!)
  }
  
  
  func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
    vmlog("in centralManager:willRestoreState")
  }
  
  
  func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
    vmlog("in centralManager:didDisconnectPeripheral:")
    vmlog(peripheral.name!)
    
    
    // just reconnect for now
    if peripheral.name=="OpenXC_C5_BTLE" {
      centralManager.connectPeripheral(openXCPeripheral, options:nil)
    }
    if peripheral.name=="CrossChasm" {
      centralManager.connectPeripheral(openXCPeripheral, options:nil)
    }

    if let act = managerCallback {
      act.performAction(["status":"C5DISCONNECT"] as NSDictionary)
    }

  }
  
  
  
  // MARK : Peripheral Delgate Function
  
  func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
    vmlog("in peripheral:didDiscoverServices")
    if peripheral != openXCPeripheral {
      vmlog("peripheral error!")
      return
    }
    
    for service in peripheral.services! {
      vmlog(" - Found service : ",service.UUID)
      
      if service.UUID.UUIDString == "6800D38B-423D-4BDB-BA05-C9276D8453E1" {
        vmlog("   OPENXC_MAIN_SERVICE DETECTED")
        openXCService = service
        openXCPeripheral.discoverCharacteristics(nil, forService:service)
        if let act = managerCallback {
          act.performAction(["status":"C5SERVICEFOUND"] as NSDictionary)
        }
      }
      
    }
  }
  
  
  func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
    vmlog("in peripheral:didDiscoverCharacteristicsForService")
    if peripheral != openXCPeripheral {
      vmlog("peripheral error!")
      return
    }
    if service != openXCService {
      vmlog("service error!")
      return
    }
    
    for characteristic in service.characteristics! {
      vmlog(" - Found characteristic : ",characteristic.UUID)
      if characteristic.UUID.UUIDString == "6800D38B-5262-11E5-885D-FEFF819CDCE3" {
        openXCNotifyChar = characteristic
        peripheral.setNotifyValue(true, forCharacteristic:characteristic)
        openXCPeripheral.discoverDescriptorsForCharacteristic(characteristic)
        if let act = managerCallback {
          act.performAction(["status":"C5NOTIFYON"] as NSDictionary)
        }
      }
      if characteristic.UUID.UUIDString == "6800D38B-5262-11E5-885D-FEFF819CDCE2" {
        openXCWriteChar = characteristic
        openXCPeripheral.discoverDescriptorsForCharacteristic(characteristic)
        if let act = managerCallback {
          act.performAction(["status":"C5WRITEON"] as NSDictionary)
        }
      }
    }
    
  }
  
  
  func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    // vmlog("in peripheral:didUpdateValueForCharacteristic")
    
    let data = characteristic.value!
    
    if data.length > 0 {
      BLERxDataBuffer.appendData(data)
    }
    
    BLERxDataParser()
    
    
  }
  
  
  func BLERxDataParser() {
    
    
    // JSON decoding
    // TODO if protbuf?
    ////////////////
    
    let sepdata = NSData(bytes: [0x00] as [UInt8], length: 1)
    let rangedata = NSMakeRange(0, BLERxDataBuffer.length)
    let foundRange = BLERxDataBuffer.rangeOfData(sepdata, options:[], range:rangedata)
    
    let data_chunk : NSMutableData = NSMutableData()
    let data_left : NSMutableData = NSMutableData()
    
    if foundRange.location != NSNotFound {
      data_chunk.appendData(BLERxDataBuffer.subdataWithRange(NSMakeRange(0,foundRange.location)))
      /*
       vmlog("buff",BLEDataBuffer)
       vmlog("chunk",data_chunk)
       vmlog("buf len:",BLEDataBuffer.length)
       vmlog("foundRange loc:",foundRange.location," len:",foundRange.length)
       let start = foundRange.location+1
       let len = BLEDataBuffer.length-foundRange.location
       vmlog("start:",start," len:",len)
       */
      if BLERxDataBuffer.length-1 > foundRange.location {
        data_left.appendData(BLERxDataBuffer.subdataWithRange(NSMakeRange(foundRange.location+1,BLERxDataBuffer.length-foundRange.location-1)))
        BLERxDataBuffer = data_left
      } else {
        BLERxDataBuffer = NSMutableData()
      }
      let str = String(data: data_chunk,encoding: NSUTF8StringEncoding)
      if str != nil {
//        vmlog(str!)
      } else {
        vmlog("not UTF8")
      }
    }


    // TODO error handling!
    if data_chunk.length > 0 {
      do {
        let json = try NSJSONSerialization.JSONObjectWithData(data_chunk, options: .MutableContainers)
        let str = String(data: data_chunk,encoding: NSUTF8StringEncoding)
        
        var decodedMessage : VehicleBaseMessage = VehicleBaseMessage()
        
        
        var timestamp : NSInteger = 0
        if json["timestamp"] != nil {
          timestamp = json["timestamp"] as! NSInteger
          decodedMessage.timestamp = timestamp
        }
        
        
        
        // evented measurement rsp
        ///////////////////
        if let event = json["event"] as? NSString {
          let name = json["name"] as! NSString
          let value : AnyObject = json["value"] ?? NSNull()
          
          let rsp : VehicleMeasurementResponse = VehicleMeasurementResponse()
          rsp.timestamp = timestamp
          rsp.name = name
          rsp.value = value
          rsp.isEvented = true
          rsp.event = event
          decodedMessage = rsp


          var found=false
          for key in measurementCallbacks.keys {
            let act = measurementCallbacks[key]
            if act!.returnKey() == name {
              found=true
              act!.performAction(["vehiclemessage":rsp] as NSDictionary)
            }
          }
          if !found {
            let act = defaultMeasurementCallback
            act!.performAction(["vehiclemessage":rsp] as NSDictionary)
          }
        }
        ///////////////////////
        


        // measurement rsp
        ///////////////////
        else if let name = json["name"] as? NSString {
          let value : AnyObject = json["value"] ?? NSNull()
          
          let rsp : VehicleMeasurementResponse = VehicleMeasurementResponse()
          rsp.value = value
          rsp.timestamp = timestamp
          rsp.name = name
          decodedMessage = rsp

          
          latestVehicleMeasurements.setValue(rsp, forKey:name as String)

          var found=false
          for key in measurementCallbacks.keys {
            let act = measurementCallbacks[key]
            if act!.returnKey() == name {
              found=true
              act!.performAction(["vehiclemessage":rsp] as NSDictionary)
            }
          }
          if !found {
            if let act = defaultMeasurementCallback {
              act.performAction(["vehiclemessage":rsp] as NSDictionary)
            }
          }
        }
        ///////////////////////
        
        
        
        // command rsp
        ///////////////////
        else if let cmd_rsp = json["command_response"] as? NSString {
          
          var message : NSString = ""
          if let messageX = json["message"] as? NSString {
            message = messageX
          }
          
          var status : Bool = false
          if let statusX = json["status"] as? Bool {
            status = statusX
          }

          let rsp : VehicleCommandResponse = VehicleCommandResponse()
          rsp.timestamp = timestamp
          rsp.message = message
          rsp.command_response = cmd_rsp
          rsp.status = status
          decodedMessage = rsp
          
          let ta : TargetAction = BLETxCommandCallback.removeFirst()
          let s : String = BLETxCommandToken.removeFirst()
          ta.performAction(["vehiclemessage":rsp,"key":s] as NSDictionary)
          
        }
        //////////////////////////
        
          
          
          
          
        // diag rsp message
        ///////////////////
        else if let message_id = json["message_id"] as? NSInteger {
          
          var bus : NSInteger = 0
          if let busX = json["bus"] as? NSInteger {
            bus = busX
          }
          var status : Bool = false
          if let statusX = json["status"] as? Bool {
            status = statusX
          }
          var payload : NSString = ""
          if let payloadX = json["payload"] as? NSString {
            payload = payloadX
          }
          
          vmlog("msg rsp bus:\(bus) message_id:\(message_id) status:\(status) payload:\(payload)")
          
          // TODO get handlers in here
          
        }
          
          

          
        // CAN bus message
        ///////////////////
        else if let id = json["id"] as? NSInteger {
          
          var bus : NSInteger = 0
          if let busX = json["bus"] as? NSInteger {
            bus = busX
          }
          var data : NSString = ""
          if let dataX = json["data"] as? NSString {
            data = dataX
          }
          
          vmlog("CAN bus:\(bus) status:\(id) payload:\(data)")
          
          // TODO get handlers in here
          
        }
          
        
        ////////////
        
        
        
        if traceFileEnabled {
          traceFileWriter(str!)
        }

        
        
      } catch {
        vmlog("bad json")
        // bad json!
      }

      
    }
    
  }
  
  
  
  func traceFileWriter (message:VehicleBaseMessage) {
    
    // TODO if we want to be able to trace directly from a vehicleMessage,
    // this is where to do it
    // Each class of vehicle message has it's own trace output method
    vmlog(message.traceOutput())
    
  }
  
  func traceFileWriter (string:String) {
    
    // this version of the method outputs a direct string
    // make sure there are no LFCR in the string, because they're added here automatically
    vmlog("trace:",string)
    
    var traceOut = string
    
    traceOut.appendContentsOf("\n");
    
    if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
                                                     NSSearchPathDomainMask.AllDomainsMask, true).first {
      let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(traceFileName as String)
      
      //writing
      do {
        let data = traceOut.dataUsingEncoding(NSUTF8StringEncoding)!
        if let fileHandle = try? NSFileHandle(forWritingToURL: path) {
          defer {
            fileHandle.closeFile()
          }
          fileHandle.seekToEndOfFile()
          fileHandle.writeData(data)
        }
        else {
          try data.writeToURL(path, options: .DataWritingAtomic)
        }
      }
      catch {
        // TODO error handling here
      }
      
    }

    
  }
  

  
  
  func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    vmlog("in peripheral:didDiscoverDescriptorsForCharacteristic")
    vmlog(characteristic.descriptors)
  }
  
  
  func peripheral(peripheral: CBPeripheral, didUpdateValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
    vmlog("in peripheral:didUpdateValueForDescriptor")
  }
  
  
  func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    vmlog("in peripheral:didUpdateNotificationStateForCharacteristic")
  }
  
  
  func peripheral(peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
    vmlog("in peripheral:didModifyServices")
  }
  
  
  func peripheral(peripheral: CBPeripheral, didDiscoverIncludedServicesForService service: CBService, error: NSError?) {
    vmlog("in peripheral:didDiscoverIncludedServicesForService")
  }
  
  
  func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    vmlog("in peripheral:didWriteValueForCharacteristic")
    if error != nil {
      vmlog("error")
      vmlog(error!.localizedDescription)
    } else {
      BLETxWriteCount -= 1
    }
  }
  
  
  func peripheral(peripheral: CBPeripheral, didWriteValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
    vmlog("in peripheral:didWriteValueForDescriptor")
  }
  
  
  func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?) {
    vmlog("in peripheral:didReadRSSI")
  }
  

  
  

}