//
//  modalSettingsView.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-09-13.
//  Copyright (c) 2016 Ford Motor Company Licensed under the BSD license.
//

import UIKit

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
  
  @IBOutlet weak var playswitch: UISwitch!
  @IBOutlet weak var playname: UITextField!
  
  @IBOutlet weak var autoswitch: UISwitch!
  
  @IBOutlet weak var protoswitch: UISwitch!
  
  @IBOutlet weak var sensorswitch: UISwitch!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print("in modal viewDidLoad")
        
    // watch for changes to trace file output file name field
    recname.addTarget(self, action: #selector(recFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
    recname.hidden = true
    
    // watch for changes to dweet name field
    dweetname.addTarget(self, action: #selector(dweetFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
    dweetname.addTarget(self, action: #selector(keyboardWillShow), forControlEvents: UIControlEvents.EditingDidBegin)
    dweetname.addTarget(self, action: #selector(keyboardWillHide), forControlEvents: UIControlEvents.EditingDidEnd)
    dweetname.hidden = true
    dweetnamelabel.hidden = true

    // watch for changes to trace file input file name field
    playname.addTarget(self, action: #selector(playFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
    playname.hidden = true

    // check saved value of trace output switch
    let traceOutOn = NSUserDefaults.standardUserDefaults().boolForKey("traceOutputOn")
    // update UI if necessary
    if traceOutOn == true {
      recswitch.setOn(true, animated:false)
      recname.hidden = false
    }
    if let name = NSUserDefaults.standardUserDefaults().valueForKey("traceOutputFilename") as? NSString {
      recname.text = name as String
    }
    
    // check saved value of trace input switch
    let traceInOn = NSUserDefaults.standardUserDefaults().boolForKey("traceInputOn")
    // update UI if necessary
    if traceInOn == true {
      playswitch.setOn(true, animated:false)
      playname.hidden = false
    }
    if let name = NSUserDefaults.standardUserDefaults().valueForKey("traceInputFilename") as? NSString {
      playname.text = name as String
    }
    
    // check saved value of autoconnect switcg
    let autoOn = NSUserDefaults.standardUserDefaults().boolForKey("autoConnectOn")
    // update UI if necessary
    if autoOn == true {
      autoswitch.setOn(true, animated:false)
    }
    
    // check saved value of sensor switch
    let sensorOn = NSUserDefaults.standardUserDefaults().boolForKey("sensorsOn")
    // update UI if necessary
    if sensorOn == true {
      sensorswitch.setOn(true, animated:false)
    }
    
    // check saved value of protobuf switch
    let protobufOn = NSUserDefaults.standardUserDefaults().boolForKey("protobufOn")
    // update UI if necessary
    if protobufOn == true {
      protoswitch.setOn(true, animated:false)
    }
    
    // at first run, get a random dweet name
    if NSUserDefaults.standardUserDefaults().stringForKey("dweetname") == nil {
      let name : NSMutableString = ""
      
      var fileroot = NSBundle.mainBundle().pathForResource("adjectives", ofType:"txt")
      if fileroot != nil {
        do {
          let filecontents = try String(contentsOfFile: fileroot!)
          let allLines = filecontents.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
          let randnum = Int(arc4random_uniform(UInt32(allLines.count)))
          name.appendString(allLines[randnum])
        } catch {
          print("file load error")
          var randnum = arc4random_uniform(26)
          name.appendFormat("%c",65+randnum)
          randnum = arc4random_uniform(26)
          name.appendFormat("%c",65+randnum)
        }
      } else {
        print("file load error")
        var randnum = arc4random_uniform(26)
        name.appendFormat("%c",65+randnum)
        randnum = arc4random_uniform(26)
        name.appendFormat("%c",65+randnum)
      }
      
      name.appendString("-")
      
      fileroot = NSBundle.mainBundle().pathForResource("nouns", ofType:"txt")
      if fileroot != nil {
        do {
          let filecontents = try String(contentsOfFile: fileroot!)
          let allLines = filecontents.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
          let randnum = Int(arc4random_uniform(UInt32(allLines.count)))
          name.appendString(allLines[randnum])
        } catch {
          print("file load error")
          var randnum = arc4random_uniform(10)
          name.appendFormat("%c",30+randnum)
          randnum = arc4random_uniform(10)
          name.appendFormat("%c",30+randnum)
        }
      } else {
        print("file load error")
        var randnum = arc4random_uniform(10)
        name.appendFormat("%c",30+randnum)
        randnum = arc4random_uniform(10)
        name.appendFormat("%c",30+randnum)
      }
      
      print("first load - dweet name is ",name)
      NSUserDefaults.standardUserDefaults().setValue(name, forKey:"dweetname")
      
    }
    // load the dweet name into the text field
    dweetname.text = NSUserDefaults.standardUserDefaults().stringForKey("dweetname")
    // check value of dweet out switch
    let dweetOn = NSUserDefaults.standardUserDefaults().boolForKey("dweetOutputOn")
    // update UI if necessary
    if dweetOn == true {
      dweetswitch.setOn(true, animated:false)
      dweetname.hidden = false
      dweetnamelabel.hidden = false
    }
    
    
  }
  
  
  
  // text view delegate to clear keyboard
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder();
    return true;
  }
  
  // trace file output file name changed, save it in nsuserdefaults
  func recFieldDidChange(textField: UITextField) {
    NSUserDefaults.standardUserDefaults().setObject(textField.text, forKey:"traceOutputFilename")
  }
  
  // trace file input file name changed, save it in nsuserdefaults
  func playFieldDidChange(textField: UITextField) {
    NSUserDefaults.standardUserDefaults().setObject(textField.text, forKey:"traceInputFilename")
  }
  
  // dweet output name changed, save it in nsuserdefaults
  func dweetFieldDidChange(textField: UITextField) {
  NSUserDefaults.standardUserDefaults().setObject(textField.text, forKey:"dweetname")
  }
  
  
  // close modal view
  @IBAction func hideHit(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  // show 'about' view
  @IBAction func aboutHit(sender: AnyObject) {
    mainView.hidden = true
    aboutView.hidden = false
  }
  
  // show 'record' view
  @IBAction func recHit(sender: AnyObject) {
    mainView.hidden = true
    recView.hidden = false
  }
  // the trace output enabled switch changed, save it's new value
  // and show or hide the text field for filename accordingly
  @IBAction func recChange(sender: UISwitch) {
    NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey:"traceOutputOn")
    if sender.on {
      recname.hidden = false
    } else {
      recname.hidden = true
    }
  }
  @IBAction func dweetChange(sender: UISwitch) {
    NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey:"dweetOutputOn")
    if sender.on {
      dweetname.hidden = false
      dweetnamelabel.hidden = false
    } else {
      dweetname.hidden = true
      dweetnamelabel.hidden = true
    }
  }
  
  // show 'sources' view
  @IBAction func srcHit(sender: AnyObject) {
    mainView.hidden = true
    srcView.hidden = false
  }
  // the trace output enabled switch changed, save it's new value
  // and show or hide the text field for filename accordingly
  @IBAction func playChange(sender: UISwitch) {
    NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey:"traceInputOn")
    if sender.on {
      playname.hidden = false
    } else {
      playname.hidden = true
    }
  }
  // autoconnect switch changed, save it's value
  @IBAction func autoChange(sender: UISwitch) {
    NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey:"autoConnectOn")
  }
  // include sensor switch changed, save it's value
  @IBAction func sensorChange(sender: UISwitch) {
    NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey:"sensorsOn")
  }
  // protbuf mode switch changed, save it's value
  @IBAction func protoChange(sender: UISwitch) {
    NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey:"protobufOn")
  }

  // 'back' hit, clear all view and show initial menu view
  @IBAction func backHit(sender: AnyObject) {
    mainView.hidden = false
    aboutView.hidden = true
    recView.hidden = true
    srcView.hidden = true
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
  
  
  
  
}