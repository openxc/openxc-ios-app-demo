//
//  SendCanViewController.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-08-04.
//  Copyright © 2016 Bug Labs. All rights reserved.
//

import UIKit
import openXCiOSFramework

class SendCanViewController: UIViewController, UITextFieldDelegate {

  // UI outlets
  @IBOutlet weak var busField: UITextField!
  @IBOutlet weak var idField: UITextField!
  @IBOutlet weak var dataField: UITextField!
  
  @IBOutlet weak var lastReq: UILabel!

  var vm: VehicleManager!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // grab VM instance
    vm = VehicleManager.sharedInstance

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  
  
  // text view delegate to clear keyboard
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder();
    return true;
  }
  
  
  // CAN send button hit
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
    
    // create an empty CAN request
    let cmd = VehicleCanRequest()
    
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
        cmd.id = midInt
      } else {
        lastReq.text = "Invalid command : message_id should be hex number (with no leading 0x)"
        return
      }
    } else {
      lastReq.text = "Invalid command : need a message_id"
      return
    }
    print("mid is ",cmd.id)
    
    // check that the payload field is valid
    if let payld = dataField.text as String? {
      if payld=="" {
        lastReq.text = "Invalid command : need a payload"
        return
      }
      if (Int(payld,radix:16) as NSInteger?) != nil {
        cmd.data = dataField.text!
        if (cmd.data.length % 2) == 1 {
          cmd.data = "0" + dataField.text!
        }
      } else {
        lastReq.text = "Invalid command : payload should be hex number (with no leading 0x)"
        return
      }
    } else {
      lastReq.text = "Invalid command : need a payload"
      return
    }
    print("payload is ",cmd.data)
    
    // send the CAN request
    vm.sendCanReq(cmd)
    
    // update the last request sent label
    lastReq.text = "bus:"+String(cmd.bus)+" id:0x"+idField.text!+" payload:0x"+String(cmd.data)
    
  }

  
  

}

