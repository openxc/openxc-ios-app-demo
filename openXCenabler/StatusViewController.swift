//
//  StatusViewController.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-08-04.
//  Copyright (c) 2016 Ford Motor Company Licensed under the BSD license.
//

import UIKit
import openXCiOSFramework

// TODO: ToDo - Work on removing the warnings

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
  var timer: Timer!
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // change tab bar text colors
    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.gray], for:UIControlState())
    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for:.selected)

  
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
  @IBAction func searchHit(_ sender: UIButton) {
    
    // make sure we're not already connected first
    if (vm.connectionState==VehicleManagerConnectionState.notConnected) {
      
      // start a timer to update the UI with the total received messages
      timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(StatusViewController.msgRxdUpdate(_:)), userInfo: nil, repeats: true)
      
      // check to see if the config is set for autoconnect mode
      vm.setAutoconnect(false)
      if UserDefaults.standard.bool(forKey: "autoConnectOn") {
        vm.setAutoconnect(true)
      }
      
      // check to see if the config is set for protobuf mode
      vm.setProtobufMode(false)
      if UserDefaults.standard.bool(forKey: "protobufOn") {
        vm.setProtobufMode(true)
      }
      
      // check to see if a trace input file has been set up
      if UserDefaults.standard.bool(forKey: "traceInputOn") {
        if let name = UserDefaults.standard.value(forKey: "traceInputFilename") as? NSString {
          vm.enableTraceFileSource(name)
        }
      }

      // check to see if a trace output file has been configured
      if UserDefaults.standard.bool(forKey: "traceOutputOn") {
        if let name = UserDefaults.standard.value(forKey: "traceOutputFilename") as? NSString {
          vm.enableTraceFileSink(name)
        }
      }

      // start the VI scan
      vm.scan()

      // update the UI
      DispatchQueue.main.async {
        self.actConLab.text = "❓"
        self.searchBtn.setTitle("SCANNING",for:UIControlState())
      }
      

    }
    
  }
  
  
  // this function receives all status updates from the VM
  func manager_status_updates(_ rsp:NSDictionary) {
   
    // extract the status message
    let status = rsp.object(forKey: "status") as! Int
    let msg = VehicleManagerStatusMessage(rawValue: status)
    print("VM status : ",msg!)
    
    
    // show/reload the table showing detected VIs
    if msg==VehicleManagerStatusMessage.c5DETECTED {
      DispatchQueue.main.async {
        self.peripheralTable.isHidden = false
        self.peripheralTable.reloadData()
      }
    }
    
    // update the UI showing connected VI
    if msg==VehicleManagerStatusMessage.c5CONNECTED {
      DispatchQueue.main.async {
        self.peripheralTable.isHidden = true
        self.actConLab.text = "✅"
        self.searchBtn.setTitle("BTLE VI CONNECTED",for:UIControlState())
      }
    }
    
    // update the UI showing disconnected VI
    if msg==VehicleManagerStatusMessage.c5DISCONNECTED {
      DispatchQueue.main.async {
        self.actConLab.text = "---"
        self.msgRvcdLab.text = "---"
        self.verLab.text = "---"
        self.devidLab.text = "---"
        self.searchBtn.setTitle("SEARCH FOR BTLE VI",for:UIControlState())
      }
    }
    
    // when we see that notify is on, we can send 2 command requests
    // for version and device id, one after the other
    if msg==VehicleManagerStatusMessage.c5NOTIFYON {
     
      let delayTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
      DispatchQueue.main.asyncAfter(deadline: delayTime) {
        print("sending version cmd")
        let cm = VehicleCommandRequest()
        cm.command = .version
        self.vm.sendCommand(cm)
      }
      
      let delayTime2 = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
      DispatchQueue.main.asyncAfter(deadline: delayTime2) {
        print("sending devid cmd")
        let cm = VehicleCommandRequest()
        cm.command = .device_id
        self.vm.sendCommand(cm)
      }
      
      
    }
    
  }
  
  // this function handles all command responses
  func handle_cmd_response(_ rsp:NSDictionary) {
    // extract the command response message
    let cr = rsp.object(forKey: "vehiclemessage") as! VehicleCommandResponse
    print("cmd response : \(cr.command_response)")
    
    // update the UI depending on the command type
    if cr.command_response.isEqual(to: "version") {
      DispatchQueue.main.async {
        self.verLab.text = cr.message as String
      }
    }
    if cr.command_response.isEqual(to: "device_id") {
      DispatchQueue.main.async {
        self.devidLab.text = cr.message as String
      }
    }
    
  }

  
  // this function is called by the timer, it updates the UI
  func msgRxdUpdate(_ t:Timer) {
    if vm.connectionState==VehicleManagerConnectionState.operational {
      print("VM is receiving data from VI!")
      print("So far we've had ",vm.messageCount," messages")
      DispatchQueue.main.async {
        self.msgRvcdLab.text = String(self.vm.messageCount)
      }
    }
  }

  
  
  
  // table view delegate functions
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // how many VIs have been discovered
    print("discovered VI count",vm.discoveredVI().count)
    tableView.dataSource = self

    let count = vm.discoveredVI().count
    return count
    
  }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    
    // grab a cell
    var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?
    if (cell == nil) {
      cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
    }
    
    // grab the name of the VI for this row
    let p = vm.discoveredVI()[indexPath.row] as String
    
    // display the name of the VI
    cell!.textLabel?.text = p
    cell!.textLabel?.font = UIFont(name:"Arial", size: 14.0)
    cell!.textLabel?.textColor = UIColor.lightGray
    
    return cell!
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    // if a row is selected, connect to the selected VI
    let p = vm.discoveredVI()[indexPath.row] as String
    vm.connect(p)

  }
  

  
  
  
  
  
}

