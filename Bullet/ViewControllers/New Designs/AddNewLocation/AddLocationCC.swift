//
//  AddLocationCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 22/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

//protocol AddLocationCCDelgate: AnyObject {
//
//    func didSelectCell(cell: AddLocationCC)
//}

class AddLocationCC: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var tagimageView: UIImageView!
//    @IBOutlet weak var pinView: UIView!
    
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var closeButtonView: UIView!
    @IBOutlet weak var closeImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        pinView.layer.cornerRadius =  pinView.frame.size.width/2
//        pinView.backgroundColor = Constant.appColor.lightGray
        
        locationImageView.backgroundColor = Constant.appColor.lightGray
        
        
    }

    override func layoutSubviews() {
        
        locationImageView.layer.cornerRadius =  locationImageView.frame.size.width/2
        closeButtonView.layer.cornerRadius =  closeButtonView.frame.size.width/2
        
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCellLocations(loc: Location) {
        
        
        self.locationImageView.sd_setImage(with: URL(string: loc.image ?? "") , placeholderImage: nil)
        
        
        if loc.favorite ?? false {
            self.closeImageView.image = UIImage(named: "FavouriteStar")
            self.closeButtonView.backgroundColor = .white
            self.closeButtonView.layer.borderWidth = 1
            self.closeButtonView.layer.borderColor = Constant.appColor.lightGray.cgColor
            
            self.locationImageView.layer.borderWidth = 1.5
            self.locationImageView.layer.borderColor = Constant.appColor.lightGray.cgColor
            
        }
        else {
            self.closeImageView.image = UIImage(named: "FavouritePlus")
            self.closeButtonView.backgroundColor = Constant.appColor.lightRed
            self.closeButtonView.layer.borderWidth = 1
            self.closeButtonView.layer.borderColor = Constant.appColor.lightGray.cgColor
            
            self.locationImageView.layer.borderWidth = 1.5
            self.locationImageView.layer.borderColor = Constant.appColor.lightGray.cgColor
        }
        
        
        titleLabel.text = loc.name ?? "" 
    }
    
}
