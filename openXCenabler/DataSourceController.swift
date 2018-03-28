//
//  DataSourceController.swift
//  openXCenabler
//
//  Created by Ranjan, Kumar sahu (K.) on 22/03/18.
//  Copyright © 2018 Ford Motor Company. All rights reserved.
//

import UIKit
import openXCiOSFramework
import CoreLocation

class DataSourceController: UIViewController,UITextFieldDelegate,CLLocationManagerDelegate {

    
    @IBOutlet var PopupView: UIView!
    
    @IBOutlet weak var bluetoothBtn: UIButton!
    @IBOutlet weak var networkBtn: UIButton!
    @IBOutlet weak var tracefileBtn: UIButton!
    @IBOutlet weak var noneBtn: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    //Tracefile play back switch and textfield
    @IBOutlet weak var playswitch: UISwitch!
    @IBOutlet weak var playname: UITextField!

    @IBOutlet weak var locationswitch: UISwitch!
    @IBOutlet weak var bleAutoswitch: UISwitch!
    @IBOutlet weak var protoswitch: UISwitch!
    @IBOutlet weak var sensorswitch: UISwitch!
    
    //ranjan added code for Network data
    @IBOutlet weak var networkDataswitch: UISwitch!
    @IBOutlet weak var networkDataHost: UITextField!
    @IBOutlet weak var networkDataPort: UITextField!
    
    
    var interfaceValue:String!
    var locationManager = CLLocationManager()
    
    //Singleton Instance
    var NM : NetworkData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
         NM = NetworkData.sharedInstance
        // Do any additional setup after loading the view.
        PopupView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        
         //ranjan added code for Network data
         // watch for changes to network file output file name field
         networkDataHost.addTarget(self, action: #selector(networkDataFieldDidChange), for:UIControlEvents.editingChanged)
         networkDataPort.addTarget(self, action: #selector(networkPortFieldDidChange), for:UIControlEvents.editingChanged)
         //networkDataHost.isHidden = true
     
         // watch for changes to trace file input file name field
         playname.addTarget(self, action: #selector(playFieldDidChange), for: UIControlEvents.editingChanged)
        // playname.isHidden = true

        
        // check saved value of trace input switch
        let locationIsOn = UserDefaults.standard.bool(forKey: "locationOn")
        // update UI if necessary
        if locationIsOn == true {
            locationswitch.setOn(true, animated:false)
            //playname.isHidden = false
        }
        // check saved value of autoconnect switcg
        let autoOn = UserDefaults.standard.bool(forKey: "autoConnectOn")
        // update UI if necessary
        if autoOn == true {
            bleAutoswitch.setOn(true, animated:false)
        }
        // check saved value of sensor switch
        let sensorOn = UserDefaults.standard.bool(forKey: "sensorsOn")
        // update UI if necessary
        if sensorOn == true {
            sensorswitch.setOn(true, animated:false)
        }
        // check saved value of protobuf switch
        let protobufOn = UserDefaults.standard.bool(forKey: "protobufOn")
        // update UI if necessary
        if protobufOn == true {
            protoswitch.setOn(true, animated:false)
        }
        
        if let vechileInterface = UserDefaults.standard.value(forKey: "vehicleInterface") as? NSString {
            titleLabel.text = vechileInterface as String
            interfaceValue = vechileInterface as String
            self.setValueVehicleInterface()
        }
        if let networkHost = UserDefaults.standard.value(forKey: "networkHostName") as? NSString {
            networkDataHost.text = networkHost as String
        }
        if let networkPort = UserDefaults.standard.value(forKey: "networkPortName") as? NSString {
            networkDataPort.text = networkPort as String
            //self.networkDataFetch(hostName: networkDataHost.text!, PortName: networkDataPort.text!)
        }
        if let name = UserDefaults.standard.value(forKey: "traceInputFilename") as? NSString {
            playname.text = name as String
        }
    }
   /*
    //if we have no permission to access user location, then ask user for permission.
    func isAuthorizedtoGetUserLocation() {
        
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse     {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    //this method will be called each time when a user change his location access preference.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("User allowed us to access location")
            //do whatever init activities here.
        }
    }
    
    
    //this method is called by the framework on         locationManager.requestLocation();
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did location updates is called")
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        //store the user location here to firebase or somewhere
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did location updates is called but failed getting location \(error)")
    }
    */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //Dismiss button main view Action
    @IBAction func dismissView(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    //Vehicle interface button main view Action
    @IBAction func vehicleInterfaceBtn(_ sender: AnyObject) {
        PopupView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
       self.view.addSubview(PopupView)
        if let vechileInterface = UserDefaults.standard.value(forKey: "vehicleInterface") as? NSString {
            titleLabel.text = vechileInterface as String
            interfaceValue = vechileInterface as String
            self.setValueForRadioBtn()
        }
    }
    //Cancel button on pop up view Action
    @IBAction func cancelBtn(_ sender: AnyObject) {
        
        PopupView.removeFromSuperview()
        self.setValueVehicleInterface()
    }
    //Radio buttons on pop up view Action
    @IBAction func bluetoothBtnAction(_ sender: Any) {
        
        bluetoothBtn.isSelected = true
        networkBtn.isSelected = false
        tracefileBtn.isSelected = false
        noneBtn.isSelected = false
        interfaceValue = "Bluetooth"
    }
    @IBAction func networkBtnAction(_ sender: Any) {
        
        bluetoothBtn.isSelected = false
        networkBtn.isSelected = true
        tracefileBtn.isSelected = false
        noneBtn.isSelected = false
        interfaceValue = "Network"
    }
    @IBAction func trscefileBtnAction(_ sender: Any) {
        
        bluetoothBtn.isSelected = false
        networkBtn.isSelected = false
        tracefileBtn.isSelected = true
        noneBtn.isSelected = false
        interfaceValue = "Pre-recorded Tracefile"
    }
    @IBAction func noneBtnAction(_ sender: Any) {
        
        bluetoothBtn.isSelected = false
        networkBtn.isSelected = false
        tracefileBtn.isSelected = false
        noneBtn.isSelected = true
        interfaceValue = "None"
    }
    func setValueForRadioBtn(){
        if  (interfaceValue == "Bluetooth") {
            bluetoothBtn.isSelected = true
            networkBtn.isSelected = false
            tracefileBtn.isSelected = false
            noneBtn.isSelected = false
        }else if  (interfaceValue == "Pre-recorded Tracefile") {
            bluetoothBtn.isSelected = false
            networkBtn.isSelected = false
            tracefileBtn.isSelected = true
            noneBtn.isSelected = false
            
        }else if  (interfaceValue == "Network") {
            bluetoothBtn.isSelected = false
            networkBtn.isSelected = true
            tracefileBtn.isSelected = false
            noneBtn.isSelected = false
            
        }else  {
            bluetoothBtn.isSelected = false
            networkBtn.isSelected = false
            tracefileBtn.isSelected = false
            noneBtn.isSelected = true
            
        }
    }
    func setValueVehicleInterface(){
        
        if  (interfaceValue == "Bluetooth") {
            
            playname.isUserInteractionEnabled = false
            networkDataHost.isUserInteractionEnabled = false
            networkDataPort.isUserInteractionEnabled = false
            UserDefaults.standard.set(interfaceValue, forKey:"vehicleInterface")
            titleLabel.text = interfaceValue
        }
        else if  (interfaceValue == "Pre-recorded Tracefile") {
            playname.isUserInteractionEnabled = true
            networkDataHost.isUserInteractionEnabled = false
            networkDataPort.isUserInteractionEnabled = false
            UserDefaults.standard.set(interfaceValue, forKey:"vehicleInterface")
            titleLabel.text = interfaceValue
        }
        else if  (interfaceValue == "Network") {
            playname.isUserInteractionEnabled = false
            networkDataHost.isUserInteractionEnabled = true
            networkDataPort.isUserInteractionEnabled = true
            UserDefaults.standard.set(interfaceValue, forKey:"vehicleInterface")
            titleLabel.text = interfaceValue
        }
        else  {
            playname.isUserInteractionEnabled = false
            networkDataHost.isUserInteractionEnabled = false
            networkDataPort.isUserInteractionEnabled = false
            UserDefaults.standard.set(interfaceValue, forKey:"vehicleInterface")
            titleLabel.text = interfaceValue
        }
        
    }
    
    // the trace output enabled switch changed, save it's new value
    // and show or hide the text field for filename accordingly
    @IBAction func locationChange(_ sender: UISwitch) {
         UserDefaults.standard.set(sender.isOn, forKey:"locationOn")
       /* if sender.isOn == true{
           
            self.isAuthorizedtoGetUserLocation()
            
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.requestLocation();
            }
        }*/
      
    }
    // autoconnect switch changed, save it's value
    @IBAction func autoChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey:"autoConnectOn")
    }
    
    // include sensor switch changed, save it's value
    @IBAction func sensorChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey:"sensorsOn")
    }
    // protbuf mode switch changed, save it's value
    @IBAction func protoChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey:"protobufOn")
    }
    // text view delegate to clear keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       
        if textField.tag == 101{
           networkDataPort.becomeFirstResponder()
        }
        if textField.tag == 102{
            networkDataFetch(hostName: networkDataHost.text!,PortName: networkDataPort.text!)
             textField.resignFirstResponder();
        }
      
        return true;
    }
    //ranjan added code for Network data
    func networkDataFetch(hostName:String,PortName:String)  {
        // networkData.text = name as String
        
         //let ip  = hostName
         let port  = Int(hostName)
        if(hostName != "" && PortName != ""){
            NetworkData.sharedInstance.connect(ip:hostName, portvalue: port!, completionHandler: { (success) in
                print(success)
                if(success){
                    UserDefaults.standard.set(hostName, forKey:"networkHostName")
                    UserDefaults.standard.set(PortName, forKey:"networkPortName")
                    //self.callBack()
                }else{
                    let alertController = UIAlertController(title: "", message:
                        "error ocured in connection", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }else{
            let alertController = UIAlertController(title: "", message:
                "Please enter valid host name and port", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
            networkDataPort.resignFirstResponder()
            networkDataHost.resignFirstResponder()
        }
        
       /* let searchCharacter: Character = ":"
        if Ip.lowercased().characters.contains(searchCharacter) {
            
            // if (Ip != ""){
            
            var myStringArr = Ip.components(separatedBy: ":")
            let ip = myStringArr[0] //"0.0.0.0"
            if (myStringArr[1] != ""){
                let port = Int(myStringArr[1]) //50001
               
                
            }else{
                let alertController = UIAlertController(title: "", message:
                    "Please enter valid IP and host name", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }else{
            let alertController = UIAlertController(title: "", message:
                "Please enter valid IP and host name", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }*/
        
    }
    
    
    //ranjan added code for Network data
    // trace file output file name changed, save it in nsuserdefaults
    func networkDataFieldDidChange(_ textField: UITextField) {
        //UserDefaults.standard.set(textField.text, forKey:"networkAdress")
    }
    func networkPortFieldDidChange(_ textField: UITextField) {
        //UserDefaults.standard.set(textField.text, forKey:"networkAdress")
    }
    // trace file input file name changed, save it in nsuserdefaults
    func playFieldDidChange(_ textField: UITextField) {
        UserDefaults.standard.set(textField.text, forKey:"traceInputFilename")
    }
    
 
    //ranjan added code for Network data
    // connect to network address to fetch data from network emulator
//    @IBAction func networkData(_ sender: UISwitch) {
//
//        if sender.isOn {
//           // networkData.isHidden = false
//            UserDefaults.standard.set(sender.isOn, forKey:"networkdataOn")
//        } else {
//            //networkData.isHidden = true
//            UserDefaults.standard.set(false, forKey:"networkdataOn")
//            UserDefaults.standard.set("", forKey:"networkAdress")
//            NetworkData.sharedInstance.disconnectConnection()
//
//        }
//    }
    func keyboardWillShow() {
        if view.frame.origin.y == 0{
            self.view.frame.origin.y -= 120
        }
    }
    
    func keyboardWillHide() {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y += 120
        }
    }
    
    // show 'sources' view
    @IBAction func srcHit(_ sender: AnyObject) {
        /*  mainView.isHidden = true
         srcView.isHidden = false
         
         //ranjan added code for Network data
         // check saved value of Networkdata switch
         let networkOn = UserDefaults.standard.bool(forKey: "networkdataOn")
         // update UI if necessary
         if networkOn == true {
         networkDataswitch.setOn(true, animated:false)
         networkData.isHidden = false
         if let name = UserDefaults.standard.value(forKey: "networkAdress") as? NSString {
         
         if(!VehicleManager.sharedInstance.isNetworkConnected){
         networkDataFetch(Ip: name as String)
         }
         }
         }else{
         
         }*/
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
