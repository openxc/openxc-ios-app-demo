//
//  StatusViewController.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-08-04.
//  Copyright © 2016 Bug Labs. All rights reserved.
//

import UIKit
import openXCiOSFramework

class StatusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  // UI Labels
  @IBOutlet weak var actConLab: UILabel!
  @IBOutlet weak var msgRvcdLab: UILabel!
  @IBOutlet weak var verLab: UILabel!
  @IBOutlet weak var devidLab: UILabel!
  
  // scan/connect button
  @IBOutlet weak var searchBtn: UIButton!
  
  // table for holding/showing discovered VIs
  @IBOutlet weak var peripheralTable: UITableView!
  
  // the VM
  var vm: VehicleManager!
  
  // timer for UI counter updates
  var timer: NSTimer!
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // change tab bar text colors
    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.grayColor()], forState:.Normal)
    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Selected)

  
    // instantiate the VM
    print("loading VehicleManager")
    vm = VehicleManager.sharedInstance
   
    
    // setup the status callback, and the command response callback
    vm.setManagerCallbackTarget(self, action: StatusViewController.manager_status_updates)
    vm.setCommandDefaultTarget(self, action: StatusViewController.handle_cmd_response)
    // turn on debug output
    vm.setManagerDebug(true)
    
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  // this function is called when the scan button is hit
  @IBAction func searchHit(sender: UIButton) {
    
    // make sure we're not already connected first
    if (vm.connectionState==VehicleManagerConnectionState.NotConnected) {
      
      // start a timer to update the UI with the total received messages
      timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: #selector(StatusViewController.msgRxdUpdate(_:)), userInfo: nil, repeats: true)
      
      // check to see if the config is set for autoconnect mode
      vm.setAutoconnect(false)
      if NSUserDefaults.standardUserDefaults().boolForKey("autoConnectOn") {
        vm.setAutoconnect(true)
      }
      
      // check to see if a trace input file has been set up
      if NSUserDefaults.standardUserDefaults().boolForKey("traceInputOn") {
        if let name = NSUserDefaults.standardUserDefaults().valueForKey("traceInputFilename") as? NSString {
          vm.enableTraceFileSource(name,speed:100)
        }
      }

      // check to see if a trace output file has been configured
      if NSUserDefaults.standardUserDefaults().boolForKey("traceOutputOn") {
        if let name = NSUserDefaults.standardUserDefaults().valueForKey("traceOutputFilename") as? NSString {
          vm.enableTraceFileSink(name)
        }
      }

      // start the VI scan
      vm.scan()

      // update the UI
      dispatch_async(dispatch_get_main_queue()) {
        self.actConLab.text = "❓"
        self.searchBtn.setTitle("SCANNING",forState:UIControlState.Normal)
      }
      

    }
    
  }
  
  
  // this function receives all status updates from the VM
  func manager_status_updates(rsp:NSDictionary) {
   
    // extract the status message
    let status = rsp.objectForKey("status") as! Int
    let msg = VehicleManagerStatusMessage(rawValue: status)
    print("VM status : ",msg!)
    
    
    // show/reload the table showing detected VIs
    if msg==VehicleManagerStatusMessage.C5DETECTED {
      dispatch_async(dispatch_get_main_queue()) {
        self.peripheralTable.hidden = false
        self.peripheralTable.reloadData()
      }
    }
    
    // update the UI showing connected VI
    if msg==VehicleManagerStatusMessage.C5CONNECTED {
      dispatch_async(dispatch_get_main_queue()) {
        self.peripheralTable.hidden = true
        self.actConLab.text = "✅"
        self.searchBtn.setTitle("BTLE VI CONNECTED",forState:UIControlState.Normal)
      }
    }
    
    // update the UI showing disconnected VI
    if msg==VehicleManagerStatusMessage.C5DISCONNECTED {
      dispatch_async(dispatch_get_main_queue()) {
        self.actConLab.text = "---"
        self.msgRvcdLab.text = "---"
        self.verLab.text = "---"
        self.devidLab.text = "---"
        self.searchBtn.setTitle("SEARCH FOR BTLE VI",forState:UIControlState.Normal)
      }
    }
    
    // when we see that notify is on, we can send 2 command requests
    // for version and device id, one after the other
    if msg==VehicleManagerStatusMessage.C5NOTIFYON {
     
      let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
      dispatch_after(delayTime, dispatch_get_main_queue()) {
        print("sending version cmd")
        let cm = VehicleCommandRequest()
        cm.command = .version
        self.vm.sendCommand(cm)
      }
      
      let delayTime2 = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
      dispatch_after(delayTime2, dispatch_get_main_queue()) {
        print("sending devid cmd")
        let cm = VehicleCommandRequest()
        cm.command = .device_id
        self.vm.sendCommand(cm)
      }
      
      
    }
    
  }
  
  // this function handles all command responses
  func handle_cmd_response(rsp:NSDictionary) {
    // extract the command response message
    let cr = rsp.objectForKey("vehiclemessage") as! VehicleCommandResponse
    print("cmd response : \(cr.command_response)")
    
    // update the UI depending on the command type
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

  
  // this function is called by the timer, it updates the UI
  func msgRxdUpdate(t:NSTimer) {
    if vm.connectionState==VehicleManagerConnectionState.Operational {
//      print("VM is receiving data from VI!")
//      print("So far we've had ",vm.messageCount," messages")
      dispatch_async(dispatch_get_main_queue()) {
        self.msgRvcdLab.text = String(self.vm.messageCount)
      }
    }
  }

  
  
  
  // table view delegate functions
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // how many VIs have been discovered
    return vm.discoveredVI().count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    // grab a cell
    var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell?
    if (cell == nil) {
      cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
    }
    
    // grab the name of the VI for this row
    let p = vm.discoveredVI()[indexPath.row] as String
    
    // display the name of the VI
    cell!.textLabel?.text = p
    cell!.textLabel?.font = UIFont(name:"Arial", size: 14.0)
    cell!.textLabel?.textColor = UIColor.lightGrayColor()
    
    return cell!
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    // if a row is selected, connect to the selected VI
    let p = vm.discoveredVI()[indexPath.row] as String
    vm.connect(p)

  }
  

  
  
  
  
  
}

