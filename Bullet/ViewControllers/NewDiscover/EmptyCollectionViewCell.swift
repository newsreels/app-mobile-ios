//
//  EmptyCollectionViewCell.swift
//  Bullet
//
//  Created by Faris Muhammed on 08/09/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class EmptyCollectionViewCell: UICollectionReusableView {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    weak var delegate: DiscoverReusableViewDelegate?
    
    @IBOutlet weak var searchContainerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
//        lblTitle.text = NSLocalizedString("Discover", comment: "")
//        lblSubTitle.text = NSLocalizedString("Articles, topics, channels, authors", comment: "")
        
        searchContainerView.layer.cornerRadius = 8

        searchContainerView.layer.borderWidth = 1

        searchContainerView.layer.borderColor = UIColor(red: 0.871, green: 0.908, blue: 0.95, alpha: 1).cgColor
        
        
        lblSubTitle.textColor = Constant.appColor.lightGray
    }
    
    
    
    @IBAction func didTapSearch(_ sender: Any) {
        
        self.delegate?.didTapSearchHeader()
    }
    
    
    override func layoutSubviews() {
        
        
        DispatchQueue.main.async {
            
            if SharedManager.shared.isSelectedLanguageRTL() {
                
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
                self.lblSubTitle.semanticContentAttribute = .forceRightToLeft
                self.lblSubTitle.textAlignment = .right
                
            } else {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
                self.lblSubTitle.semanticContentAttribute = .forceLeftToRight
                self.lblSubTitle.textAlignment = .left
            }
            
        }
        
        
    }
    
}
