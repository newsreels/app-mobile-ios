//
//  AudioSettingsVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 07/01/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import SwiftTheme

class AudioSettingsVC: UIViewController {

    @IBOutlet var btnCollectionNarrator: [UIButton]!
    @IBOutlet weak var btnRadioHeadOnly: UIButton!
    @IBOutlet weak var imgRadioHeadOnly: UIImageView!
    @IBOutlet weak var btnRadioHeadBullets: UIButton!
    @IBOutlet weak var imgRadioHeadBullets: UIImageView!
    
    @IBOutlet weak var lblReadingSpeed: UILabel!
    @IBOutlet var lblCollection: [UILabel]!
//    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var slider: CustomUISlider!
    @IBOutlet weak var lblNarrator: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblHeadingOnly: UILabel!
    @IBOutlet weak var lblReading: UILabel!
    @IBOutlet weak var lblHeadingBullets: UILabel!
    
    var stNarrator = ""
    let step: Float = 0.5
    let numbers = [0.5, 0.75, 1.0, 1.5, 2.0]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocalization()
        // slider values go from 0 to the number of values in your numbers array
        let numberOfSteps = Float((numbers.count) - 1)
        slider.maximumValue = numberOfSteps
        slider.minimumValue = 0
//        slider.minimumValue = 0.0
//        slider.maximumValue = 2.0
        slider.isContinuous = true
        
        let sValue = SharedManager.shared.localReadingSpeed
        print(sValue)
//        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
//        imgBack.theme_image = GlobalPicker.imgBack
        lblCollection.forEach { lbl in
            lbl.addTextSpacing(spacing: 2.0)
            lbl.setLineSpacing(lineSpacing: 5)
            lbl.theme_textColor = GlobalPicker.textColor
        }
        
//        if let index = numbers.firstIndex(of: sValue) {
//
//            if index == 0 {
//
//                lblReadingSpeed.text = "\(sValue)x"
//                SharedManager.shared.readingSpeed = "\(sValue)x"
//                SharedManager.shared.localReadingSpeed = 0.5
//            }
//            else if index == 1 {
//
//                lblReadingSpeed.text = "\(sValue)x"
//                SharedManager.shared.readingSpeed = "\(sValue)x"
//                SharedManager.shared.localReadingSpeed = 0.75
//            }
//            else if index == 2 {
//
//                lblReadingSpeed.text = "\(sValue)x"
//                SharedManager.shared.readingSpeed = "\(sValue)x"
//                SharedManager.shared.localReadingSpeed = 1.0
//            }
//            else if index == 3 {
//
//                lblReadingSpeed.text = "\(sValue)x"
//                SharedManager.shared.readingSpeed = "\(sValue)x"
//                SharedManager.shared.localReadingSpeed = 1.5
//            }
//            else if index == 4 {
//
//                lblReadingSpeed.text = "\(sValue)x"
//                SharedManager.shared.readingSpeed = "\(sValue)x"
//                SharedManager.shared.localReadingSpeed = 2.0
//            }
//            else {
//
//                lblReadingSpeed.text = "1.0x"
//                SharedManager.shared.readingSpeed = "1.0x"
//                SharedManager.shared.localReadingSpeed = 1.0
//            }
//
//        }

        
        if sValue == 0.5 || sValue == 0.65 {

            lblReadingSpeed.text = "0.5x"
            SharedManager.shared.readingSpeed = "0.5x"
            //slider.value = 0.5
            slider.setValue(0, animated: false)
        }
        else if sValue == 0.85 || sValue == 0.75 {

            lblReadingSpeed.text = "0.75x"
            SharedManager.shared.readingSpeed = "0.75x"
            //slider.value = 0.75
            slider.setValue(1, animated: false)
        }
        else if sValue == 1 {

            lblReadingSpeed.text = "1.0x"
            SharedManager.shared.readingSpeed = "1.0x"
            //slider.value = 1.5
            slider.setValue(2, animated: false)
        }
        else if sValue == 1.1  || sValue == 1.5 {

            lblReadingSpeed.text = "1.5x"
            SharedManager.shared.readingSpeed = "1.5x"
            //slider.value = 1.5
            slider.setValue(3, animated: false)
        }
        else if sValue == 1.25  || sValue == 2.0 {

            lblReadingSpeed.text = "2.0x"
            SharedManager.shared.readingSpeed = "2.0x"
            //slider.value = 2.0
            slider.setValue(4, animated: false)
        }
        else {

            lblReadingSpeed.text = "\(slider.value)x"
            SharedManager.shared.readingSpeed = "\(slider.value)x"
            slider.value = Float(sValue)
        }
        
        self.lblReadingSpeed.text = "\(SharedManager.shared.readingSpeed)"
        
        self.stNarrator = SharedManager.shared.showHeadingsOnly
        if self.stNarrator == "HEADLINES_ONLY" {
            
            self.setNarratorForNews(self.btnRadioHeadOnly)
        }
        else {
            
            self.setNarratorForNews(self.btnRadioHeadBullets)
        }

        //self.performWSToUserConfig()
    }
    
    
    override func viewWillLayoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblHeadingBullets.semanticContentAttribute = .forceRightToLeft
                self.lblHeadingBullets.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblHeadingBullets.semanticContentAttribute = .forceLeftToRight
                self.lblHeadingBullets.textAlignment = .left
            }
        }
    }
    
    func setupLocalization() {
        lblTitle.text = NSLocalizedString("Audio Settings", comment: "")
        lblNarrator.text = NSLocalizedString("NARRATOR", comment: "")
        lblHeadingOnly.text = NSLocalizedString("HEADLINES ONLY", comment: "")
        lblHeadingBullets.text = NSLocalizedString("HEADLINES AND\nBULLETS", comment: "")
        lblReading.text = NSLocalizedString("READING SPEED", comment: "")
        
        self.lblHeadingBullets.semanticContentAttribute = .forceLeftToRight
    }
    
    
    
    @IBAction func didTapBackButton(_ sender: Any) {
     
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapNarrator(_ sender: UIButton) {
        
        if sender.tag == 0 {
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.headlinesOnly, eventDescription: "")
        }
        else {
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.headlinesBullets, eventDescription: "")
        }
        setNarratorForNews(sender)
        performWSToViewUpdate()
    }
    
    @IBAction func sliderReadingSpeedAction(_ sender: UISlider) {
                
        let index = Int(slider.value + 0.5)
        slider.setValue(Float(index), animated: false)
        let number = numbers[index] // <-- This numeric value you want
        print(String(format: "sliderIndex: %i", index))
        print("number: \(number)")
        
        if index == 0 {
            
            lblReadingSpeed.text = "\(number)x"
            SharedManager.shared.readingSpeed = "\(number)x"
            SharedManager.shared.localReadingSpeed = 0.5
        }
        else if index == 1 {
            
            lblReadingSpeed.text = "\(number)x"
            SharedManager.shared.readingSpeed = "\(number)x"
            SharedManager.shared.localReadingSpeed = 0.75
        }
        else if index == 2 {
            
            lblReadingSpeed.text = "\(number)x"
            SharedManager.shared.readingSpeed = "\(number)x"
            SharedManager.shared.localReadingSpeed = 1.0
        }
        else if index == 3 {
            
            lblReadingSpeed.text = "\(number)x"
            SharedManager.shared.readingSpeed = "\(number)x"
            SharedManager.shared.localReadingSpeed = 1.5
        }
        else if index == 4 {

            lblReadingSpeed.text = "\(number)x"
            SharedManager.shared.readingSpeed = "\(number)x"
            SharedManager.shared.localReadingSpeed = 2.0
        }
        else {

            lblReadingSpeed.text = "1.0x"
            SharedManager.shared.readingSpeed = "1.0x"
            SharedManager.shared.localReadingSpeed = 1.0
        }

      //  SharedManager.shared.isTabReload = true
        self .performWSToViewUpdate()

//        let roundedValue = round(sender.value / step) * step
//        sender.value = roundedValue

//        if slider.value == 0.0 {
//
//            lblReadingSpeed.text = "0.5x"
//            SharedManager.shared.readingSpeed = "0.5x"
//            SharedManager.shared.localReadingSpeed = 0.0
//        }
//        else if slider.value == 0.5 {
//
//            lblReadingSpeed.text = "0.75x"
//            SharedManager.shared.readingSpeed = "0.75x"
//            SharedManager.shared.localReadingSpeed = 0.5
//        }
//        else if slider.value == 1.5 {
//
//            lblReadingSpeed.text = "1.5x"
//            SharedManager.shared.readingSpeed = "1.5x"
//            SharedManager.shared.localReadingSpeed = 1.5
//        }
//        else if slider.value == 2.0 {
//
//            lblReadingSpeed.text = "2.0x"
//            SharedManager.shared.readingSpeed = "2.0x"
//            SharedManager.shared.localReadingSpeed = 2.0
//        }
//        else {
//
//            lblReadingSpeed.text = "\(slider.value)x"
//            SharedManager.shared.readingSpeed = "\(slider.value)x"
//            SharedManager.shared.localReadingSpeed = 1.0
//        }
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.readingSpeedClick, eventDescription: "")
    }
    
    func setNarratorForNews(_ sender: UIButton) {
        
        for button in btnCollectionNarrator {
            
            if sender.tag == button.tag {
                button.isSelected = true;
                //                button.setImage(UIImage(named: "selectMenu"), for: .normal)
            } else {
                button.isSelected = false;
                //                button.setImage(UIImage(named: "unselect"), for: .normal)
            }
        }
        
        
        let image = UIImage(named: "icn_radio_selected_light")
        let lightImage = image?.sd_tintedImage(with: Constant.appColor.blue)
        let darkImage = image?.sd_tintedImage(with: Constant.appColor.purple)
        let selectedImage = ThemeImagePicker(images: lightImage!,darkImage!)
        
        if sender == btnRadioHeadOnly {
            imgRadioHeadOnly.theme_image = selectedImage
            imgRadioHeadBullets.image = UIImage(named: "unselect")
        }
        else {
            imgRadioHeadOnly.image = UIImage(named: "unselect")
            imgRadioHeadBullets.theme_image = selectedImage
        }
        
        stNarrator = btnRadioHeadOnly.isSelected ? "HEADLINES_ONLY" : "HEADLINES_AND_BULLETS"
        SharedManager.shared.showHeadingsOnly = stNarrator
        
    }
    
    
    func performWSToUserConfig() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
                
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("user/config", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userConfigDC.self, from: response)
                
                if let preference = FULLResponse.home_preference {
      
                    if let narrMode = preference.narration?.mode {
                        
                        self.stNarrator = narrMode.uppercased()
                        SharedManager.shared.showHeadingsOnly = self.stNarrator

                        if self.stNarrator == "HEADLINES_ONLY" {
                            
                            self.setNarratorForNews(self.btnRadioHeadOnly)
                        }
                        else {
                            
                            self.setNarratorForNews(self.btnRadioHeadBullets)
                        }
                    }
      
                }
                
            } catch let jsonerror {
            
                SharedManager.shared.logAPIError(url: "user/config", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performWSToViewUpdate() {
        
        print("This is run on the background queue")
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let params = ["view_mode": "EXTENDED",
                      "narration_enabled": SharedManager.shared.isAudioEnable,
                      "narration_mode": SharedManager.shared.showHeadingsOnly,
                      "reading_speed": SharedManager.shared.localReadingSpeed,
                      "auto_scroll": 0] as [String : Any]
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("user/config/view", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(userConfigViewDC.self, from: response)
                
                if let _ = FULLResponse.message {

                    
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "user/config", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
}
