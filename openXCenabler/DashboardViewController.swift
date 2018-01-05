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

// TODO: ToDo - Work on removing the warnings

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, NSURLConnectionDelegate {

  // measurement table
  @IBOutlet weak var dashTable: UITableView!
  
  
  var vm: VehicleManager!
  
  // dictionary holding name/value from measurement messages
  var dashDict: NSMutableDictionary!
  
  // sensor related vars
  fileprivate var sensorLoop: Timer = Timer()
  fileprivate var headphones : String = "No"
  fileprivate var motionManager : CMMotionManager = CMMotionManager()
  fileprivate var locationManager : CLLocationManager = CLLocationManager()
  fileprivate var lat : Double = 0
  fileprivate var long : Double = 0
  fileprivate var alt : Double = 0
  fileprivate var head : Double = 0
  fileprivate var speed : Double = 0.0
  
  // dweet related vars
  fileprivate var dweetLoop: Timer = Timer()
  fileprivate var dweetConn: NSURLConnection?
  fileprivate var dweetRspData: NSMutableData?
  
  
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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print("in viewDidAppear")
    
    sensorLoop.invalidate()
    locationManager.stopUpdatingLocation()
    motionManager.stopDeviceMotionUpdates()
    
    dweetLoop.invalidate()
    
    
    if  UserDefaults.standard.bool(forKey: "sensorsOn") !=
        UserDefaults.standard.bool(forKey: "lastSensorsOn") {
      // clear the table if the sensor value changes
      dashDict = NSMutableDictionary()
      dashTable.reloadData()
    }
    UserDefaults.standard.set(UserDefaults.standard.bool(forKey: "sensorsOn"), forKey:"lastSensorsOn")
    
    if UserDefaults.standard.bool(forKey: "sensorsOn") {
      
      sensorLoop = Timer.scheduledTimer(timeInterval: 0.25, target:self, selector:#selector(sensorUpdate), userInfo: nil, repeats:true)
    
      if CLLocationManager.locationServicesEnabled() {
        locationManager.startUpdatingLocation()
      }
      
      motionManager.deviceMotionUpdateInterval = 0.05
      motionManager.startDeviceMotionUpdates()
      
    }
    
    if UserDefaults.standard.bool(forKey: "dweetOutputOn") {
      dweetLoop = Timer.scheduledTimer(timeInterval: 1.5, target:self, selector:#selector(sendDweet), userInfo: nil, repeats:true)
    }


  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    print("in viewDidDisappear")

  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  func default_measurement_change(_ rsp:NSDictionary) {
    // extract the measurement message
    let vr = rsp.object(forKey: "vehiclemessage") as! VehicleMeasurementResponse
    
    // take name and value from measurement message
    let name = vr.name as NSString
    var val = vr.value as AnyObject
    // make sure we don't have any nulls in the dictionary, better to have blank strings
    if val.isEqual(NSNull()) {
      val="" as AnyObject
    }
    if vr.isEvented {
      var e:NSString
      if vr.event is NSNumber {
        let ne = vr.event as! NSNumber
        if ne.isEqual(to: NSNumber(value: true)) {
          e = "true";
        } else if ne.isEqual(to: NSNumber(value:false)) {
          e = "true";
        } else {
          // round any floating points
          let ner = Double(round(10.0*Double(ne))/10)
          e = String(ner) as NSString
        }
      } else {
        e = vr.event.description as NSString
      }
      val = NSString(format:"%@:%@",vr.value.description,e)
    }
    // save the name key and value in the dictionary
    dashDict.setObject(val, forKey:name)

    // update the table
    DispatchQueue.main.async {
        self.dashTable.reloadData()
    }
    if vr.isEvented {
      print("default measurement msg:",vr.name," -- ",vr.value,":",vr.event)
    } else {
      print("default measurement msg:",vr.name," -- ",vr.value)
    }
  }

  
  
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // table size based on what's in the dictionary
    return dashDict.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?
    if (cell == nil) {
      cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
    }

    // sort the name keys alphabetically
    let sortedKeys = (dashDict.allKeys as! [String]).sorted(by: <)
    
    // grab a name key based on the table row
    let k = sortedKeys[indexPath.row]
    
    // grab the value based on the name key
    let v = dashDict.object(forKey: k)

    // main text in table is the measurement name
    cell!.textLabel?.text = k
    cell!.textLabel?.font = UIFont(name:"Arial", size: 14.0)
    cell!.textLabel?.textColor = UIColor.lightGray
    
    // figure out if the value is a bool/number/string
    if v is NSNumber {
      let nv = v as! NSNumber
      if nv.isEqual(to: NSNumber(value: true as Bool)) {
        cell!.detailTextLabel?.text = "true"
      } else if nv.isEqual(to: NSNumber(value: false as Bool)) {
        cell!.detailTextLabel?.text = "false"
      } else {
        // round any floating points
        let nvr = Double(round(10.0*Double(nv))/10)
        cell!.detailTextLabel?.text = String(nvr)
      }
    } else {
      cell!.detailTextLabel?.text = (v! as AnyObject).description
    }
    cell!.detailTextLabel?.font = UIFont(name:"Arial", size: 14.0)
    cell!.detailTextLabel?.textColor = UIColor.lightGray
    
    cell!.backgroundColor = UIColor.clear
    
    
    return cell!
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // selecting this table does nothing
  }

  
  
  func sensorUpdate() {
    //print("in sensorLoop")
    
    if isHeadsetPluggedIn() {
      dashDict.setObject("Yes", forKey:"phone_headphones_attached" as NSCopying)
    } else {
      dashDict.setObject("No", forKey:"phone_headphones_attached" as NSCopying)
    }

    dashDict.setObject(UIScreen.main.brightness, forKey:"phone_brightness" as NSCopying)

    if let motion = motionManager.deviceMotion {
      let p = 180/M_PI*motion.attitude.pitch;
      let r = 180/M_PI*motion.attitude.roll;
      let y = 180/M_PI*motion.attitude.yaw;
      dashDict.setObject(p, forKey:"phone_motion_pitch" as NSCopying)
      dashDict.setObject(r, forKey:"phone_motion_roll" as NSCopying)
      dashDict.setObject(y, forKey:"phone_motion_yaw" as NSCopying)
    }
    
    // update the table
    DispatchQueue.main.async {
      self.dashTable.reloadData()
    }
    
  }
  
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("in locationMgr:didUpdateLocations")
    if locations.count>0 {
      print(locations.last as Any)
      let loc = locations.last!
      dashDict.setObject(loc.coordinate.latitude, forKey:"phone_latitude" as NSCopying)
      dashDict.setObject(loc.coordinate.longitude, forKey:"phone_longitude" as NSCopying)
      dashDict.setObject(loc.altitude, forKey:"phone_altitude" as NSCopying)
      dashDict.setObject(loc.course, forKey:"phone_heading" as NSCopying)
      dashDict.setObject(loc.speed, forKey:"phone_speed" as NSCopying)
      // update the table
      DispatchQueue.main.async {
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
      let jsonData = try JSONSerialization.data(withJSONObject: dashDict, options: .prettyPrinted)
      
      if let dweetname = UserDefaults.standard.string(forKey: "dweetname") {
        let urlStr = URL(string:"https://dweet.io/dweet/for/"+dweetname)
        let postLength = String(format:"%lu", Double(jsonData.count))
        
        let request = NSMutableURLRequest()
        request.url = urlStr
        request.httpMethod = "POST"
        request.setValue(postLength,forHTTPHeaderField:"Content-Length")
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.httpBody = jsonData
        
        // TODO: ToDo - Change NSURLConnection to NSURLSession
        dweetConn = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately:true)
      }
      
    } catch {
      print("json encode error")
    }
    
  
    
  }
  
    private func connection(_ connection: NSURLConnection!, didReceiveData data: Data!){

    //print("in didRxData")
    dweetRspData?.append(data)
    
  }
  
  func connectionDidFinishLoading(_ connection: NSURLConnection!) {
   
    //print("in didFinishLoading")
    
    //let responseString = String(data:dweetRspData!,encoding:NSUTF8StringEncoding)
    //print(responseString)
    
  }
    
  
}

