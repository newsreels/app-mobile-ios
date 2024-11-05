//
//  FollowingTableViewCell.swift
//  Bullet
//
//  Created by Faris Muhammed on 25/05/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol FollowingTableViewCellDelegate: AnyObject {
    
    func didTapFollow(cell: FollowingTableViewCell)
}

class FollowingTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var followView: UIView!
    @IBOutlet weak var followImageView: UIImageView!
    
    weak var delegate: FollowingTableViewCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        followView.backgroundColor = Constant.appColor.followBackgroundColor
        menuImageView.backgroundColor = Constant.appColor.lightGray
        
    }
    
    
    override func prepareForReuse() {
        
        followView.hideLoaderView()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func layoutSubviews() {
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
        followView.layer.cornerRadius = followView.frame.size.height/2
        menuImageView.layer.cornerRadius = menuImageView.frame.size.height/4
    }
    
    func setupCell(title: String, image: String, isFollow: Bool, isShowingLoader: Bool) {
        
        titleLabel.text = title
        
        menuImageView.image = nil
        menuImageView.sd_setImage(with: URL(string: image), placeholderImage: nil)
        
        
        if isFollow {
            followImageView.image = UIImage(named: "FollowTick")
        }
        else {
            followImageView.image = UIImage(named: "FollowPlus")

        }
        
        
        if isShowingLoader {
            followView.showLoader(size: CGSize(width: 15, height: 15),color: Constant.appColor.lightRed, padding: 0)
            followImageView.isHidden = true
        }
        else {
            followView.hideLoaderView()
            followImageView.isHidden = false
        }
        
    }
    
    @IBAction func didTapFollow(_ sender: Any) {
        
        self.delegate?.didTapFollow(cell: self)
    }
    
}
