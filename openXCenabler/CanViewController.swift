//
//  CanViewController.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-08-04.
//  Copyright (c) 2016 Ford Motor Company Licensed under the BSD license.
//

import UIKit
import openXCiOSFramework


class CanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var canTable: UITableView!

  var vm: VehicleManager!
  
  // dictionary holding CAN key/CAN message from measurement messages
  var canDict: NSMutableDictionary!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // grab VM instance
    vm = VehicleManager.sharedInstance

    // set default CAN target
    vm.setCanDefaultTarget(self, action: CanViewController.default_can_change)
    
    // initialize dictionary/table
    canDict = NSMutableDictionary()
    canTable.reloadData()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  func default_can_change(rsp:NSDictionary) {
    // extract the CAN message
    let vr = rsp.objectForKey("vehiclemessage") as! VehicleCanResponse
   
    // create CAN key from measurement message
    let key = String(format:"%x-%x",vr.bus,vr.id)
    let val = "0x"+(vr.data as String)
 
    // save the CAN key and can message in the dictionary
    canDict.setObject(vr, forKey:key)
    
    // update the table
    dispatch_async(dispatch_get_main_queue()) {
      self.canTable.reloadData()
    }
    print("default can msg:",key," -- ",val)
  }
  
  
  
  
  
  
  
  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // table size based on what's in the dictionary
    return canDict.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell?
    if (cell == nil) {
      cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
    }
    
    // sort the name keys alphabetically
    let sortedKeys = (canDict.allKeys as! [String]).sort(<)
    
    // grab a CAN key based on the table row
    let k = sortedKeys[indexPath.row]
    
    // grab the CAN message based on the CAN key
    let cr = canDict.objectForKey(k) as! VehicleCanResponse
    
    // convert timestamp to a normal time
    let date = NSDate(timeIntervalSince1970: Double(cr.timestamp/1000))
    let dayTimePeriodFormatter = NSDateFormatter()
    dayTimePeriodFormatter.dateFormat = "hh:mm:ss"
    let dateString = dayTimePeriodFormatter.stringFromDate(date)
    
    // show the table row with the important contents of the CAN message
    cell!.textLabel?.text = String(format:"%@  %2d  0x%3x   0x",dateString,cr.bus,cr.id)+(cr.data as String)
    cell!.textLabel?.font = UIFont(name:"Courier New", size: 14.0)
    cell!.textLabel?.textColor = UIColor.lightGrayColor()
    
    
    cell!.backgroundColor = UIColor.clearColor()
    
    
    return cell!
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // selecting this table does nothing    
  }
  




}

