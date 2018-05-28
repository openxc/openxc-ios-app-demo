//
//  RadioButtonsView.swift
//  openXCenabler
//
//  Created by Ranjan, Kumar sahu (K.) on 22/03/18.
//  Copyright © 2018 Ford Motor Company. All rights reserved.
//

import UIKit

// Custom Radio Button Component

 class RadioButtonsView: UIView {

    //MARK:- Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstCheckBox: UIButton!
    @IBOutlet weak var secondCheckBox: UIButton!
    @IBOutlet weak var thirdCheckBox: UIButton!
    @IBOutlet weak var fourthCheckBox: UIButton!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var fourthButton: UIButton!
    @IBOutlet var titleBtnGrp: [UIButton]!
    @IBOutlet var checkBoxGrp: [UIButton]!
    @IBOutlet var view: UIView!
   // public var radioClickHandler : RadioButtonClickHandler?
    
    //MARK:- Initializers
    override init (frame : CGRect) {
        super.init(frame : frame)
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    // for using CustomView in IB
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed("RadioButtonsView", owner: self, options: nil)
        self.addSubview(view)
    }
    
    //MARK:- Custom Functions
   // here set title and  radio button options
    func setRadioGroupWithTitle(_ title: String, options : [String] ) {
        self.titleLabel.text = title
        self.firstButton.setTitle(options[0],for: .normal)
        self.secondButton.setTitle(options[1],for: .normal)
        self.thirdButton.setTitle(options[2],for: .normal)
        self.fourthButton.setTitle(options[3],for: .normal)
    }
    
    
    // set Checkbox group  Title and Butons UI for Amenities
    func setAmenitiesRadioGroupWithTitle(_ title: String, options : [String] ,_ arrAmenities: [String]?) {
         self.titleLabel.text = title
        for i in 0 ..< options.count {
                let btn = titleBtnGrp[i]
                let checkbox = checkBoxGrp[i]
                btn.setTitle(options[i],for: .normal)
                let amenity = arrAmenities![i]
                if(amenity == "Y"){
                    //btn.setTitleColor(kChekBoxSelectedColor, for:.normal)
                    btn.isSelected = true
                    checkbox.setBackgroundImage( UIImage(named: "checked"), for: .normal)
                    checkbox.isSelected = true
                }else{
                    //btn.setTitleColor(kChekBoxdeselectedColor, for:.normal)
                    btn.isSelected = false
                    checkbox.setBackgroundImage( UIImage(named: "unchecked"), for: .normal)
                    checkbox.isSelected = false
                }
        }
    }
    
    // set Checkbox group  Title and Butons UI for Amenities
    func setCapacitiesRadioGroupWithTitle(_ title: String, options : [String] ,_ arrCapacities: [String]?) {

        self.setRadioGroupWithTitle(title, options: options)
        for capacity in arrCapacities! {  //itereate for all kind of capacity
            // let btn = titleBtnGrp[dictCapacity[capacity]!]
            // let checkbox = checkBoxGrp[dictCapacity[capacity]!]
             //btn.setTitleColor(kChekBoxSelectedColor, for:.normal)
            // btn.isSelected = true
             //checkbox.setBackgroundImage( UIImage(named: "checked"), for: .normal)
            // checkbox.isSelected = true
            
        }
    
   }
    
    // Reset UI for all Options
    func ResetAllOptions() {
        for titlebutton in titleBtnGrp {
           // titlebutton.setTitleColor(kChekBoxdeselectedColor, for: .normal)
            titlebutton.isSelected = false
          }
        for checkbox in checkBoxGrp {
            checkbox.setBackgroundImage( UIImage(named: "unchecked"), for: .normal)
            checkbox.isSelected = false
         }
    }
    
    func updateUI()  {
        
    }
    
    //MARK:- Button clicked Events
    
    //click event for all buttons
    @IBAction func firstButtonAction(_ sender: Any) {
        var selectedBtn = sender as! UIButton
        let selectedBtnTag = selectedBtn.tag
        
        // for  highlighting selected option only
        for titlebutton in titleBtnGrp {
            if(titlebutton.tag == selectedBtnTag){
                if(!titlebutton.isSelected){
                    //titlebutton.setTitleColor(kChekBoxSelectedColor, for:.normal)
                     titlebutton.isSelected = true
                }else{
                   // titlebutton.setTitleColor(kChekBoxdeselectedColor, for:.normal)
                    titlebutton.isSelected = false
                }
                selectedBtn = titlebutton
              }
             }
        
        
        // for set checked image for selected button only
        for checkbox in checkBoxGrp {
            if(checkbox.tag == selectedBtnTag){
              if(!checkbox.isSelected){
                   checkbox.setBackgroundImage( UIImage(named: "checked"), for: .normal)
                   checkbox.isSelected = true
               }else{
                   checkbox.setBackgroundImage( UIImage(named: "unchecked"), for: .normal)
                   checkbox.isSelected = false
                }
             }
      }
        //set callbak handler
         //self.radioClickHandler!(selectedBtn)
    }

}
