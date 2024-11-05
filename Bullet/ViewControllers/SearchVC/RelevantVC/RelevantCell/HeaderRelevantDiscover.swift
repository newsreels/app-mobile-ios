//
//  HeaderRelevantDiscover.swift
//  Bullet
//
//  Created by Faris Muhammed on 19/05/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class HeaderRelevantDiscover: UITableViewHeaderFooterView {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func layoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
            }
        }
    }
    
}
