//
//  ViewController.swift
//  openXC-iOS-basic
//
//  Created by Tim Buick on 2016-07-01.
//  Copyright © 2016 Bug Labs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  // MARK : Properties

  @IBOutlet weak var es_lab: UILabel!
  @IBOutlet weak var bps_lab: UILabel!
  @IBOutlet weak var od_lab: UILabel!
  @IBOutlet weak var hs_lab: UILabel!
  @IBOutlet weak var cmd_lab: UILabel!
  @IBOutlet weak var default_lab: UILabel!
  
  
  // MARK : Actions

  @IBAction func sendVerCmd(sender: AnyObject) {
    let cmdcode = vm.sendCommand(.version, target: self, action: ViewController.handle_cmd_response)
    print("sent version cmd: code=\(cmdcode)")
  }
  @IBAction func sendDevCmd(sender: AnyObject) {
    let cmdcode = vm.sendCommand(.device_id, target: self, action: ViewController.handle_cmd_response)
    print("sent devid cmd: code=\(cmdcode)")
  }
  
  @IBAction func es_switch(sender: AnyObject) {
    let sw = sender as! UISwitch
    if sw.on {
      vm.addMeasurementTarget("engine_speed", target: self, action: ViewController.es_change)
    } else {
      vm.clearMeasurementTarget("engine_speed")
    }
  }
  
  @IBAction func bps_switch(sender: AnyObject) {
    let sw = sender as! UISwitch
    if sw.on {
      vm.addMeasurementTarget("brake_pedal_status", target: self, action: ViewController.bps_change)
    } else {
      vm.clearMeasurementTarget("brake_pedal_status")
    }
  }
  
  @IBAction func od_switch(sender: AnyObject) {
    let sw = sender as! UISwitch
    if sw.on {
      vm.addMeasurementTarget("odometer", target: self, action: ViewController.od_change)
    } else {
      vm.clearMeasurementTarget("odometer")
    }
  }
  
  @IBAction func hs_switch(sender: AnyObject) {
    let sw = sender as! UISwitch
    if sw.on {
      vm.addMeasurementTarget("headlamp_status", target: self, action: ViewController.hs_change)
    } else {
      vm.clearMeasurementTarget("headlamp_status")
    }
  }
  
  @IBAction func default_switch(sender: AnyObject) {
    let sw = sender as! UISwitch
    if sw.on {
      vm.setMeasurementDefaultTarget(self, action: ViewController.default_measurement_change)
    } else {
      vm.clearMeasurementDefaultTarget()
    }
  }
  
  
  // MARK : Class Vars

  
  var vm: VehicleManager!
  var defaultLabelStrings : [String] = []
  var cmdrspLabelStrings : [String] = []

  
  
  // MARK : overrides

  
  
  override func viewDidLoad() {
    super.viewDidLoad()

    print("loading VehicleManager")
    vm = VehicleManager.sharedInstance
    vm.setManagerCallbackTarget(self, action: ViewController.manager_status_updates)
    vm.setManagerDebug(true)
    vm.enableTraceFileSink("tracefile.txt")
    vm.connect()

    vm.setMeasurementDefaultTarget(self, action: ViewController.default_measurement_change)
    vm.addMeasurementTarget("engine_speed", target: self, action: ViewController.es_change)
    vm.addMeasurementTarget("brake_pedal_status", target: self, action: ViewController.bps_change)
    vm.addMeasurementTarget("odometer", target: self, action: ViewController.od_change)
    vm.addMeasurementTarget("headlamp_status", target: self, action: ViewController.hs_change)

  
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  
  
  // MARK : Class Funcs

  
  func manager_status_updates(rsp:NSDictionary) {
    let status = rsp.objectForKey("status") as! String
    print("VM status : ",status)
  }
  
  
  func default_measurement_change(rsp:NSDictionary) {
    let vr = rsp.objectForKey("vehiclemessage") as! VehicleMeasurementResponse
    
    if defaultLabelStrings.count>11 {
      defaultLabelStrings.removeFirst()
    }
    if vr.isEvented {
      defaultLabelStrings.append("\(vr.name) -- \(vr.value)")
      dispatch_async(dispatch_get_main_queue()) {
        self.default_lab.text = self.defaultLabelStrings.joinWithSeparator("\n")
      }
      print("default measurement msg (evented):",vr.name," -- ",vr.event," -- ",vr.value)
    } else {
      defaultLabelStrings.append("\(vr.name) -- \(vr.value)")
      dispatch_async(dispatch_get_main_queue()) {
        self.default_lab.text = self.defaultLabelStrings.joinWithSeparator("\n")
      }
      print("default measurement msg:",vr.name," -- ",vr.value)
    }
  }

  func es_change(rsp:NSDictionary) {
    let vr = rsp.objectForKey("vehiclemessage") as! VehicleMeasurementResponse
    print("es event:",vr.name," -- ",vr.value)
    dispatch_async(dispatch_get_main_queue()) {
      self.es_lab.text = vr.value.debugDescription
    }
  }

  func bps_change(rsp:NSDictionary) {
    let vr = rsp.objectForKey("vehiclemessage") as! VehicleMeasurementResponse
    print("bps event:",vr.name," -- ",vr.value)
    dispatch_async(dispatch_get_main_queue()) {
      self.bps_lab.text = vr.value.debugDescription
    }
  }
  
  func od_change(rsp:NSDictionary) {
    let vr = rsp.objectForKey("vehiclemessage") as! VehicleMeasurementResponse
    print("od event:",vr.name," -- ",vr.value)
    dispatch_async(dispatch_get_main_queue()) {
      self.od_lab.text = vr.value.debugDescription
    }
  }
  
  func hs_change(rsp:NSDictionary) {
    let vr = rsp.objectForKey("vehiclemessage") as! VehicleMeasurementResponse
    print("hs event:",vr.name," -- ",vr.value)
    dispatch_async(dispatch_get_main_queue()) {
      self.hs_lab.text = vr.value.debugDescription
    }
  }
  
  
  func handle_cmd_response(rsp:NSDictionary) {
    let cr = rsp.objectForKey("vehiclemessage") as! VehicleCommandResponse
    let code = rsp.objectForKey("key") as! String
    print("cmd response : \(code) : \(cr.command_response)")
    if cmdrspLabelStrings.count>5 {
      cmdrspLabelStrings.removeFirst()
    }
    cmdrspLabelStrings.append("\(cr.command_response) -- \(cr.message) -- \(cr.status)")
    dispatch_async(dispatch_get_main_queue()) {
      self.cmd_lab.text = self.cmdrspLabelStrings.joinWithSeparator("\n")
    }
  }
  
  
  
}

