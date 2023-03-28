//
//  GenericPhotoCell.swift
//  Bullet
//
//  Created by Khadim Hussain on 12/04/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
//import Hero
import SDWebImage

class GenericPhotoCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    //    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var collectionView1: UICollectionView!
    @IBOutlet weak var collectionView2: UICollectionView!
    @IBOutlet weak var collectionView3: UICollectionView!
    //    @IBOutlet weak var imgLeftGradient: UIImageView!
    //    @IBOutlet weak var imgRightGradient: UIImageView!
    @IBOutlet weak var viewCollectionViewContainer: UIView!
    @IBOutlet weak var dummyImage: UIImageView!
    @IBOutlet weak var collectionViewStack: UIStackView!
    
    var model: Discover?
    
    var iconsArray1 = [icons]()
    var iconsArray2 = [icons]()
    var iconsArray3 = [icons]()
    var totalItems = 1000
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.lblTitle.theme_textColor = GlobalPicker.textSubColorDiscover
        self.lblSubTitle.theme_textColor = GlobalPicker.textBWColorDiscover
        
        self.viewBG.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        self.theme_backgroundColor = GlobalPicker.backgroundDiscoverMainColor
        
        
        //        imgLeftGradient.theme_image = GlobalPicker.discoverRightGradient
        //        imgRightGradient.theme_image = GlobalPicker.discoverLeftGradient
        
        self.viewBG.addBottomShadowForDiscoverPage()
        
        //        heroModifiers = [.whenMatched(.useNoSnapshot), .spring(stiffness: 300, damping: 25)]
        
//        collectionView.register(UINib(nibName: "MaqueeImageCell", bundle: nil), forCellWithReuseIdentifier: "MaqueeImageCell")
        
        collectionView1.register(UINib(nibName: "TopicIconCC", bundle: nil), forCellWithReuseIdentifier: "TopicIconCC")
        collectionView1.register(UINib(nibName: "ChannelIconCC", bundle: nil), forCellWithReuseIdentifier: "ChannelIconCC")
        
        collectionView1.delegate = self
        collectionView1.dataSource = self
        
        collectionView2.register(UINib(nibName: "TopicIconCC", bundle: nil), forCellWithReuseIdentifier: "TopicIconCC")
        collectionView2.register(UINib(nibName: "ChannelIconCC", bundle: nil), forCellWithReuseIdentifier: "ChannelIconCC")
        
        collectionView2.delegate = self
        collectionView2.dataSource = self
        
        collectionView3.register(UINib(nibName: "TopicIconCC", bundle: nil), forCellWithReuseIdentifier: "TopicIconCC")
        collectionView3.register(UINib(nibName: "ChannelIconCC", bundle: nil), forCellWithReuseIdentifier: "ChannelIconCC")
        
        collectionView3.delegate = self
        collectionView3.dataSource = self
        
    }
    
    override func prepareForReuse() {
        
        iconsArray1.removeAll()
        iconsArray2.removeAll()
        iconsArray3.removeAll()
    }
    override func layoutSubviews() {
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
                self.lblSubTitle.semanticContentAttribute = .forceRightToLeft
                self.lblSubTitle.textAlignment = .right
            }
            
        } else {
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
                self.lblSubTitle.semanticContentAttribute = .forceLeftToRight
                self.lblSubTitle.textAlignment = .left
            }
        }

    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCell(model: Discover?, isScaleImage: Bool) {
        
        self.model = model
        
        self.lblTitle.text = model?.subtitle?.uppercased() ?? ""
        self.lblSubTitle.text = model?.title ?? ""
        //        let url = model?.data?.image ?? ""
        
        //        if isScaleImage {
        //            self.imgNews.contentMode = .scaleToFill
        //        } else {
        //            self.imgNews.contentMode = .scaleAspectFill
        //        }
        //        self.imgNews.contentMode = .scaleAspectFill
        
        populateArray()
        
        let url = model?.data?.image ?? ""
        dummyImage.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        dummyImage.layoutIfNeeded()
        
        if model?.type == "IMAGE_TOPICS" {
            self.collectionView3.isHidden = false
        } else {
            self.collectionView3.isHidden = true
        }
        
        self.collectionView1.reloadData()
        self.collectionView2.reloadData()
        self.collectionView3.reloadData()
        
        
        
        
        
//        SDWebImageManager.shared.loadImage(
//            with: URL(string: url),
//            options: .highPriority,
//            progress: nil) { [weak self] (image, data, error, cacheType, isFinished, imageUrl)  in
//            self?.dummyImage.image = image
//            self?.dummyImage.layoutIfNeeded()
//
//        }
        
        
    }
    
    
    func populateArray() {
        if iconsArray1.count == 0 {
            
            if let icons = model?.data?.icons {
                
                for  (index,obj) in icons.enumerated() {
                    
                    if index % 3 == 0 {
                        iconsArray1.append(obj)
                    } else if index % 2 == 0 {
                        iconsArray2.append(obj)
                    } else {
                        iconsArray3.append(obj)
                    }
                    
                }
                
            }
            
        }
    }
    
    
//    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        UIView.animate(withDuration: 0.2) {
//            self.viewBG.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//        }
//    }
//
//    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        UIView.animate(withDuration: 0.2) {
//            self.viewBG.transform = CGAffineTransform.identity
//        }
//    }
    
    
    
}


extension GenericPhotoCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return totalItems
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if model?.type == "IMAGE_TOPICS" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopicIconCC", for: indexPath) as! TopicIconCC
            cell.imgIcon.image = nil
            cell.lblName.text = nil
            
            let url = getImage(indexPath: indexPath, collectionView: collectionView)?.icon ?? ""
            cell.imgIcon?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            cell.imgIcon.contentMode = .scaleAspectFill
            cell.lblName.text = getImage(indexPath: indexPath, collectionView: collectionView)?.name ?? ""
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChannelIconCC", for: indexPath) as! ChannelIconCC
            cell.imgIcon.image = nil
            cell.lblName.text = nil
            
            let url = getImage(indexPath: indexPath, collectionView: collectionView)?.icon ?? ""
            cell.imgIcon?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            cell.imgIcon.contentMode = .scaleAspectFill
            cell.lblName.text = getImage(indexPath: indexPath, collectionView: collectionView)?.name ?? ""
            return cell
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

//        if indexPath.item == 0 {
//            let size = CGSize(width: 25, height: 55)
//            return size
//        }
        calculateSize(collectionView: collectionView)

    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == collectionView2 {
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    
    
    func calculateSize(collectionView: UICollectionView)-> CGSize {
        if model?.type == "IMAGE_TOPICS" {
            let size = CGSize(width: 130, height: collectionView.frame.size.height)
            return size
        } else {
            let size = CGSize(width: collectionView.frame.size.height - 20, height: collectionView.frame.size.height)
            return size
        }
    }
    
    
    func getImage(indexPath: IndexPath, collectionView: UICollectionView)-> icons? {
        
        if model?.type == "IMAGE_TOPICS" {
            if collectionView == collectionView1 {
                return iconsArray1[indexPath.row % iconsArray1.count]
            }
            else if collectionView == collectionView2 {
                return iconsArray2[indexPath.row % iconsArray2.count]
            }
            else {
                return iconsArray3[indexPath.row % iconsArray3.count]
            }
        } else {
            if collectionView == collectionView1 {
                return iconsArray1[indexPath.row % iconsArray1.count]
            }
            else if collectionView == collectionView2 {
                return iconsArray2[indexPath.row % iconsArray2.count]
            }
            else {
                return iconsArray3[indexPath.row % iconsArray3.count]
            }
        }
        
    }
    
    
    
}
