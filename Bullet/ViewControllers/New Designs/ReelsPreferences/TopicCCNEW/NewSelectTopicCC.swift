//
//  NewSelectTopicCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 11/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol NewSelectTopicCCDelegate: AnyObject {
    func didTapClose(cell: NewSelectTopicCC)
}
class NewSelectTopicCC: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundRoundView: UIView!
    @IBOutlet weak var contentBackgroundView: UIView!
//    @IBOutlet weak var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButtonView: UIView!
    @IBOutlet weak var closeImageView: UIImageView!
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var imageViewTopic: UIImageView!
    
    @IBOutlet weak var closeImageContainer: UIView!
    
    
    weak var delegate: NewSelectTopicCCDelegate?
    var isShowingTrending = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        addShadow()
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        addShadow()
    }
    
    func addShadow() {
        
        closeImageContainer.layer.cornerRadius = closeImageContainer.frame.size.width/2
        imageViewTopic.layer.cornerRadius = imageViewTopic.frame.size.width/2
        backgroundRoundView.layer.cornerRadius = 10
//        backgroundRoundView.layer.masksToBounds = true
        
        contentBackgroundView.layer.cornerRadius = 10
//        let shadowPath2 = UIBezierPath(rect: contentBackgroundView.bounds)
//        contentBackgroundView.layer.masksToBounds = false
//        contentBackgroundView.layer.shadowColor = UIColor.black.cgColor
//        contentBackgroundView.layer.shadowOffset = CGSize(width: CGFloat(1.0), height: CGFloat(3.0))
//        contentBackgroundView.layer.shadowOpacity = 0.5
//        contentBackgroundView.layer.shadowPath = shadowPath2.cgPath
    }
    
    func setupCell(topic: TopicData, isShowingTrending: Bool) {
        
        backgroundRoundView.backgroundColor = .clear
        self.imageViewTopic.sd_setImage(with: URL(string: topic.image ?? "") , placeholderImage: nil)

        self.isShowingTrending = isShowingTrending
        self.titleLabel.text =  "\(topic.name ?? "")"
        
        titleLabel.textColor = .black
        
        if (topic.isShowingLoader ?? false) {
            
            if topic.favorite ?? false {
                AddButton.showLoader(color: Constant.appColor.lightRed)
            }
            else {
                AddButton.showLoader()
            }
        }
        else {
            AddButton.hideLoaderView()
        }
        if topic.favorite ?? false {
            
            self.closeImageView.image = UIImage(named: "FavouriteStar")
            self.closeImageContainer.backgroundColor = .white
            self.closeImageContainer.layer.borderWidth = 1
            self.closeImageContainer.layer.borderColor = Constant.appColor.lightGray.cgColor
            
            self.imageViewTopic.layer.borderWidth = 1.5
            self.imageViewTopic.layer.borderColor = Constant.appColor.lightGray.cgColor
        }
        else {
            
            self.closeImageView.image = UIImage(named: "FavouritePlus")
            self.closeImageContainer.backgroundColor = Constant.appColor.lightRed
            self.closeImageContainer.layer.borderWidth = 1
            self.closeImageContainer.layer.borderColor = Constant.appColor.lightGray.cgColor
            
            self.imageViewTopic.layer.borderWidth = 1.5
            self.imageViewTopic.layer.borderColor = Constant.appColor.lightGray.cgColor
        }
        
        self.addShadow()
        
        self.updateConstraintsIfNeeded()
        self.layoutIfNeeded()
        
        
    }
    
    func setupCell(location: Location, isSelected: Bool) {
        
        backgroundRoundView.backgroundColor = .clear
        self.imageViewTopic.sd_setImage(with: URL(string: location.image ?? "") , placeholderImage: nil)

//        self.isShowingTrending = isShowingTrending
        self.titleLabel.text =  "\(location.name ?? "")"
        
        titleLabel.textColor = .black
        
        if (location.isShowingLoader ?? false) {
            if location.favorite ?? false {
                AddButton.showLoader(color: Constant.appColor.lightRed)
            }
            else {
                AddButton.showLoader()
            }
        }
        else {
            AddButton.hideLoaderView()
        }
        
        if location.favorite ?? false {
            
            self.closeImageView.image = UIImage(named: "FavouriteStar")
            self.closeImageContainer.backgroundColor = .white
            self.closeImageContainer.layer.borderWidth = 1
            self.closeImageContainer.layer.borderColor = Constant.appColor.lightGray.cgColor
            
            self.imageViewTopic.layer.borderWidth = 1.5
            self.imageViewTopic.layer.borderColor = Constant.appColor.lightGray.cgColor
        }
        else {
            
            self.closeImageView.image = UIImage(named: "FavouritePlus")
            self.closeImageContainer.backgroundColor = Constant.appColor.lightRed
            self.closeImageContainer.layer.borderWidth = 1
            self.closeImageContainer.layer.borderColor = Constant.appColor.lightGray.cgColor
            
            self.imageViewTopic.layer.borderWidth = 1.5
            self.imageViewTopic.layer.borderColor = Constant.appColor.lightGray.cgColor
        }
        self.addShadow()
        
        self.updateConstraintsIfNeeded()
        self.layoutIfNeeded()
        
        
    }
    
    
            
    func setupAddOtherCell() {
        self.titleLabel.text =  "Add"
        self.closeImageView.image = UIImage(named: "AddTag")
        
        self.backgroundRoundView.backgroundColor = Constant.appColor.lightRed
        titleLabel.textColor = .white
//        titleTrailingConstraint.constant = 35
        closeButtonView.isHidden = false
        
        self.addShadow()
        
        self.updateConstraintsIfNeeded()
        self.layoutIfNeeded()
    }
    
    @IBAction func didTapRemove(_ sender: Any) {
        
        
        self.delegate?.didTapClose(cell: self)
    }
    
    
}
