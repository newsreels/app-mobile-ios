//
//  SuggestedSourcesCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 04/04/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol SuggestedSourcesCCDelegate: AnyObject {
    func didTapFollowing(cell: SuggestedSourcesCC)
}


class SuggestedSourcesCC: UICollectionViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    weak var delegate: SuggestedSourcesCCDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        
        userImageView.cornerRadius = userImageView.frame.size.width/2
        followButton.cornerRadius = 12
        
    }
    
    func setupCell(model: ChannelInfo) {
        
        userImageView.sd_setImage(with: URL(string: model.image ?? "") , placeholderImage: nil)
        
        nameLabel.text = model.name?.trim()
        usernameLabel.text = "@\(model.name ?? "")"
        usernameLabel.isHidden = (usernameLabel.text == "") ? true : false
        
        
        let fav = model.favorite ?? false
        if fav {
            followButton.setTitle("Following", for: .normal)
            followButton.backgroundColor = Constant.appColor.lightGray
            followButton.setTitleColor(Constant.appColor.darkGray, for: .normal)
        }
        else {
            followButton.setTitle("Follow", for: .normal)
            followButton.backgroundColor = Constant.appColor.lightRed
            followButton.setTitleColor(.white, for: .normal)
            
        }
        
        if model.isShowingLoader ?? false {
            self.isUserInteractionEnabled = false
            followButton.showLoader()
        }
        else {
            self.isUserInteractionEnabled = true
            followButton.hideLoaderView()
        }
        
    }
    
    
    // MARK:- Actions
    @IBAction func didTapFollowButton(_ sender: Any) {
        
        
//        followButton.showLoader()
        self.delegate?.didTapFollowing(cell: self)
    }
    

}
