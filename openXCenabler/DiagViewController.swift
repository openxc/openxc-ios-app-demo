//
//  DiagViewController.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-08-04.
//  Copyright (c) 2016 Ford Motor Company Licensed under the BSD license.
//

import UIKit
import openXCiOSFramework

class DiagViewController: UIViewController, UITextFieldDelegate {

  // UI outlets
  @IBOutlet weak var busField: UITextField!
  @IBOutlet weak var idField: UITextField!
  @IBOutlet weak var modeField: UITextField!
  @IBOutlet weak var pidField: UITextField!
  
  @IBOutlet weak var lastReq: UILabel!
  @IBOutlet weak var rspText: UITextView!
  
  var vm: VehicleManager!

  // string array holding last X diag responses
  var rspStrings : [String] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // grab VM instance
    vm = VehicleManager.sharedInstance

    // set default diag response target
    vm.setDiagnosticDefaultTarget(self, action: DiagViewController.default_diag_rsp)

  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  
  func default_diag_rsp(rsp:NSDictionary) {
    // extract the diag resp message
    let vr = rsp.objectForKey("vehiclemessage") as! VehicleDiagnosticResponse
    
    print("diag_rsp -  success:",vr.success)
    
    // create the string we want to show in the received messages UI
    var newTxt = "bus:"+vr.bus.description+" id:0x"+String(format:"%x",vr.message_id)+" mode:0x"+String(format:"%x",vr.mode)
    if vr.pid != nil {
      newTxt = newTxt+" pid:0x"+String(format:"%x",vr.pid!)
    }
    newTxt = newTxt+" success:"+vr.success.description
    if vr.value != nil {
      newTxt = newTxt+" value:"+vr.value!.description
    } else {
      newTxt = newTxt+" payload:"+vr.payload.description
    }

    // save only the 5 response strings
    if rspStrings.count>5 {
      rspStrings.removeFirst()
    }
    // append the new string
    rspStrings.append(newTxt)

    // reload the label with the update string list
    dispatch_async(dispatch_get_main_queue()) {
      self.rspText.text = self.rspStrings.joinWithSeparator("\n")
    }

  }
  
  
  
  // text view delegate to clear keyboard
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder();
    return true;
  }
  
  
  // diag send button hit
  @IBAction func sendHit(sender: AnyObject) {

    // hide keyboard when the send button is hit
    for textField in self.view.subviews where textField is UITextField {
      textField.resignFirstResponder()
    }

    // if the VM isn't operational, don't send anything
    if vm.connectionState != VehicleManagerConnectionState.Operational {
      lastReq.text = "Not connected to VI"
      return
    }
    
    // create an empty diag request
    let cmd = VehicleDiagnosticRequest()
    
    // check that the bus field is valid
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
    
    // check that the msg id field is valid
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
    
    // check that the mode field is valid
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
    
    // check that the pid field is valid (or empty)
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
    
    // send the diag request
    vm.sendDiagReq(cmd)
    
    // update the last request sent label
    lastReq.text = "bus:"+String(cmd.bus)+" id:0x"+idField.text!+" mode:0x"+modeField.text!
    if cmd.pid != nil {
      lastReq.text = lastReq.text!+" pid:0x"+pidField.text!
    }
    
  }

}

