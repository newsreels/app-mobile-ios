//
//  TutorialVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 14/03/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol TutorialVCDelegate: AnyObject {
    
    func userDismissed(vc: TutorialVC)
}

class TutorialVC: UIViewController {

    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    weak var delegate: TutorialVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        self.navigationController?.presentationController?.delegate = self
        self.presentationController?.delegate = self

    }
    
    // MARK: - Methods
    func setupUI() {
        
        continueButton.backgroundColor = Constant.appColor.lightRed

        continueButton.layer.cornerRadius = 15
        
        continueButton.setTitleColor(.white, for: .normal)
        
        continueButton.setTitle(NSLocalizedString("Ok, got it!", comment: ""), for: .normal)
        
        title1Label.text = NSLocalizedString("Swipe up for discovering more", comment: "")
        title2Label.text = NSLocalizedString("Many reels for you to explore in a simple move", comment: "")
        
    }

   
    // MARK: - Actions
    
    @IBAction func didTapClose(_ sender: Any) {
        
        self.delegate?.userDismissed(vc: self)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didTapContinue(_ sender: Any) {
    
        didTapClose(sender)
    }

}

extension TutorialVC: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
        self.delegate?.userDismissed(vc: self)
    }
}

