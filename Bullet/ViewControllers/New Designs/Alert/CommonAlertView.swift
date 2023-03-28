//
//  CommonAlertView.swift
//  Bullet
//
//  Created by Faris Muhammed on 01/03/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

class CommonAlertView: UIView {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var alertTopConstraint: NSLayoutConstraint!
    
    var isAutoDismiss: Bool = true
    var message: String = ""
    var closeButtonText = ""
    weak var delegate: AlertViewNewDelegate?
    
    enum alertType {
        case alert
        case error
    }
    var selectedUIType: alertType = .alert
    
    
    override func awakeFromNib() {
        initWithNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initWithNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initWithNib()
    }
    
    
    private func initWithNib() {
        Bundle.main.loadNibNamed("CommonAlertView", owner: self, options: nil)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        setupLayout()
        
        setLocalizations()
        setupUI()
    }
    
    
    private func setupLayout() {
        NSLayoutConstraint.activate(
            [
                containerView.topAnchor.constraint(equalTo: topAnchor),
                containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
                containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ]
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if selectedUIType == .alert {
            alertView.backgroundColor = UIColor(displayP3Red: 0.153, green: 0.682, blue: 0.376, alpha: 1)
        }
        else {
            alertView.backgroundColor = Constant.appColor.lightRed
        }
        
        self.messageLabel.text = message
    }
    
    override func didMoveToSuperview() {
        
        self.layoutIfNeeded()
        self.updateConstraintsIfNeeded()
        
        showAlert()
    }
    
    // MARK : - Methods
    func setupUI() {
        
//        alertView.alpha = 0
//        alertView.transform = CGAffineTransform(scaleX: 0, y: 0)
        self.alertTopConstraint.constant = -70
        alertView.layer.cornerRadius = 12
        
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
//        self.layoutIfNeeded()
//        self.updateConstraintsIfNeeded()
        UIView.animate(withDuration: 0.5) { [self] in
//            self.alertView.alpha = 1
//            self.alertView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.alertTopConstraint.constant = 50
            self.layoutIfNeeded()
            self.updateConstraintsIfNeeded()
        }
    }
    
    func hideAlert() {
        
        UIView.animate(withDuration: 0.5) {
//            self.alertView.transform = CGAffineTransform(scaleX: 0, y: 0)
            self.alertTopConstraint.constant = -70
            self.layoutIfNeeded()
            self.updateConstraintsIfNeeded()
        } completion: { status in
//            self.alertView.alpha = 0
            self.delegate?.alertClosedbyUser()
            self.removeFromSuperview()
        }
        
    }
    
    
    // MARK: - Actions
    @IBAction func didTapClose(_ sender: Any) {
        
        hideAlert()
        
    }
    
    
    

}
