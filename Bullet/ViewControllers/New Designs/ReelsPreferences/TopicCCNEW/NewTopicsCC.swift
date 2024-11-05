//
//  NewTopicsCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 18/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol NewTopicsCCDelegate: AnyObject {
    
    func didCellReloaded(cell: NewTopicsCC)
    func openAddOther(cell: NewTopicsCC)
    func didSelectItem(cell: NewTopicsCC, secondaryIndex: Int)
    func didTapFollow(cell: NewTopicsCC, secondaryIndex: Int)
    func didTapSeeallTopics(cell: NewTopicsCC)
}

class NewTopicsCC: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var descriptionHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: NewTopicsCCDelegate?
    
    var topicArray = [TopicData]()
    var locationsArray = [Location]()
    
//    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
//    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundRoundView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(UINib(nibName: "NewSelectTopicCC", bundle: nil), forCellWithReuseIdentifier: "NewSelectTopicCC")
        setupCollectionView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    func setupCollectionView() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

//        let layout1 = UICollectionViewCenterLayout()
//        layout1.estimatedItemSize = CGSize(width: 140, height: 40)
////        collectionView.collectionViewLayout = layout1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        
//        self.collectionViewHeightConstraint.constant = self.collectionView.contentSize.height > 50 ? self.collectionView.contentSize.height : 50
    }
    
    
    func setupTopicsCell(topics: [TopicData], isOpenFromDiscover:Bool = false) {
        
//        if isOpenForAddOther {
//            collectionViewBottomConstraint.constant = 0
//        } else {
//            collectionViewBottomConstraint.constant = 40
//        }
        
        self.topicArray.removeAll()
        self.locationsArray.removeAll()
        
        if isOpenFromDiscover {
            self.titleLabel.text = "Trending Topics"
            self.descriptionLabel.text = ""
            self.descriptionHeightConstraint.constant = 0
        }
        else {
            self.titleLabel.text = "Topics"
            self.descriptionLabel.text = "Discover curated content from you fav topics."
            self.descriptionHeightConstraint.constant = 16.5
        }
        
        
        self.topicArray = topics
        reloadCollectionViews()
        
        
    }
    
    func setupLocationsCell(locations: [Location], isOpenFromDiscover:Bool = false) {
        
//        collectionViewBottomConstraint.constant = 0
        self.topicArray.removeAll()
        self.locationsArray.removeAll()
        
        if isOpenFromDiscover {
            self.titleLabel.text = "Locations"
            self.descriptionLabel.text = ""
            self.descriptionHeightConstraint.constant = 0
        }
        else {
            self.titleLabel.text = "Locations"
            self.descriptionLabel.text = "Discover curated content from you fav places."
            self.descriptionHeightConstraint.constant = 16.5
        }
        
        
        self.locationsArray = locations
        reloadCollectionViews()
        
    }
    
    
    func reloadCollectionViews() {
        
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        self.layoutSubviews()
    }
    
    
    @IBAction func didTapSeeAll(_ sender: Any) {
        
        self.delegate?.didTapSeeallTopics(cell: self)
    }
    
    
}


extension NewTopicsCC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if topicArray.count > 0 {
            return topicArray.count
        }
        return locationsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewSelectTopicCC", for: indexPath) as! NewSelectTopicCC
        
//        if indexPath.item == collectionView.numberOfItems(inSection: 0) - 1, isOpenForAddOther == false {
//            cell.setupAddOtherCell()
//        }
//        else
        if topicArray.count > 0 {
            cell.setupCell(topic: topicArray[indexPath.row], isShowingTrending: false)
        }
        else if locationsArray.count > 0 {
            cell.setupCell(location: locationsArray[indexPath.row], isSelected: locationsArray[indexPath.row].favorite ?? false)
        }
        cell.delegate = self
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.delegate?.didSelectItem(cell: self,secondaryIndex: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 90, height: collectionView.frame.size.height)
    }
    
}

extension NewTopicsCC: NewSelectTopicCCDelegate {
    
    func didTapClose(cell: NewSelectTopicCC) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        
        self.delegate?.didTapFollow(cell: self, secondaryIndex: indexPath.item)
        
        
    }
    
    
}
