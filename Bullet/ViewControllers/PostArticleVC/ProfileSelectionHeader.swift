//
//  ProfileSelectionHeader.swift
//  Bullet
//
//  Created by Faris Muhammed on 20/06/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class ProfileSelectionHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    
    
    
    
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
