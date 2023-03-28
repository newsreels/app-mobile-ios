//
//  AlertViewNew.swift
//  Bullet
//
//  Created by Faris Muhammed on 14/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol AlertViewNewDelegate: AnyObject {
    func alertClosedbyUser()
}

class AlertViewNew: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var isAutoDismiss: Bool = true
    var message: String = ""
    var closeButtonText = ""
    weak var delegate: AlertViewNewDelegate?
    enum alertType {
        case alert
        case error
    }
    var selectedUIType: alertType = .alert
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setLocalizations()
        setupUI()
        
        showAlert()
    }
    
    
    // MARK: - Methods
    func setupUI() {
        
        alertView.alpha = 0
        alertView.transform = CGAffineTransform(scaleX: 0, y: 0)

        alertView.layer.cornerRadius = 12
        
        if selectedUIType == .alert {
            alertView.backgroundColor = UIColor(displayP3Red: 0.153, green: 0.682, blue: 0.376, alpha: 1)
        }
        else {
            alertView.backgroundColor = Constant.appColor.lightRed
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if self.isAutoDismiss {
                self.didTapClose(UIButton())
            }
        }
    }
    
    func setLocalizations() {
        
        if closeButtonText == "" {
            closeButton.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
        }
        else {
            closeButton.setTitle(NSLocalizedString("\(closeButtonText)", comment: ""), for: .normal)
        }
        

    }
    
    func showAlert() {
        self.messageLabel.text = message
        UIView.animate(withDuration: 0.5) { [self] in
            self.alertView.alpha = 1
            self.alertView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.view.layoutIfNeeded()
        }
    }
    
    func hideAlert() {
        
        UIView.animate(withDuration: 0.5) {
            self.alertView.alpha = 0
            self.alertView.transform = CGAffineTransform(scaleX: 0, y: 0)
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    // MARK: - Actions
    @IBAction func didTapClose(_ sender: Any) {
        
        hideAlert()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.delegate?.alertClosedbyUser()
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
}
