//
//  BlockAlertVC.swift
//  Bullet
//
//  Created by Mahesh on 10/10/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

@objc protocol BlockAlertVCDelegate {
    
    @objc optional func delegateBlockAlertVCBlockForId(_ id: String, isFrom: String)
    //@objc optional func delegateBlockAlertVCBlockForSource(_ id: String)
}

class BlockAlertVC: UIViewController {

    weak var delegate: BlockAlertVCDelegate?
    var isFromBlock = ""
    var id = ""
    var name = ""

    //View Block Alert
    @IBOutlet weak var viewBlockAlertBG: UIView!
    @IBOutlet weak var lblBlockTitle: UILabel!
    @IBOutlet weak var lblBlockMessage: UILabel!
    @IBOutlet weak var btnBlock: UIButton!
    @IBOutlet weak var btnBlockCancel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //LOCALIZABLE STRING
        lblBlockTitle.text = "\(NSLocalizedString("Block", comment: "")) \(name)"
        lblBlockMessage.text = "\(NSLocalizedString("Are you sure you want block", comment: "")) \(name)? \(NSLocalizedString("Once blocked, you wont be able to see any Articles related to this", comment: "")) \(isFromBlock)."
        btnBlock.setTitle(NSLocalizedString("BLOCK", comment: ""), for: .normal)
        btnBlockCancel.setTitle(NSLocalizedString("CANCEL", comment: ""), for: .normal)
        
        //View Block Design
        viewBlockAlertBG.theme_backgroundColor = GlobalPicker.tabBarTintColor
        btnBlockCancel.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
        btnBlock.addTextSpacing(spacing: 2.5)
        btnBlockCancel.addTextSpacing(spacing: 2.5)
        lblBlockTitle.theme_textColor = GlobalPicker.textColor
        lblBlockMessage.setLineSpacing(lineSpacing: 5)
        
    }

    @IBAction func didTapBlock(_ sender: Any) {
        
        self.dismiss(animated: true) {
            self.delegate?.delegateBlockAlertVCBlockForId?(self.id, isFrom: self.isFromBlock)
        }
    }
    
    @IBAction func didTapClose(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
}
