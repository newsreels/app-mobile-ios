//
//  AuthorsFollowingCell.swift
//  Bullet
//
//  Created by Khadim Hussain on 07/09/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol AuthorsFollowingCellDelegate: AnyObject {
    
    func didTapFollow(cell: AuthorsFollowingCell)
}

class AuthorsFollowingCell: UICollectionViewCell {

    @IBOutlet weak var authorView: UIView!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgAuthor: UIImageView!
    @IBOutlet weak var lblAuthorName: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    
    weak var delegate: AuthorsFollowingCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgAuthor.cornerRadius = imgAuthor.frame.height / 2
        authorView.cornerRadius = 10
        btnFollow.cornerRadius = 12
    }
    
    func setupCell(model: Author) {
        
        imgAuthor.sd_setImage(with: URL(string: model.profile_image ?? "") , placeholderImage: nil)
        
        let name = "\(model.first_name ?? "")" + " " + "\(model.last_name ?? "")"
        lblAuthorName.text = name.trim()
        usernameLabel.text = model.username ?? ""
        
        let fav = model.favorite ?? false
        if fav {
            btnFollow.setTitle("Following", for: .normal)
            btnFollow.backgroundColor = Constant.appColor.lightGray
            btnFollow.setTitleColor(Constant.appColor.darkGray, for: .normal)
        }
        else {
            btnFollow.setTitle("Follow", for: .normal)
            btnFollow.backgroundColor = Constant.appColor.lightRed
            btnFollow.setTitleColor(.white, for: .normal)
            
        }
        
        if model.isShowingLoader ?? false {
            self.isUserInteractionEnabled = false
            btnFollow.showLoader()
        }
        else {
            self.isUserInteractionEnabled = true
            btnFollow.hideLoaderView()
        }
    }
    
    func setupCell(model: ChannelInfo) {
        
        imgAuthor.sd_setImage(with: URL(string: model.image ?? "") , placeholderImage: nil)
        
        let name = model.name ?? ""
        lblAuthorName.text = name.trim()
        usernameLabel.text = "@\(name)"
        
        let fav = model.favorite ?? false
        if fav {
            btnFollow.setTitle("Following", for: .normal)
            btnFollow.backgroundColor = Constant.appColor.lightGray
            btnFollow.setTitleColor(Constant.appColor.darkGray, for: .normal)
        }
        else {
            btnFollow.setTitle("Follow", for: .normal)
            btnFollow.backgroundColor = Constant.appColor.lightRed
            btnFollow.setTitleColor(.white, for: .normal)
            
        }
        
        if model.isShowingLoader ?? false {
            self.isUserInteractionEnabled = false
            btnFollow.showLoader()
        }
        else {
            self.isUserInteractionEnabled = true
            btnFollow.hideLoaderView()
        }
    }
    
    func setupCellForBlockList(model: ChannelInfo) {
        
        imgAuthor.sd_setImage(with: URL(string: model.image ?? "") , placeholderImage: nil)
        
        let name = model.name ?? ""
        lblAuthorName.text = name.trim()
        usernameLabel.text = "@\(name)"
        
        let block = model.isUserBlocked ?? false
        if block {
            btnFollow.setTitle("Unblock", for: .normal)
            btnFollow.backgroundColor = Constant.appColor.lightGray
            btnFollow.setTitleColor(Constant.appColor.darkGray, for: .normal)
        }
        else {
            btnFollow.setTitle("Block", for: .normal)
            btnFollow.backgroundColor = Constant.appColor.lightRed
            btnFollow.setTitleColor(.white, for: .normal)
        }
        
        if model.isShowingLoader ?? false {
            self.isUserInteractionEnabled = false
            btnFollow.showLoader()
        }
        else {
            self.isUserInteractionEnabled = true
            btnFollow.hideLoaderView()
        }
    }
    
    
    
    @IBAction func didTapFollow(_ sender: Any) {
        btnFollow.showLoader()
        self.delegate?.didTapFollow(cell: self)
    }
    
}
