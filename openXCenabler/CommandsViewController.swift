//
//  CommandsViewController.swift
//  openXCenabler
//
//  Created by Kanishka, Vedi (V.) on 27/04/17.
//  Copyright (c) 2016 Ford Motor Company Licensed under the BSD license.
//

import UIKit
import openXCiOSFramework


class CommandsViewController:UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    // the VM
    var vm: VehicleManager!
    var cm: Command!
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var responseLab: UILabel!
    
    @IBOutlet weak var busSeg: UISegmentedControl!
    @IBOutlet weak var enabSeg: UISegmentedControl!
    @IBOutlet weak var bypassSeg: UISegmentedControl!
    @IBOutlet weak var pFormatSeg: UISegmentedControl!
    
    @IBOutlet weak var busLabel: UILabel!
    @IBOutlet weak var enabledLabel: UILabel!
    @IBOutlet weak var bypassLabel: UILabel!
    @IBOutlet weak var formatLabel: UILabel!
    
    @IBOutlet weak var sendCmndButton: UIButton!

    @IBOutlet weak var acitivityInd: UIActivityIndicatorView!

    
    let commands = ["Version","Device Id","Passthrough CAN Mode","Acceptance Filter Bypass","Payload Format JSON", "Platform", "RTC Config", "SD Card Status"]
    
    var versionResp: String!
    var deviceIdResp: String!
    var passthroughResp: String!
    var accFilterBypassResp: String!
    var payloadFormatResp: String!
    var platformResp: String!
    var rtcConfigResp: String!
    var sdCardResp: String!

    var selectedRowInPicker: Int!

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        hideAll()
      
        acitivityInd.center = self.view.center
        acitivityInd.hidesWhenStopped = true
        acitivityInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        acitivityInd.isHidden = true
        
        // grab VM instance
        vm = VehicleManager.sharedInstance
        cm = Command.sharedInstance
       // vm.setCommandDefaultTarget(self, action: CommandsViewController.handle_cmd_response)
        vm.setCommandDefaultTarget(self, action: CommandsViewController.handle_cmd_response)
        //vm.cmdObj?.setCommandDefaultTarget(self, action: CommandsViewController.handle_cmd_response)
        
        selectedRowInPicker = pickerView.selectedRow(inComponent: 0)
       
        populateCommandResponseLabel(rowNum: selectedRowInPicker)
        
        busSeg.addTarget(self, action: #selector(busSegmentedControlValueChanged), for: .valueChanged)
        enabSeg.addTarget(self, action: #selector(enabSegmentedControlValueChanged), for: .valueChanged)
        bypassSeg.addTarget(self, action: #selector(bypassSegmentedControlValueChanged), for: .valueChanged)
        pFormatSeg.addTarget(self, action: #selector(formatSegmentedControlValueChanged), for: .valueChanged)

    }
    
    override func viewDidAppear(_ animated: Bool) {

        if(!vm.isBleConnected){
            
            AlertHandling.sharedInstance.showAlert(onViewController: self, withText: errorMSG, withMessage:errorMsgBLE)

          }
    }
    // MARK: Commands Function

    @IBAction func sendCmnd() {
        
        let sRow = pickerView.selectedRow(inComponent: 0)
        
        
        if(vm.isBleConnected){
        
        switch sRow {
        case 0:
            responseLab.text = versionResp
            break
        case 1:
            responseLab.text = deviceIdResp
            break
        case 2:

            let cm = VehicleCommandRequest()
            
            // look at segmented control for bus
            cm.bus = busSeg.selectedSegmentIndex + 1
            
            
            
            if enabSeg.selectedSegmentIndex==0 {
                cm.enabled = true
            } else {
                cm.enabled = false
            }
            
            cm.command = .passthrough
            self.cm.sendCommand(cm)
            // activity indicator
            
            showActivityIndicator()
            
            break
        case 3:
            
            let cm = VehicleCommandRequest()
            
            // look at segmented control for bus
            cm.bus = busSeg.selectedSegmentIndex + 1
           

            if bypassSeg.selectedSegmentIndex==0 {
                cm.bypass = true
            } else {
                cm.bypass = false
            }
            
            cm.command = .af_bypass
            self.cm.sendCommand(cm)
            showActivityIndicator()
            break
        case 4:
            
            let cm = VehicleCommandRequest()
            
            if pFormatSeg.selectedSegmentIndex==0 {
                cm.format = "json"
            } else {
                cm.format = "protobuf"
            }
            cm.command = .payload_format
            self.cm.sendCommand(cm)
            showActivityIndicator()
            break
        case 5:
            
            let cm = VehicleCommandRequest()
            cm.command = .platform
            self.cm.sendCommand(cm)
            showActivityIndicator()
            break
        case 6:
            let cm = VehicleCommandRequest()
            cm.command = .rtc_configuration
            self.cm.sendCommand(cm)
            showActivityIndicator()
            break
        case 7:
           
            let cm = VehicleCommandRequest()
            cm.command = .sd_mount_status
            self.cm.sendCommand(cm)
            showActivityIndicator()
            break
        default:
            break
        }
        }else{
            AlertHandling.sharedInstance.showAlert(onViewController: self, withText: errorMSG, withMessage: errorMsgBLE)

        }

    }
    
    // this function handles all command responses
    func handle_cmd_response(_ rsp:NSDictionary) {
        // extract the command response message
        let cr = rsp.object(forKey: "vehiclemessage") as! VehicleCommandResponse
        
        // update the UI depending on the command type- version,device_id works for JSON mode, not in protobuf - TODO
        
        if cr.command_response.isEqual(to: "version") {
                versionResp = cr.message as String
        }
        if cr.command_response.isEqual(to: "device_id") {
                deviceIdResp = cr.message as String
        }
        
        if cr.command_response.isEqual(to: "passthrough") {
            passthroughResp = String(cr.status)
        }
        
        if cr.command_response.isEqual(to: "af_bypass") {
            accFilterBypassResp = String(cr.status)
        }
        
        if cr.command_response.isEqual(to: "payload_format") {
            payloadFormatResp = String(cr.status)
        }
        if cr.command_response.isEqual(to: "platform") {
            platformResp = cr.message as String
        }
        if cr.command_response.isEqual(to: "rtc_configuration") {
            rtcConfigResp = String(cr.status)
        }
        if cr.command_response.isEqual(to: "sd_mount_status") {
            sdCardResp = String(cr.status)
        }
        // update the label
        DispatchQueue.main.async {
            self.populateCommandResponseLabel(rowNum: self.selectedRowInPicker)
        }
    }
    
    // MARK: Segment Control Function
    
    func busSegmentedControlValueChanged() {
      
       
        //let selectedSegment = busSeg.selectedSegmentIndex

    }

    func enabSegmentedControlValueChanged() {
        
       
    }

    func bypassSegmentedControlValueChanged() {
        
      
    }
    
    func formatSegmentedControlValueChanged() {
        
      
    }
    
    // MARK: Picker Delgate Function

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return commands.count
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var rowTitle:NSAttributedString!
        
        rowTitle = NSAttributedString(string: commands[row], attributes: [NSForegroundColorAttributeName : UIColor.white])
        return rowTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedRowInPicker = row
        populateCommandResponseLabel(rowNum: row)
        
    }
    
    // MARK: UI Function

    func populateCommandResponseLabel(rowNum: Int) {
        hideAll()
        hideActivityIndicator()

        switch rowNum {
        case 0:
            sendCmndButton.isHidden = true
            responseLab.text = versionResp
            break
        case 1:
            sendCmndButton.isHidden = true
            responseLab.text = deviceIdResp
            break
        case 2:
            sendCmndButton.isHidden = false
            responseLab.text = passthroughResp
            busLabel.isHidden = false
            busSeg.isHidden = false
            enabledLabel.isHidden = false
            enabSeg.isHidden = false
            break
        case 3:
            sendCmndButton.isHidden = false
            responseLab.text = accFilterBypassResp
            busLabel.isHidden = false
            busSeg.isHidden = false
            bypassLabel.isHidden = false
            bypassSeg.isHidden = false
            break
        case 4:
            sendCmndButton.isHidden = false
            responseLab.text = payloadFormatResp
            formatLabel.isHidden = false
            pFormatSeg.isHidden = false
            break
        case 5:
            sendCmndButton.isHidden = false
            responseLab.text = platformResp
            break
        case 6:
            sendCmndButton.isHidden = false
            responseLab.text = rtcConfigResp
            break
        case 7:
            sendCmndButton.isHidden = false
            responseLab.text = sdCardResp
            break
        default:
            sendCmndButton.isHidden = true
            responseLab.text = versionResp
        }
    }
    
    func hideAll() {
        busSeg.isHidden = true
        enabSeg.isHidden = true
        bypassSeg.isHidden = true
        pFormatSeg.isHidden = true
        busLabel.isHidden = true
        enabledLabel.isHidden = true
        bypassLabel.isHidden = true
        formatLabel.isHidden = true
    }
    
    func showActivityIndicator() {
        acitivityInd.startAnimating()
        self.view.alpha = 0.5
        self.view.isUserInteractionEnabled = false

    }
    func hideActivityIndicator() {
        acitivityInd.stopAnimating()
        self.view.alpha = 1.0
        self.view.isUserInteractionEnabled = true
        
    }
}
