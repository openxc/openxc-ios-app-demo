//
//  DashboardViewController.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-08-04.
//  Copyright (c) 2016 Ford Motor Company Licensed under the BSD license.
//

import UIKit
import openXCiOSFramework
import CoreMotion
import CoreLocation
import AVFoundation

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, NSURLConnectionDelegate {

  // measurement table
  @IBOutlet weak var dashTable: UITableView!
  
  
  var vm: VehicleManager!
  
  // dictionary holding name/value from measurement messages
  var dashDict: NSMutableDictionary!
  
  // sensor related vars
  private var sensorLoop: NSTimer = NSTimer()
  private var headphones : String = "No"
  private var motionManager : CMMotionManager = CMMotionManager()
  private var locationManager : CLLocationManager = CLLocationManager()
  private var lat : Double = 0
  private var long : Double = 0
  private var alt : Double = 0
  private var head : Double = 0
  private var speed : Double = 0.0
  
  // dweet related vars
  private var dweetLoop: NSTimer = NSTimer()
  private var dweetConn: NSURLConnection?
  private var dweetRspData: NSMutableData?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // grab VM instance
    vm = VehicleManager.sharedInstance
    
    // set default measurement target
    vm.setMeasurementDefaultTarget(self, action: DashboardViewController.default_measurement_change)
    
    // initialize dictionary/table
    dashDict = NSMutableDictionary()
    dashTable.reloadData()
    
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=500;
    locationManager.requestWhenInUseAuthorization()

    
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    print("in viewDidAppear")
    
    sensorLoop.invalidate()
    locationManager.stopUpdatingLocation()
    motionManager.stopDeviceMotionUpdates()
    
    dweetLoop.invalidate()
    
    
    if  NSUserDefaults.standardUserDefaults().boolForKey("sensorsOn") !=
        NSUserDefaults.standardUserDefaults().boolForKey("lastSensorsOn") {
      // clear the table if the sensor value changes
      dashDict = NSMutableDictionary()
      dashTable.reloadData()
    }
    NSUserDefaults.standardUserDefaults().setBool(NSUserDefaults.standardUserDefaults().boolForKey("sensorsOn"), forKey:"lastSensorsOn")
    
    if NSUserDefaults.standardUserDefaults().boolForKey("sensorsOn") {
      
      sensorLoop = NSTimer.scheduledTimerWithTimeInterval(0.25, target:self, selector:#selector(sensorUpdate), userInfo: nil, repeats:true)
    
      if CLLocationManager.locationServicesEnabled() {
        locationManager.startUpdatingLocation()
      }
      
      motionManager.deviceMotionUpdateInterval = 0.05
      motionManager.startDeviceMotionUpdates()
      
    }
    
    if NSUserDefaults.standardUserDefaults().boolForKey("dweetOutputOn") {
      dweetLoop = NSTimer.scheduledTimerWithTimeInterval(1.5, target:self, selector:#selector(sendDweet), userInfo: nil, repeats:true)
    }


  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    print("in viewDidDisappear")

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

  
  
  func sensorUpdate() {
    //print("in sensorLoop")
    
    if isHeadsetPluggedIn() {
      dashDict.setObject("Yes", forKey:"phone_headphones_attached")
    } else {
      dashDict.setObject("No", forKey:"phone_headphones_attached")
    }

    dashDict.setObject(UIScreen.mainScreen().brightness, forKey:"phone_brightness")

    if let motion = motionManager.deviceMotion {
      let p = 180/M_PI*motion.attitude.pitch;
      let r = 180/M_PI*motion.attitude.roll;
      let y = 180/M_PI*motion.attitude.yaw;
      dashDict.setObject(p, forKey:"phone_motion_pitch")
      dashDict.setObject(r, forKey:"phone_motion_roll")
      dashDict.setObject(y, forKey:"phone_motion_yaw")
    }
    
    // update the table
    dispatch_async(dispatch_get_main_queue()) {
      self.dashTable.reloadData()
    }
    
  }
  
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("in locationMgr:didUpdateLocations")
    if locations.count>0 {
      print(locations.last)
      let loc = locations.last!
      dashDict.setObject(loc.coordinate.latitude, forKey:"phone_latitude")
      dashDict.setObject(loc.coordinate.longitude, forKey:"phone_longitude")
      dashDict.setObject(loc.altitude, forKey:"phone_altitude")
      dashDict.setObject(loc.course, forKey:"phone_heading")
      dashDict.setObject(loc.speed, forKey:"phone_speed")
      // update the table
      dispatch_async(dispatch_get_main_queue()) {
        self.dashTable.reloadData()
      }

    }
  }
  
  func isHeadsetPluggedIn() -> Bool {
    let route = AVAudioSession.sharedInstance().currentRoute
    for desc in route.outputs {
      if desc.portType == AVAudioSessionPortHeadphones {
        return true
      }
    }
    return false
  }
  

  func sendDweet() {
    
    if let conn = dweetConn {
      // connection already exists!
      conn.cancel()
    }
    dweetConn = nil
    dweetRspData = NSMutableData()
    
    do {
      let jsonData = try NSJSONSerialization.dataWithJSONObject(dashDict, options: .PrettyPrinted)
      
      if let dweetname = NSUserDefaults.standardUserDefaults().stringForKey("dweetname") {
        let urlStr = NSURL(string:"https://dweet.io/dweet/for/"+dweetname)
        let postLength = String(format:"%lu", Double(jsonData.length))
        
        let request = NSMutableURLRequest()
        request.URL = urlStr
        request.HTTPMethod = "POST"
        request.setValue(postLength,forHTTPHeaderField:"Content-Length")
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.HTTPBody = jsonData
        
        dweetConn = NSURLConnection(request: request, delegate: self, startImmediately:true)
      }
      
    } catch {
      print("json encode error")
    }
    
  
    
  }
  
  func connection(connection: NSURLConnection!, didReceiveData data: NSData!){

    //print("in didRxData")
    dweetRspData?.appendData(data)
    
  }
  
  func connectionDidFinishLoading(connection: NSURLConnection!) {
   
    //print("in didFinishLoading")
    
    //let responseString = String(data:dweetRspData!,encoding:NSUTF8StringEncoding)
    //print(responseString)
    
  }
    
  
}

