//
//  FollowingHeaderView.swift
//  Bullet
//
//  Created by Faris Muhammed on 26/05/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol FollowingHeaderViewDelegate: AnyObject {
    
    func didTapHeader(header: FollowingHeaderView)
}

class FollowingHeaderView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var loaderView: GMView!
    
    weak var delegate: FollowingHeaderViewDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("init(coder:) has not been implemented")
        self.loadFromNib()
    }
    
    
    func loadFromNib() {
        
        Bundle.main.loadNibNamed("FollowingHeaderView", owner: self)
        addSubview(contentView)
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
    }
    
    
    func setupTitle(title: String, isSelected: Bool, isLoadedShowing: Bool) {
        
        if isLoadedShowing {
            loaderView.isHidden = false
        }
        else {
            loaderView.isHidden = true
        }
        
        arrowImageView.image = UIImage(named: "RightArrowFollowing")
        titleLabel.text = title
        
        if isSelected {
            self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: .pi / 2)
        }
        else {
            self.arrowImageView.transform = CGAffineTransform.identity
        }
        
    }
    
    func animateHeader(isSelected: Bool) {
        
        if isSelected {
            if self.arrowImageView.transform != self.arrowImageView.transform.rotated(by: .pi / 2) {
                UIView.animate(withDuration: 0.25) {
                    self.arrowImageView.transform = self.arrowImageView.transform.rotated(by: .pi / 2)
                }
            }
        }
        else {
            if self.arrowImageView.transform != CGAffineTransform.identity {
                UIView.animate(withDuration: 0.25) {
                    self.arrowImageView.transform = CGAffineTransform.identity
                }
            }
        }
        
    }
    
    @IBAction func didTapHeader(_ sender: Any) {
        
        self.delegate?.didTapHeader(header: self)
    }
    
}
