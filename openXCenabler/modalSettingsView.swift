//
//  modalSettingsView.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-09-13.
//  Copyright (c) 2016 Ford Motor Company Licensed under the BSD license.
//

import UIKit
import openXCiOSFramework


class modalSettingsView: UIViewController, UITextFieldDelegate {

  // UI outlets
  @IBOutlet weak var mainView: UIView!
  @IBOutlet weak var aboutView: UIView!
  @IBOutlet weak var recView: UIView!
  @IBOutlet weak var srcView: UIView!
  
  @IBOutlet weak var recswitch: UISwitch!
  @IBOutlet weak var recname: UITextField!
  @IBOutlet weak var dweetswitch: UISwitch!
  @IBOutlet weak var dweetname: UITextField!
  @IBOutlet weak var dweetnamelabel: UILabel!
    
  @IBOutlet weak var appVersion: UILabel!
  
  @IBOutlet weak var playswitch: UISwitch!
  @IBOutlet weak var playname: UITextField!
    
  @IBOutlet weak var networkData: UITextField!
 
  
  @IBOutlet weak var autoswitch: UISwitch!
  
  @IBOutlet weak var protoswitch: UISwitch!
  
  @IBOutlet weak var sensorswitch: UISwitch!
    
   //ranjan added code for Network data
  @IBOutlet weak var networkDataswitch: UISwitch!
    var NM : NetworkData!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let versionNumberString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
   
    
    appVersion.text = versionNumberString
    NM = NetworkData.sharedInstance

    // watch for changes to trace file output file name field
    recname.addTarget(self, action: #selector(recFieldDidChange), for: UIControlEvents.editingChanged)
    recname.isHidden = true
    
    //ranjan added code for Network data
    // watch for changes to trace file output file name field
    networkData.addTarget(self, action: #selector(networkDataFieldDidChange), for:UIControlEvents.editingChanged)
    networkData.isHidden = true
    
    // watch for changes to dweet name field
    dweetname.addTarget(self, action: #selector(dweetFieldDidChange), for: UIControlEvents.editingChanged)
    dweetname.addTarget(self, action: #selector(keyboardWillShow), for: UIControlEvents.editingDidBegin)
    dweetname.addTarget(self, action: #selector(keyboardWillHide), for: UIControlEvents.editingDidEnd)
    dweetname.isHidden = true
    dweetnamelabel.isHidden = true

    // watch for changes to trace file input file name field
    playname.addTarget(self, action: #selector(playFieldDidChange), for: UIControlEvents.editingChanged)
    playname.isHidden = true

    // check saved value of trace output switch
    let traceOutOn = UserDefaults.standard.bool(forKey: "traceOutputOn")
    // update UI if necessary
    if traceOutOn == true {
      recswitch.setOn(true, animated:false)
      recname.isHidden = false
    }
    if let name = UserDefaults.standard.value(forKey: "traceOutputFilename") as? NSString {
      recname.text = name as String
    }
    
    // check saved value of trace input switch
    let traceInOn = UserDefaults.standard.bool(forKey: "traceInputOn")
    // update UI if necessary
    if traceInOn == true {
      playswitch.setOn(true, animated:false)
      playname.isHidden = false
    }
    if let name = UserDefaults.standard.value(forKey: "traceInputFilename") as? NSString {
      playname.text = name as String
    }
    
    // check saved value of autoconnect switcg
    let autoOn = UserDefaults.standard.bool(forKey: "autoConnectOn")
    // update UI if necessary
    if autoOn == true {
      autoswitch.setOn(true, animated:false)
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

    // at first run, get a random dweet name
    if UserDefaults.standard.string(forKey: "dweetname") == nil {
      let name : NSMutableString = ""
      
      var fileroot = Bundle.main.path(forResource: "adjectives", ofType:"txt")
      if fileroot != nil {
        do {
          let filecontents = try String(contentsOfFile: fileroot!)
          let allLines = filecontents.components(separatedBy: CharacterSet.newlines)
          let randnum = Int(arc4random_uniform(UInt32(allLines.count)))
          name.append(allLines[randnum])
        } catch {
      
          var randnum = arc4random_uniform(26)
          name.appendFormat("%c",65+randnum)
          randnum = arc4random_uniform(26)
          name.appendFormat("%c",65+randnum)
        }
      } else {
   
        var randnum = arc4random_uniform(26)
        name.appendFormat("%c",65+randnum)
        randnum = arc4random_uniform(26)
        name.appendFormat("%c",65+randnum)
      }
      
      name.append("-")
      
      fileroot = Bundle.main.path(forResource: "nouns", ofType:"txt")
      if fileroot != nil {
        do {
          let filecontents = try String(contentsOfFile: fileroot!)
          let allLines = filecontents.components(separatedBy: CharacterSet.newlines)
          let randnum = Int(arc4random_uniform(UInt32(allLines.count)))
          name.append(allLines[randnum])
        } catch {
         
          var randnum = arc4random_uniform(10)
          name.appendFormat("%c",30+randnum)
          randnum = arc4random_uniform(10)
          name.appendFormat("%c",30+randnum)
        }
      } else {
       
        var randnum = arc4random_uniform(10)
        name.appendFormat("%c",30+randnum)
        randnum = arc4random_uniform(10)
        name.appendFormat("%c",30+randnum)
      }
      UserDefaults.standard.setValue(name, forKey:"dweetname")
      
    }
    // load the dweet name into the text field
    dweetname.text = UserDefaults.standard.string(forKey: "dweetname")
    // check value of dweet out switch
    let dweetOn = UserDefaults.standard.bool(forKey: "dweetOutputOn")
    // update UI if necessary
    if dweetOn == true {
      dweetswitch.setOn(true, animated:false)
      dweetname.isHidden = false
      dweetnamelabel.isHidden = false
    }
    
    
  }

  // text view delegate to clear keyboard
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder();
   if textField.tag == 101{
    networkDataFetch(Ip: textField.text!)
    
    }
    return true;
  }
  //ranjan added code for Network data
    func networkDataFetch(Ip:String)  {
       // networkData.text = name as String
        let searchCharacter: Character = ":"
        if Ip.lowercased().characters.contains(searchCharacter) {
           // print("word contains \(search Character)")

       // if (Ip != ""){
       
        var myStringArr = Ip.components(separatedBy: ":")
        let ip = myStringArr[0] //"0.0.0.0"
            if (myStringArr[1] != ""){
        let port = Int(myStringArr[1]) //50001
                NetworkData.sharedInstance.connect(ip: ip, portvalue: port!, completionHandler: { (success) in
                    print(success)
                    if(success){
                         UserDefaults.standard.set(Ip, forKey:"networkAdress")
                        //self.callBack()
                    }else{
                        let alertController = UIAlertController(title: "", message:
                                        "error ocured", preferredStyle: UIAlertControllerStyle.alert)
                                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                                    self.present(alertController, animated: true, completion: nil)
                    }
                })
                
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
        }

    }

  // trace file output file name changed, save it in nsuserdefaults
  func recFieldDidChange(_ textField: UITextField) {
    UserDefaults.standard.set(textField.text, forKey:"traceOutputFilename")
  }
    //ranjan added code for Network data
    // trace file output file name changed, save it in nsuserdefaults
    func networkDataFieldDidChange(_ textField: UITextField) {
        //UserDefaults.standard.set(textField.text, forKey:"networkAdress")
    }
  
  // trace file input file name changed, save it in nsuserdefaults
  func playFieldDidChange(_ textField: UITextField) {
    UserDefaults.standard.set(textField.text, forKey:"traceInputFilename")
  }
  
  // dweet output name changed, save it in nsuserdefaults
  func dweetFieldDidChange(_ textField: UITextField) {
  UserDefaults.standard.set(textField.text, forKey:"dweetname")
  }
  
  
  // close modal view
  @IBAction func hideHit(_ sender: AnyObject) {
    self.dismiss(animated: true, completion: nil)
  }
  
  
  // show 'about' view
  @IBAction func aboutHit(_ sender: AnyObject) {
    mainView.isHidden = true
    aboutView.isHidden = false
  }
  
  // show 'record' view
  @IBAction func recHit(_ sender: AnyObject) {
    mainView.isHidden = true
    recView.isHidden = false
  }
  // the trace output enabled switch changed, save it's new value
  // and show or hide the text field for filename accordingly
  @IBAction func recChange(_ sender: UISwitch) {
    UserDefaults.standard.set(sender.isOn, forKey:"traceOutputOn")
    if sender.isOn {
      recname.isHidden = false
    } else {
      recname.isHidden = true
    }
  }
  @IBAction func dweetChange(_ sender: UISwitch) {
    UserDefaults.standard.set(sender.isOn, forKey:"dweetOutputOn")
    if sender.isOn {
      dweetname.isHidden = false
      dweetnamelabel.isHidden = false
    } else {
      dweetname.isHidden = true
      dweetnamelabel.isHidden = true
    }
  }
  
  // show 'sources' view
  @IBAction func srcHit(_ sender: AnyObject) {
    mainView.isHidden = true
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
        
    }
    
  }
  // the trace output enabled switch changed, save it's new value
  // and show or hide the text field for filename accordingly
  @IBAction func playChange(_ sender: UISwitch) {
    UserDefaults.standard.set(sender.isOn, forKey:"traceInputOn")
    if sender.isOn {
      playname.isHidden = false
    } else {
      playname.isHidden = true
    }
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
//ranjan added code for Network data
     // connect to network address to fetch data from network emulator
  @IBAction func networkData(_ sender: UISwitch) {
    
        if sender.isOn {
            networkData.isHidden = false
            UserDefaults.standard.set(sender.isOn, forKey:"networkdataOn")
        } else {
            networkData.isHidden = true
            UserDefaults.standard.set(false, forKey:"networkdataOn")
            UserDefaults.standard.set("", forKey:"networkAdress")
            NetworkData.sharedInstance.disconnectConnection()
            
        }
    }
    
  // 'back' hit, clear all view and show initial menu view
  @IBAction func backHit(_ sender: AnyObject) {
    mainView.isHidden = false
    aboutView.isHidden = true
    recView.isHidden = true
    srcView.isHidden = true
  }
 
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

    /*func callBack(){
        if (VehicleManager.sharedInstance.isNetworkConnected){
            let alertController = UIAlertController(title: "", message:
                "connected sucessfully", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }*/
  
}
