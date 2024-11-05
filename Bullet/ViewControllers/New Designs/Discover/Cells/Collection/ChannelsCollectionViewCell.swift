//
//  ChannelsCollectionViewCell.swift
//  NewsReels2.0
//
//  Created by Harlene James Cruz on 6/3/22.
//

import UIKit

class ChannelsCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageName: UIImageView!
    @IBOutlet var myLabel: UILabel!
    @IBOutlet var plusImage: UIImageView!
    @IBOutlet var containerView: UIView!
    
    static let identifier = "ChannelsCollectionViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ChannelsCollectionViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func configure(with model: Channel) {
        self.imageName.image = UIImage(named: model.imageName)
        self.myLabel.text = model.text
        self.plusImage.image = UIImage(named: model.plusImageName)
//        self.containerView.cardView()
    }
}
