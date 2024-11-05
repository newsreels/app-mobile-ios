//
//  SelectTopicCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 11/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol SelectTopicCCDelegate: AnyObject {
    func didTapClose(cell: SelectTopicCC)
}
class SelectTopicCC: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundRoundView: UIView!
    @IBOutlet weak var contentBackgroundView: UIView!
    @IBOutlet weak var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButtonView: UIView!
    @IBOutlet weak var closeImageView: UIImageView!
    @IBOutlet weak var AddButton: UIButton!
    
    weak var delegate: SelectTopicCCDelegate?
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
        
        self.isShowingTrending = isShowingTrending
        self.titleLabel.text =  "#\(topic.name ?? "")"
        self.closeImageView.image = UIImage(named: "RemoveTag")
    
        if (topic.isShowingLoader ?? false) {
            self.closeImageView.isHidden = true
            AddButton.showLoader(size: CGSize(width: 35, height: 35))
        }
        else {
            self.closeImageView.isHidden = false
            AddButton.hideLoaderView()
        }
        if topic.favorite ?? false {
            
            if isShowingTrending {
                self.backgroundRoundView.backgroundColor = Constant.appColor.lightGray
            }
            else {
                self.backgroundRoundView.backgroundColor = .white
            }
            
            titleLabel.textColor = .black
            titleTrailingConstraint.constant = 35
            closeButtonView.isHidden = false
            
        }
        else {
            
            if isShowingTrending {
                self.backgroundRoundView.backgroundColor = Constant.appColor.darkGray
                self.closeImageView.image = UIImage(named: "AddTag")
                closeButtonView.isHidden = false
            }
            else {
                self.backgroundRoundView.backgroundColor = Constant.appColor.lightRed
                closeButtonView.isHidden = true
            }
            
            
            titleLabel.textColor = .white
            titleTrailingConstraint.constant = 14
            
            
        }
        self.addShadow()
        self.layoutIfNeeded()
        
        
    }
    
    func setupCell(location: Location, isSelected: Bool) {
        
        self.titleLabel.text =  "#\(location.name ?? "")"
        self.closeImageView.image = UIImage(named: "RemoveTag")
        
        if isSelected {
            self.backgroundRoundView.backgroundColor = .white
            titleLabel.textColor = .black
            titleTrailingConstraint.constant = 35
            closeButtonView.isHidden = false
            
        }
        else {
            self.backgroundRoundView.backgroundColor = Constant.appColor.lightRed
            titleLabel.textColor = .white
            titleTrailingConstraint.constant = 14
            closeButtonView.isHidden = true
            
        }
        self.addShadow()
        self.layoutIfNeeded()
        
        
    }
    
    
            
    func setupAddOtherCell() {
        self.titleLabel.text =  "Add"
        self.closeImageView.image = UIImage(named: "AddTag")
        
        self.backgroundRoundView.backgroundColor = Constant.appColor.lightRed
        titleLabel.textColor = .white
        titleTrailingConstraint.constant = 35
        closeButtonView.isHidden = false
        
        self.addShadow()
        self.layoutIfNeeded()
    }
    
    @IBAction func didTapRemove(_ sender: Any) {
        
        
        self.delegate?.didTapClose(cell: self)
    }
    
    
}
