//
//  DashboardViewController.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-08-04.
//  Copyright © 2016 Bug Labs. All rights reserved.
//

import UIKit
import openXCiOSFramework

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var dashTable: UITableView!
  
  
  var vm: VehicleManager!
  
  var dashDict: NSMutableDictionary!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    vm = VehicleManager.sharedInstance
    vm.setMeasurementDefaultTarget(self, action: DashboardViewController.default_measurement_change)
    
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
    let vr = rsp.objectForKey("vehiclemessage") as! VehicleMeasurementResponse
    
    let name = vr.name as NSString
    var val = vr.value as AnyObject
    if val.isEqual(NSNull()) {
      val=""
    }
    dashDict.setObject(val, forKey:name)

    dispatch_async(dispatch_get_main_queue()) {
        self.dashTable.reloadData()
    }
    print("default measurement msg:",vr.name," -- ",vr.value)
  }

  
  
  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dashDict.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell?
    if (cell == nil) {
      cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
    }

    let sortedKeys = (dashDict.allKeys as! [String]).sort(<)
    
    let k = sortedKeys[indexPath.row]
    
    let v = dashDict.objectForKey(k)

    cell!.textLabel?.text = k
    cell!.textLabel?.font = UIFont(name:"Arial", size: 14.0)
    cell!.textLabel?.textColor = UIColor.lightGrayColor()
    
    if v is NSNumber {
      let nv = v as! NSNumber
      if nv.isEqualToValue(NSNumber(bool: true)) {
        cell!.detailTextLabel?.text = "true"
      } else if nv.isEqualToValue(NSNumber(bool:false)) {
        cell!.detailTextLabel?.text = "false"
      } else {
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
    
  }


}

