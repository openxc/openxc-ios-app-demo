//
//  DiagViewController.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-08-04.
//  Copyright © 2016 Bug Labs. All rights reserved.
//

import UIKit
import openXCiOSFramework

class DiagViewController: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var busField: UITextField!
  @IBOutlet weak var idField: UITextField!
  @IBOutlet weak var modeField: UITextField!
  @IBOutlet weak var pidField: UITextField!
  
  @IBOutlet weak var lastReq: UILabel!
  @IBOutlet weak var rspText: UITextView!
  
  var vm: VehicleManager!

  var rspStrings : [String] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()

    vm = VehicleManager.sharedInstance
    vm.setDiagnosticDefaultTarget(self, action: DiagViewController.default_diag_rsp)

  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  
  func default_diag_rsp(rsp:NSDictionary) {
    let vr = rsp.objectForKey("vehiclemessage") as! VehicleDiagnosticResponse
    
    print("diag_rsp -  success:",vr.success)
    
    var newTxt = "bus:"+vr.bus.description+" id:0x"+String(format:"%x",vr.message_id)+" mode:0x"+String(format:"%x",vr.mode)
    if vr.pid != nil {
      newTxt = newTxt+" pid:0x"+String(format:"%x",vr.pid!)
    }
    newTxt = newTxt+" success:"+vr.success.description
    if vr.value != nil {
      newTxt = newTxt+" value:"+vr.value!.description
    } else {
      newTxt = newTxt+" payload:"+vr.payload
    }

    if rspStrings.count>5 {
      rspStrings.removeFirst()
    }
    rspStrings.append(newTxt)

    dispatch_async(dispatch_get_main_queue()) {
      self.rspText.text = self.rspStrings.joinWithSeparator("\n")
    }

  }
  
  
  
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder();
    return true;
  }
  
  
  @IBAction func sendHit(sender: AnyObject) {

    // hide keyboard
    for textField in self.view.subviews where textField is UITextField {
      textField.resignFirstResponder()
    }

    if vm.connectionState != VehicleManagerConnectionState.Operational {
      lastReq.text = "Not connected to VI"
      return
    }
    
    let cmd = VehicleDiagnosticRequest()
    
    if let bus = busField.text as String? {
      if bus=="" {
        lastReq.text = "Invalid command : need a bus"
        return
      }
      if let busInt = Int(bus) as NSInteger? {
        cmd.bus = busInt
      } else {
        lastReq.text = "Invalid command : bus should be a number"
        return
      }
    } else {
      lastReq.text = "Invalid command : need a bus"
      return
    }
    print("bus is ",cmd.bus)
    
    if let mid = idField.text as String? {
      if mid=="" {
        lastReq.text = "Invalid command : need a message_id"
        return
      }
      if let midInt = Int(mid,radix:16) as NSInteger? {
        cmd.message_id = midInt
      } else {
        lastReq.text = "Invalid command : message_id should be hex number (with no leading 0x)"
        return
      }
    } else {
      lastReq.text = "Invalid command : need a message_id"
      return
    }
    print("mid is ",cmd.message_id)
    
    
    if let mode = modeField.text as String? {
      if mode=="" {
        lastReq.text = "Invalid command : need a mode"
        return
      }
      if let modeInt = Int(mode,radix:16) as NSInteger? {
        cmd.mode = modeInt
      } else {
        lastReq.text = "Invalid command : mode should be hex number (with no leading 0x)"
        return
      }
    } else {
      lastReq.text = "Invalid command : need a mode"
      return
    }
    print("mode is ",cmd.mode)
    
    if let pid = pidField.text as String? {
      if (pid=="") {
        // this is ok, it's optional
      } else if let pidInt = Int(pid,radix:16) as NSInteger? {
        cmd.pid = pidInt
      } else {
        lastReq.text = "Invalid command : pid should be hex number (with no leading 0x)"
        return
      }
    } else {
    }
    if cmd.pid==nil {
      print ("pid is nil")
    } else {
      print("pid is ",cmd.pid)
    }
    
    
    self.vm.sendDiagReq(cmd)
    
  // temp test  cmd.mode=2
    
  // temp test  vm.sendDiagReq(cmd)

    lastReq.text = "bus:"+String(cmd.bus)+" id:0x"+idField.text!+" mode:0x"+modeField.text!
    if cmd.pid != nil {
      lastReq.text = lastReq.text!+" pid:0x"+pidField.text!
    }
    
  }

}

