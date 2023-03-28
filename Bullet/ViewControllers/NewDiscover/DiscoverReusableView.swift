//
//  DiscoverReusableView.swift
//  Bullet
//
//  Created by Faris Muhammed on 08/09/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit


protocol DiscoverReusableViewDelegate: AnyObject {
    
    func didTapSearchHeader()
    
}

class DiscoverReusableView: UICollectionReusableView {
        
    weak var delegate: DiscoverReusableViewDelegate?
    
    
    @IBAction func didTapSeach(_ sender: Any) {
        
        self.delegate?.didTapSearchHeader()
        
    }
    
    
}
