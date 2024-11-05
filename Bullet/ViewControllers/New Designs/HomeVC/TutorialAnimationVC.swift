//
//  TutorialAnimationVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 11/02/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

public enum continueButtonState: Int {
    
    case Continue
    case LearnMore
    case GotIt
}

class TutorialAnimationVC: UIViewController {
    
    //Animation view Outlets and varibale
    @IBOutlet weak var viewContainerAnimation: UIView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var lblIntro: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintTutorialAnimationHeight: NSLayoutConstraint!
    
    @IBOutlet weak var imgContinueHandGif: UIImageView!
    @IBOutlet weak var imgRightHandGif: UIImageView!
    @IBOutlet weak var imgLeftHandGif: UIImageView!
    @IBOutlet weak var imgScrollGif: UIImageView!
    
    @IBOutlet weak var btnRightHand: UIButton!
    @IBOutlet weak var btnLeftHand: UIButton!
    var continueCurrState: continueButtonState = .Continue
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadUserToturialView()
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.tutorialStart, eventDescription: "")
    }
    
    func loadUserToturialView() {
        
        self.viewContent.theme_backgroundColor = GlobalPicker.backgroundColor
        self.viewContent.layer.cornerRadius = 12
        self.viewContent.layer.borderWidth = 2.0
        self.lblIntro.theme_textColor = GlobalPicker.textBWColor
        self.btnContinue.theme_backgroundColor = GlobalPicker.btnSelectedTabbarTintColor
        self.viewContent.layer.masksToBounds = true
        self.viewContainerAnimation.isHidden = false
        self.btnContinue.isHidden = true
        self.contentViewHeight.constant = 170.0
        
        if MyThemes.current == .dark {
      
            self.btnLeftHand.tintColor = .white
            self.btnRightHand.tintColor = .white
            self.viewContent.layer.borderColor = "#3AD9D2".hexStringToUIColor().cgColor
        }
        else {

            self.btnLeftHand.tintColor = .black
            self.btnRightHand.tintColor = .black
            self.viewContent.layer.borderColor = "#FA0815".hexStringToUIColor().cgColor
        }
        self.view.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            
            self.lblIntro.text = "Explore the\nNewsreels\n in 3 simple steps"
            self.setInitialAnimationView()
            self.view.isOpaque = false
        }
    }
    
    func setInitialAnimationView() {
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.8, animations: {
            
            self.viewContent.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            self.view.layoutIfNeeded()
            
        }) { (finished) in
            UIView.animate(withDuration: 0.4, animations: {
                
                self.view.layoutIfNeeded()
                
                self.imgContinueHandGif.isHidden = false
                self.imgContinueHandGif.loadGif(name: "continueHand")
                self.btnContinue.isHidden = false
            })
        }
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
        
        if continueCurrState == .Continue {
            
            self.view.layoutIfNeeded()
            self.lblIntro.text = ""
            self.imgContinueHandGif.isHidden = true
            self.imgContinueHandGif.stopAnimating()
            self.btnContinue.isHidden = true
            UIView.animate(withDuration: 0.8, delay: 0, animations: {
                
                self.contentViewHeight.constant = 62.0
                self.view.layoutIfNeeded()
                
            }) { (finished) in
                UIView.animate(withDuration: 0.4, animations: {
                    
                    self.lblIntro.text = "Tap to view next"
                    self.imgRightHandGif.isHidden = false
                    self.imgRightHandGif.loadGif(name: "continueHand")
                    self.btnRightHand.isHidden = false
                    
                })
            }
        }
        else if continueCurrState == .LearnMore {
            
            continueCurrState = .GotIt
            let height = self.view.frame.size.height - (self.view.frame.size.height / 4)
            self.view.layoutIfNeeded()
            self.lblIntro.isHidden = true
            self.btnContinue.isHidden = true
            UIView.animate(withDuration: 0.8, animations: {
                
                self.contentViewHeight.constant = height
                self.view.layoutIfNeeded()
                
            }) { (finished) in
                UIView.animate(withDuration: 0.4, animations: {
                    
                    self.view.layoutIfNeeded()
                    
                    self.imgScrollGif.isHidden = false
                    self.imgScrollGif.loadGif(name: "Scroll")
                    self.btnContinue.setTitle("GOT IT", for: .normal)
                    self.btnContinue.isHidden = false
                })
            }
        }
        else if continueCurrState == .GotIt {
            
            self.performWSToViewUpdate(true)
            self.viewContainerAnimation.isHidden = true
        }
    }
    
    @IBAction func didTapRightHand(_ sender: Any) {
        
        self.view.layoutIfNeeded()
        NotificationCenter.default.post(name: Notification.Name.notifyTapRightTutorial, object: nil)
        UIView.animate(withDuration: 0.8, delay: 0, animations: {
            
            self.lblIntro.text = ""
            self.imgRightHandGif.isHidden = true
            self.imgRightHandGif.stopAnimating()
            self.btnRightHand.isHidden = true
            
        }) { (finished) in
            UIView.animate(withDuration: 0.4, animations: {
                
                self.lblIntro.text = "Tap to view Previous"
                self.imgLeftHandGif.isHidden = false
                self.imgLeftHandGif.loadGif(name: "continueHand")
                self.btnLeftHand.isHidden = false
                
            })
        }
    }
    
    @IBAction func didTapLeftHand(_ sender: Any) {
        
        self.view.layoutIfNeeded()
        continueCurrState = .LearnMore
        NotificationCenter.default.post(name: Notification.Name.notifyTapLeftTutorial, object: nil)
        
        self.performWSToViewUpdate(true)
        UIView.animate(withDuration: 0.8, delay: 0, animations: {
            
            self.lblIntro.text = ""
            self.imgLeftHandGif.isHidden = true
            self.imgLeftHandGif.stopAnimating()
            self.btnLeftHand.isHidden = true
            
        }) { (finished) in
            UIView.animate(withDuration: 0.4, animations: {
                
                self.viewContainerAnimation.isHidden = true
//                self.lblIntro.text = "Change view mode"
//                self.btnContinue.setTitle("LEARN MORE", for: .normal)
//                self.btnContinue.isHidden = false
            })
        }
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.tutorialStart, eventDescription: "")
    }
    
    func performWSToViewUpdate(_ isTutorialDone:Bool) {
        
        let params = ["tutorial_done": isTutorialDone]
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("user/config/view", method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                _ = try
                    JSONDecoder().decode(userConfigViewDC.self, from: response)
                
                self.dismiss(animated: false, completion: nil)
                SharedManager.shared.isTutorialDone = true
                
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "user/config/view", error: jsonerror.localizedDescription, code: "")

            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
}
