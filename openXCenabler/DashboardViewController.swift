//
//  DashboardViewController.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-08-04.
//  Copyright (c) 2016 Ford Motor Company Licensed under the BSD license.
//

import UIKit
import openXCiOSFramework

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  // measurement table
  @IBOutlet weak var dashTable: UITableView!
  
  
  var vm: VehicleManager!
  
  // dictionary holding name/value from measurement messages
  var dashDict: NSMutableDictionary!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // grab VM instance
    vm = VehicleManager.sharedInstance
    
    // set default measurement target
    vm.setMeasurementDefaultTarget(self, action: DashboardViewController.default_measurement_change)
    
    // initialize dictionary/table
    dashDict = NSMutableDictionary()
    dashTable.reloadData()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
  }
 
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  func default_measurement_change(rsp:NSDictionary) {
    // extract the measurement message
    let vr = rsp.objectForKey("vehiclemessage") as! VehicleMeasurementResponse
    
    // take name and value from measurement message
    let name = vr.name as NSString
    var val = vr.value as AnyObject
    // make sure we don't have any nulls in the dictionary, better to have blank strings
    if val.isEqual(NSNull()) {
      val=""
    }
    // save the name key and value in the dictionary
    dashDict.setObject(val, forKey:name)

    // update the table
    dispatch_async(dispatch_get_main_queue()) {
        self.dashTable.reloadData()
    }
    print("default measurement msg:",vr.name," -- ",vr.value)
  }

  
  
  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // table size based on what's in the dictionary
    return dashDict.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell?
    if (cell == nil) {
      cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
    }

    // sort the name keys alphabetically
    let sortedKeys = (dashDict.allKeys as! [String]).sort(<)
    
    // grab a name key based on the table row
    let k = sortedKeys[indexPath.row]
    
    // grab the value based on the name key
    let v = dashDict.objectForKey(k)

    // main text in table is the measurement name
    cell!.textLabel?.text = k
    cell!.textLabel?.font = UIFont(name:"Arial", size: 14.0)
    cell!.textLabel?.textColor = UIColor.lightGrayColor()
    
    // figure out if the value is a bool/number/string
    if v is NSNumber {
      let nv = v as! NSNumber
      if nv.isEqualToValue(NSNumber(bool: true)) {
        cell!.detailTextLabel?.text = "true"
      } else if nv.isEqualToValue(NSNumber(bool:false)) {
        cell!.detailTextLabel?.text = "false"
      } else {
        // round any floating points
        let nvr = Double(round(10.0*Double(nv))/10)
        cell!.detailTextLabel?.text = String(nvr)
      }
    } else {
      cell!.detailTextLabel?.text = v!.description
    }
    cell!.detailTextLabel?.font = UIFont(name:"Arial", size: 14.0)
    cell!.detailTextLabel?.textColor = UIColor.lightGrayColor()
    
    cell!.backgroundColor = UIColor.clearColor()
    
    
    return cell!
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // selecting this table does nothing
  }


}

