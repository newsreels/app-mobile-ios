//
//  AuthorDiscCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 31/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol AuthorDiscCCDelegate: AnyObject {
    
    func didTapFollow(cell: AuthorDiscCC)
}
class AuthorDiscCC: UICollectionViewCell {

    @IBOutlet weak var imgAuthor: UIImageView!
    @IBOutlet weak var imgFollowing: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    weak var delegate: AuthorDiscCCDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        updateCorner()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        updateCorner()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateCorner()
    }
    
    func updateCorner() {
        self.layoutIfNeeded()
        imgAuthor.layer.cornerRadius =  imgAuthor.frame.size.width/2
        imgAuthor.clipsToBounds = true
        imgAuthor.layer.masksToBounds = true
    }
    
    
    func setupCell(model: Author?) {
        
        self.layoutIfNeeded()
        imgAuthor.image = nil
        imgAuthor.sd_setImage(with: URL(string: model?.profile_image ?? "") , placeholderImage: UIImage(named: "icn_placeholder_dark"))
        imgAuthor.layoutIfNeeded()
        let name = "\(model?.first_name ?? "")" + " " +   "\(model?.last_name ?? "")"
        lblName.text = name.trim()
        let fav = model?.favorite ?? false
        imgFollowing.image = fav ? UIImage(named: "tickUnselected") : UIImage(named: "plus_dark")
        updateCorner()
    }
    
    
    @IBAction func didTapAddAuthor(_ sender: Any) {
        
        self.delegate?.didTapFollow(cell: self)
    }
    
}
