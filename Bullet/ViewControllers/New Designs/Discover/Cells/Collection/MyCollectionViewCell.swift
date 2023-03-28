//
//  MyCollectionViewCell.swift
//  NewsReels
//
//  Created by Harlene James Cruz on 5/31/22.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet var myLabel: UILabel!
    @IBOutlet var myImageView: UIImageView!
    
    static let identifier = "MyCollectionViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "MyCollectionViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func configure(with model: TrendingTopic) {
        self.myLabel.text = model.text
        self.myImageView.image = UIImage(named: model.imageName)
        self.containerView.cardView()
    }
}
