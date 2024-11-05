//
//  OnboardVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 01/11/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import SwiftyOnboard
import FirebaseAnalytics

class OnboardVC: UIViewController {

    @IBOutlet weak var swiftyOnboard: SwiftyOnboard!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        swiftyOnboard.style = .dark
        swiftyOnboard.delegate = self
        swiftyOnboard.dataSource = self
    }
    
    @objc func handleSkip() {
        
        SharedManager.shared.isAppOnboardScreensLoaded = true
        appDelegate.setLoginVC()
    }
    
    @objc func handleContinue(sender: UIButton) {
        
        SharedManager.shared.isAppOnboardScreensLoaded = true
        appDelegate.setLoginVC()
    }
    
    @objc func handleNext(sender: UIButton) {

        let index = sender.tag
        swiftyOnboard?.goToPage(index: index + 1, animated: true)
    }
}

extension OnboardVC: SwiftyOnboardDelegate, SwiftyOnboardDataSource {
    
    func swiftyOnboardNumberOfPages(_ swiftyOnboard: SwiftyOnboard) -> Int {
        
        return 3
    }
    
    func swiftyOnboardPageForIndex(_ swiftyOnboard: SwiftyOnboard, index: Int) -> SwiftyOnboardPage? {
        let view = CustomPage.instanceFromNib() as? CustomPage
        view?.image.image = UIImage(named: "space\(index).png")
        if index == 0 {
            
            view?.titleLabel.text = NSLocalizedString("Fuel your curiosity", comment: "")
            view?.subTitleLabel.text = NSLocalizedString("Get clutter-free news about your\nfavorite topics from trusted sources\naround the world.", comment: "")
        } else if index == 1 {
            
            view?.titleLabel.text = NSLocalizedString("Save time", comment: "")
            view?.subTitleLabel.text = NSLocalizedString("Read the news in bullet form to\nshorten a 5-minute read into just a\nfew seconds.", comment: "")
        } else {
            
            view?.titleLabel.text = NSLocalizedString("Hands-free reading", comment: "")
            view?.subTitleLabel.text = NSLocalizedString("No time to read? Use our intuitive\ntext-to-speech feature.", comment: "")
        }
        view?.subTitleLabel.setLineSpacing(lineSpacing: 7)
        view?.subTitleLabel.textAlignment = .center
        
        return view
    }
    
    func swiftyOnboardViewForOverlay(_ swiftyOnboard: SwiftyOnboard) -> SwiftyOnboardOverlay? {
        let overlay = CustomOverlay.instanceFromNib() as? CustomOverlay
        overlay?.skip.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        overlay?.buttonContinue.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        overlay?.buttonNext.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return overlay
    }
    
    func swiftyOnboardOverlayForPosition(_ swiftyOnboard: SwiftyOnboard, overlay: SwiftyOnboardOverlay, for position: Double) {
        let overlay = overlay as! CustomOverlay
        let currentPage = round(position)
        overlay.buttonNext.tag = Int(position)
        
        if currentPage == 0.0 || currentPage == 1.0 {
            
            overlay.buttonNext.isHidden = false
            overlay.skip.isHidden = false
            overlay.buttonContinue.isHidden = true
   
        } else {
            
            overlay.buttonNext.isHidden = true
            overlay.skip.isHidden = true
            overlay.buttonContinue.isHidden = false
        }
        
        overlay.pillPageControl.progress = CGFloat(currentPage)
    }
}
