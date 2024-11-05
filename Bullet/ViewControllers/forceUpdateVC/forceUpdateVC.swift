//
//  forceUpdateVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 19/11/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class forceUpdateVC: UIViewController {

    @IBOutlet weak var buttonContinue: UIButton!
    @IBOutlet weak var lblUpdateDescription: UILabel!
    
    @IBOutlet weak var lblTimeToUpdate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalization()
        
        buttonContinue.layer.borderWidth = 2.5
        buttonContinue.layer.borderColor = Constant.appColor.purple.cgColor
        buttonContinue.layer.cornerRadius = buttonContinue.bounds.height / 2
        buttonContinue.addTextSpacing(spacing: 2)
        
    }
    
    
    func setupLocalization() {
        lblTimeToUpdate.text = NSLocalizedString("Time To Update!", comment: "")
        lblUpdateDescription.text = NSLocalizedString("We added lots of new features and fix some bugs to make your experience as smooth as possible.", comment: "")
        buttonContinue.setTitle(NSLocalizedString("UPDATE APP", comment: ""), for: .normal)
    }
    
    
    @IBAction func didTapUpdate(_ sender: Any) {
        
        if let url = URL(string: "itms-apps://apple.com/app/1540932937") {
            UIApplication.shared.open(url)
        }
    }
}
