//
//  StatusViewController.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-08-04.
//  Copyright © 2016 Bug Labs. All rights reserved.
//

import UIKit
import openXCiOSFramework

class StatusViewController: UIViewController {

  @IBOutlet weak var actConLab: UILabel!
  @IBOutlet weak var msgRvcdLab: UILabel!
  @IBOutlet weak var verLab: UILabel!
  @IBOutlet weak var devidLab: UILabel!
  
  @IBOutlet weak var searchBtn: UIButton!
  
  var vm: VehicleManager!
  var timer: NSTimer!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    
    // change tab bar text colors
    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.grayColor()], forState:.Normal)
    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Selected)

    
    print("loading VehicleManager")
    vm = VehicleManager.sharedInstance
   
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  @IBAction func searchHit(sender: UIButton) {
    
    if (vm.connectionState==VehicleManagerConnectionState.NotConnected) {
      
      timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: #selector(StatusViewController.msgRxdUpdate(_:)), userInfo: nil, repeats: true)
      
      vm.setManagerCallbackTarget(self, action: StatusViewController.manager_status_updates)
      vm.setManagerDebug(true)
      vm.connect()

    }
    
  }
  
  func manager_status_updates(rsp:NSDictionary) {
   
    
    let status = rsp.objectForKey("status") as! Int
    let msg = VehicleManagerStatusMessage(rawValue: status)
    print("VM status : ",msg!)
    
    if msg==VehicleManagerStatusMessage.C5CONNECTED {
      dispatch_async(dispatch_get_main_queue()) {
        self.actConLab.text = "✅"
        self.searchBtn.titleLabel?.text = "BTLE VI CONNECTED"
      }
    }
    if msg==VehicleManagerStatusMessage.C5DISCONNECTED {
      dispatch_async(dispatch_get_main_queue()) {
        self.actConLab.text = "---"
        self.msgRvcdLab.text = "---"
        self.verLab.text = "---"
        self.devidLab.text = "---"
        self.searchBtn.titleLabel?.text = "SEARCH FOR BTLE VI"
      }
    }
    
    if msg==VehicleManagerStatusMessage.C5NOTIFYON {
      
      let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
      dispatch_after(delayTime, dispatch_get_main_queue()) {
        print("sending version cmd")
        let cm = VehicleCommandRequest()
        cm.command = .version
        self.vm.sendCommand(cm, target: self, action: StatusViewController.handle_cmd_response)
      }
      
      let delayTime2 = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
      dispatch_after(delayTime2, dispatch_get_main_queue()) {
        print("sending devid cmd")
        let cm = VehicleCommandRequest()
        cm.command = .device_id
        self.vm.sendCommand(cm, target: self, action: StatusViewController.handle_cmd_response)
      }

      
      
    }
    
  }
  
  
  func handle_cmd_response(rsp:NSDictionary) {
    let cr = rsp.objectForKey("vehiclemessage") as! VehicleCommandResponse
    let code = rsp.objectForKey("key") as! String
    print("cmd response : \(code) : \(cr.command_response)")
    if cr.command_response.isEqualToString("version") {
      dispatch_async(dispatch_get_main_queue()) {
        self.verLab.text = cr.message as String
      }
    }
    if cr.command_response.isEqualToString("device_id") {
      dispatch_async(dispatch_get_main_queue()) {
        self.devidLab.text = cr.message as String
      }
    }
    
  }

  
  func msgRxdUpdate(t:NSTimer) {
    if vm.connectionState==VehicleManagerConnectionState.Operational {
//      print("VM is receiving data from VI!")
//      print("So far we've had ",vm.messageCount," messages")
      dispatch_async(dispatch_get_main_queue()) {
        self.msgRvcdLab.text = String(self.vm.messageCount)
      }
    }
  }

  
  
}

