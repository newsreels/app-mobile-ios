//
//  HomeCategoriesCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 05/04/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol HomeCategoriesCCDelegate: AnyObject {
    func didSelectedCell(cell: HomeCategoriesCC, itemIndex: Int, isOpenForReels: Bool)
}

class HomeCategoriesCC: UITableViewCell {

//    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: HomeCategoriesCCDelegate?
    var userSelectedCategory = ""
    var headlinesListArray = [MainCategoriesData]()
    var reelsListArray = [NSLocalizedString("For you", comment: ""), NSLocalizedString("Following", comment: "")]
    var isOpenReels = false
    
    var topicsArray = [TopicData]()
    var isOpenTopics = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(UINib(nibName: "CategoryCC", bundle: nil), forCellWithReuseIdentifier: "CategoryCC")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        
        self.collectionViewHeightConstraint.constant = self.collectionView.contentSize.height > 60 ? self.collectionView.contentSize.height : 60
    }
    
    
    func setupCollectionView() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
    func reloadCollectionViews() {
        
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        self.layoutSubviews()
    }
    
    func setupCell(listArray :[MainCategoriesData]?, isOpenReels: Bool, userSelected: String) {
        
        self.isOpenReels = isOpenReels
        if let listArray = listArray {
            headlinesListArray = listArray
        }
        userSelectedCategory = userSelected
        setupCollectionView()
        
        reloadCollectionViews()
    }
    
    func setupCell(listArray :[TopicData]?) {
        
        self.isOpenTopics = true
        if let listArray = listArray {
            topicsArray = listArray
        }
        setupCollectionView()
        
        reloadCollectionViews()
    }
    
    
}

extension HomeCategoriesCC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isOpenTopics {
            return topicsArray.count
        }
//        else if isOpenReels {
//            return reelsListArray.count
//        }
        return headlinesListArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCC", for: indexPath) as! CategoryCC
        
        if isOpenTopics {
            let content = topicsArray[indexPath.item]
            var userSelected = false
            if content.favorite ?? false {
                userSelected = true
            }
            cell.setupCellForTopics(title: content.name ?? "", image: content.image ?? "", userSelected: userSelected)
        }
        else if isOpenReels {
            let content = reelsListArray[indexPath.item]
            var userSelected = false
            if indexPath.item == Int(userSelectedCategory) {
                userSelected = true
            }
            cell.setupCell(title: content, image: "", userSelected: userSelected)
        }
        else {
            let content = headlinesListArray[indexPath.item]
            var userSelected = false
            if content.id == userSelectedCategory {
                userSelected = true
            }
            cell.setupCell(title: content.title ?? "", image: content.image ?? "", userSelected: userSelected)
        }
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        reloadCollectionViews()
        self.delegate?.didSelectedCell(cell: self, itemIndex: indexPath.item, isOpenForReels: self.isOpenReels)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (self.collectionView.frame.width - 2.5) / 2, height: 60)
    }
    
    
}
