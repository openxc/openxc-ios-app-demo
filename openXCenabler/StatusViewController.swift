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
    @IBOutlet weak var platformLab: UILabel!
     @IBOutlet weak var NetworkImg: UIImageView!
    
    // scan/connect button
    @IBOutlet weak var searchBtn: UIButton!
    
    // table for holding/showing discovered VIs
    @IBOutlet weak var peripheralTable: UITableView!
    
    // the VM
    var vm: VehicleManager!
    var cm: Command!
    
    // timer for UI counter updates
    var timer: Timer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // change tab bar text colors
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.gray], for:UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for:.selected)
        
        
        // instantiate the VM
        vm = VehicleManager.sharedInstance
        cm = Command.sharedInstance
        // setup the status callback, and the command response callback
        vm.setManagerCallbackTarget(self, action: StatusViewController.manager_status_updates)
        //vm.setCanDefaultTarget(self, action: StatusViewController.handle_cmd_response)
        
        // setup the status callback, and the command response callback
        //cm.setManagerCallbackTarget(self, action: StatusViewController.manager_status_updates)
        vm.setCommandDefaultTarget(self, action: StatusViewController.handle_cmd_response)
        // turn on debug output
        vm.setManagerDebug(true)
    }
    override func viewDidAppear(_ animated: Bool) {
        let name = UserDefaults.standard.value(forKey: "networkAdress") as? NSString
        if name != nil{
            // networkDataFetch(Ip: name as String)
            if (vm.isNetworkConnected){
                self.NetworkImg.isHidden = false
                self.actConLab.text = ""
                self.searchBtn.setTitle("WIFI CONNECTED",for:UIControlState())
                return
            }else{
                self.NetworkImg.isHidden = true
                self.actConLab.text = "---"
                self.searchBtn.setTitle("SEARCH FOR BLE VI",for:UIControlState())
                let networkOn = UserDefaults.standard.bool(forKey: "networkdataOn")
                if(networkOn){
                    let alertController = UIAlertController(title: "", message:
                        "No Data please check the host adress", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    func networkDataFetch(Ip:String)  {
        if (Ip != ""){
            var myStringArr = Ip.components(separatedBy: ":")
            let ip = myStringArr[0] //"0.0.0.0"
            let port = Int(myStringArr[1]) //50001
            NetworkData.sharedInstance.connect(ip: ip, portvalue: port!, completionHandler: { (success) in
                print(success)
                if(!success){
                    let alertController = UIAlertController(title: "", message:
                        "error ocured", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
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
            vm.scan(completionHandler:{(success) in
                // update the UI
                if(!success){
                    let alertController = UIAlertController (title: "Setting", message: "Please enable Bluetooth", preferredStyle: .alert)
                    let url = URL(string: "App-Prefs:root=Bluetooth")
                    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                        guard URL(string: UIApplicationOpenSettingsURLString) != nil else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(url!) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url!, completionHandler: { (success) in
                                    print("Settings opened: \(success)") // Prints true
                                    
                                })
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                    }
                    alertController.addAction(settingsAction)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alertController.addAction(cancelAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                DispatchQueue.main.async {
                    self.actConLab.text = "❓"
                    self.searchBtn.setTitle("SCANNING",for:UIControlState())
                    //                    let alertController = UIAlertController(title: "", message:
                    //                        "Please check the BLE power is on ", preferredStyle: UIAlertControllerStyle.alert)
                    //                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    //                    self.present(alertController, animated: true, completion: nil)
                }
                
            })

        }
    }
    
    // this function receives all status updates from the VM
    func manager_status_updates(_ rsp:NSDictionary) {
        
        // extract the status message
        let status = rsp.object(forKey: "status") as! Int
        let msg = VehicleManagerStatusMessage(rawValue: status)
        
        
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
                self.NetworkImg.isHidden = true
                self.searchBtn.setTitle("BLE VI CONNECTED",for:UIControlState())
            }
        }
        if (vm.isNetworkConnected) {
            DispatchQueue.main.async {
                self.peripheralTable.isHidden = true
                self.actConLab.text = ""
                self.NetworkImg.isHidden = false
                self.searchBtn.setTitle("WIFI CONNECTED",for:UIControlState())
                self.searchBtn.isEnabled = false
                
            }
        }
        // update the UI showing disconnected VI
        if msg==VehicleManagerStatusMessage.c5DISCONNECTED {
            DispatchQueue.main.async {
                self.actConLab.text = "---"
                self.msgRvcdLab.text = "---"
                self.verLab.text = "---"
                self.devidLab.text = "---"
                self.platformLab.text = "---"
                self.searchBtn.setTitle("SEARCH FOR BLE VI",for:UIControlState())
            }
        }
        
        // when we see that notify is on, we can send the command requests
        // for version and device id, one after the other
        if msg==VehicleManagerStatusMessage.c5NOTIFYON {
            
            let delayTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                let cm = VehicleCommandRequest()
                cm.command = .version
                self.cm.sendCommand(cm)
            }
            
            let delayTime2 = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime2) {
                let cm = VehicleCommandRequest()
                cm.command = .device_id
                self.cm.sendCommand(cm)
            }
            let delayTime3 = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime3) {
                let cm = VehicleCommandRequest()
                cm.command = .platform
                self.cm.sendCommand(cm)
            }
        }
 
    }
    
    // this function handles all command responses
    func handle_cmd_response(_ rsp:NSDictionary) {
         
        // extract the command response message
        let cr = rsp.object(forKey: "vehiclemessage") as! VehicleCommandResponse
        
        
        // update the UI depending on the command type- version,device_id works for JSON mode, not in protobuf - TODO
        
        var cvc:CommandsViewController?
        let vcCount = self.tabBarController?.viewControllers?.count
        cvc = self.tabBarController?.viewControllers?[vcCount!-1] as! CommandsViewController?
        
        if cr.command_response.isEqual(to: "version") || cr.command_response.isEqual(to: ".version") {
            DispatchQueue.main.async {
                self.verLab.text = cr.message as String
            }
            cvc?.versionResp = String(cr.message)
            
            
        }
        if cr.command_response.isEqual(to: "device_id") || cr.command_response.isEqual(to: ".deviceid"){
            DispatchQueue.main.async {
                self.devidLab.text = cr.message as String
            }
            cvc?.deviceIdResp = String(cr.message)
            
        }
        if cr.command_response.isEqual(to: "platform") || cr.command_response.isEqual(to: ".platform") {
            DispatchQueue.main.async {
                self.platformLab.text = cr.message as String
            }
            cvc?.deviceIdResp = String(cr.message)
            
        }
    }
    
    
    // this function is called by the timer, it updates the UI
    func msgRxdUpdate(_ t:Timer) {
        if vm.connectionState==VehicleManagerConnectionState.operational {
           
             DispatchQueue.main.async {
                self.msgRvcdLab.text = String(self.vm.messageCount)
            }
        }
    }
    

    
    // table view delegate functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many VIs have been discovered

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

