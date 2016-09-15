//
//  modalSettingsView.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-09-13.
//  Copyright © 2016 Bug Labs. All rights reserved.
//

import UIKit

class modalSettingsView: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var mainView: UIView!
  @IBOutlet weak var aboutView: UIView!
  @IBOutlet weak var recView: UIView!
  @IBOutlet weak var srcView: UIView!
  
  @IBOutlet weak var recswitch: UISwitch!
  @IBOutlet weak var recname: UITextField!
  
  @IBOutlet weak var playswitch: UISwitch!
  @IBOutlet weak var playname: UITextField!
  
  @IBOutlet weak var autoswitch: UISwitch!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print("in modal viewDidLoad")
    
    recname.addTarget(self, action: #selector(recFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
    recname.hidden = true

    playname.addTarget(self, action: #selector(playFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
    playname.hidden = true

    let traceOutOn = NSUserDefaults.standardUserDefaults().boolForKey("traceOutputOn")
    if traceOutOn == true {
      recswitch.setOn(true, animated:false)
      recname.hidden = false
      if let name = NSUserDefaults.standardUserDefaults().valueForKey("traceOutputFilename") as? NSString {
        recname.text = name as String
      }
    }
    
    let traceInOn = NSUserDefaults.standardUserDefaults().boolForKey("traceInputOn")
    if traceInOn == true {
      playswitch.setOn(true, animated:false)
      playname.hidden = false
      if let name = NSUserDefaults.standardUserDefaults().valueForKey("traceInputFilename") as? NSString {
        playname.text = name as String
      }
    }
    
    let autoOn = NSUserDefaults.standardUserDefaults().boolForKey("autoConnectOn")
    if autoOn == true {
      autoswitch.setOn(true, animated:false)
    }
    
  }
  
  
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder();
    return true;
  }
  func recFieldDidChange(textField: UITextField) {
    NSUserDefaults.standardUserDefaults().setObject(textField.text, forKey:"traceOutputFilename")
  }
  func playFieldDidChange(textField: UITextField) {
    NSUserDefaults.standardUserDefaults().setObject(textField.text, forKey:"traceInputFilename")
  }
  
  
  
  @IBAction func hideHit(sender: AnyObject) {
    
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func aboutHit(sender: AnyObject) {
    mainView.hidden = true
    aboutView.hidden = false
  }
  
  @IBAction func recHit(sender: AnyObject) {
    mainView.hidden = true
    recView.hidden = false
  }
  @IBAction func recChange(sender: UISwitch) {
    NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey:"traceOutputOn")
    if sender.on {
      recname.hidden = false
    } else {
      recname.hidden = true
    }
  }
  
  @IBAction func srcHit(sender: AnyObject) {
    mainView.hidden = true
    srcView.hidden = false
  }
  @IBAction func playChange(sender: UISwitch) {
    NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey:"traceInputOn")
    if sender.on {
      playname.hidden = false
    } else {
      playname.hidden = true
    }
  }
  @IBAction func autoChange(sender: UISwitch) {
    NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey:"autoConnectOn")
  }
  
  @IBAction func backHit(sender: AnyObject) {
    mainView.hidden = false
    aboutView.hidden = true
    recView.hidden = true
    srcView.hidden = true
  }
  
  
  
}