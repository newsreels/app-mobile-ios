//
//  CustomOverlay.swift
//  SwiftyOnboardExample
//
//  Created by Jay on 3/27/17.
//  Copyright © 2017 Juan Pablo Fernandez. All rights reserved.
//

import UIKit
import SwiftyOnboard
import PageControls

class CustomOverlay: SwiftyOnboardOverlay {
    
    @IBOutlet weak var skip: UIButton!
    @IBOutlet weak var buttonContinue: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var pillPageControl: PillPageControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        skip.setTitle(NSLocalizedString("SKIP", comment: ""), for: .normal)
        buttonContinue.setTitle(NSLocalizedString("GET STARTED", comment: ""), for: .normal)
        buttonContinue.layer.borderWidth = 2.5
        buttonContinue.layer.borderColor = Constant.appColor.purple.cgColor
        buttonContinue.layer.cornerRadius = buttonContinue.bounds.height / 2
        buttonContinue.addTextSpacing(spacing: 2)
        skip.addTextSpacing(spacing: 2)
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomOverlay", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
}
