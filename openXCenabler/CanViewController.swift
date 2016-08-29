//
//  CanViewController.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-08-04.
//  Copyright © 2016 Bug Labs. All rights reserved.
//

import UIKit
import openXCiOSFramework


class CanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var canTable: UITableView!

  var vm: VehicleManager!
  
  var canDict: NSMutableDictionary!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    vm = VehicleManager.sharedInstance
    vm.setCanDefaultTarget(self, action: CanViewController.default_can_change)
    
    canDict = NSMutableDictionary()
    canTable.reloadData()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  func default_can_change(rsp:NSDictionary) {
    let vr = rsp.objectForKey("vehiclemessage") as! VehicleCanResponse
   
    let key = String(format:"%x-%x",vr.bus,vr.id)
    let val = "0x"+(vr.data as String)
 
    canDict.setObject(vr, forKey:key)
    
    dispatch_async(dispatch_get_main_queue()) {
      self.canTable.reloadData()
    }
    print("default can msg:",key," -- ",val)
  }
  
  
  
  
  
  
  
  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return canDict.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell?
    if (cell == nil) {
      cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
    }
    
    let sortedKeys = (canDict.allKeys as! [String]).sort(<)
    
    let k = sortedKeys[indexPath.row]
    
    let vm = canDict.objectForKey(k) as! VehicleCanResponse
    
    let date = NSDate(timeIntervalSince1970: Double(vm.timestamp/1000))
    let dayTimePeriodFormatter = NSDateFormatter()
    dayTimePeriodFormatter.dateFormat = "hh:mm:ss"
    let dateString = dayTimePeriodFormatter.stringFromDate(date)
    
    cell!.textLabel?.text = String(format:"%@  %2d  0x%3x   0x",dateString,vm.bus,vm.id)+(vm.data as String)
    cell!.textLabel?.font = UIFont(name:"Courier New", size: 14.0)
    cell!.textLabel?.textColor = UIColor.lightGrayColor()
    
    
    cell!.backgroundColor = UIColor.clearColor()
    
    
    return cell!
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
  }
  




}

