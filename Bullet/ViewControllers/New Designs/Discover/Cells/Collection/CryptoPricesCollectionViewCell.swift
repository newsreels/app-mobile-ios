//
//  CryptoPricesCollectionViewCell.swift
//  NewsReels2.0
//
//  Created by Harlene James Cruz on 6/1/22.
//

import UIKit

class CryptoPricesCollectionViewCell: UICollectionViewCell {

    @IBOutlet var containerView: UIView!
    @IBOutlet var myLabel: UILabel!
    @IBOutlet var myImageView: UIImageView!
    @IBOutlet var myPercentageLabel: UILabel!
    @IBOutlet var myValueLabel: UILabel!
    @IBOutlet var myArrowImage: UIImageView!
    
    static let identifier = "CryptoPricesCollectionViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "CryptoPricesCollectionViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(with model: CryptoPrice) {
        self.myLabel.text = model.text
        self.myImageView.image = UIImage(named: model.imageName)
        self.myPercentageLabel.text = model.percentage
        self.myValueLabel.text = model.value
        self.myArrowImage.image = UIImage(named: model.arrowImageName)
        self.containerView.cardView()
    }

}


