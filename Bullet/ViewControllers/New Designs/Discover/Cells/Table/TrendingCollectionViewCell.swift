//
//  TrendingCollectionViewCell.swift
//  NewsReels
//
//  Created by jhude lapuz on 6/2/22.
//

import UIKit

class TrendingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var photoViewRS: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var rankNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        photoView.layer.cornerRadius = photoView.frame.height  / 2.0
        photoViewRS.layer.cornerRadius = photoViewRS.frame.height  / 2.0
        containerView.cardView()
//        containerView.layer.borderWidth = 0.2
//        containerView.layer.cornerRadius = 10
//        containerView.layer.borderColor = UIColor.gray.cgColor
        //top corner
        //containerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        //bottom corner
       // containerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]

//        containerView.layer.shadowOffset = CGSize(width: 10, height: 10)
//        containerView.layer.shadowRadius = 5
//        containerView.layer.shadowOpacity = 0.3
    }
}
