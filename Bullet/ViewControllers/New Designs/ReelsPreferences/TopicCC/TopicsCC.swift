//
//  TopicsCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 18/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol TopicsCCDelegate: AnyObject {
    
    func didCellReloaded(cell: TopicsCC)
    func openAddOther(cell: TopicsCC)
    
}

class TopicsCC: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: TopicsCCDelegate?
    
    var topicArray = [TopicData]()
    var locationsArray = [Location]()
    var isOpenForAddOther = false
    
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundRoundView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(UINib(nibName: "SelectTopicCC", bundle: nil), forCellWithReuseIdentifier: "SelectTopicCC")
        setupCollectionView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    func setupCollectionView() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout1 = UICollectionViewCenterLayout()
        layout1.estimatedItemSize = CGSize(width: 140, height: 50)
        collectionView.collectionViewLayout = layout1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        
        self.collectionViewHeightConstraint.constant = self.collectionView.contentSize.height > 50 ? self.collectionView.contentSize.height : 50
    }
    
    
    func setupTopicsCell(topics: [TopicData], isOpenForAddOther:Bool = false) {
        
        self.collectionViewHeightConstraint.constant = 50
        
        if isOpenForAddOther {
            collectionViewBottomConstraint.constant = 0
        } else {
            collectionViewBottomConstraint.constant = 40
        }
        
        self.topicArray.removeAll()
        self.locationsArray.removeAll()
        
        self.titleLabel.text = "Topics"
        self.topicArray = topics
        reloadCollectionViews()
        
        self.isOpenForAddOther = isOpenForAddOther
        
    }
    
    func setupLocationsCell(locations: [Location], isOpenForAddOther:Bool = false) {
        
        self.collectionViewHeightConstraint.constant = 50
        
        collectionViewBottomConstraint.constant = 0
        self.topicArray.removeAll()
        self.locationsArray.removeAll()
        
        self.titleLabel.text = "Locations"
        self.locationsArray = locations
        reloadCollectionViews()
        
        self.isOpenForAddOther = isOpenForAddOther
        
        self.layoutIfNeeded()
        self.reloadCollectionViews()
    }
    
    
    func reloadCollectionViews() {
        
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        self.layoutSubviews()
    }
    
    
}


extension TopicsCC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if topicArray.count > 0 {
            return topicArray.count
        }
        return locationsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectTopicCC", for: indexPath) as! SelectTopicCC
        
        if indexPath.item == collectionView.numberOfItems(inSection: 0) - 1, isOpenForAddOther == false {
            cell.setupAddOtherCell()
        }
        else if topicArray.count > 0 {
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
        
        
        
        if let cell = collectionView.cellForItem(at: indexPath) as? SelectTopicCC, cell.titleLabel.text ==  "Add" {
            self.delegate?.openAddOther(cell: self)
        }
        else if topicArray.count > 0 {
            if topicArray[indexPath.row].favorite == false {
                topicArray[indexPath.row].favorite = true
            }
            if self.isOpenForAddOther == false {
                SharedManager.shared.performWSToUpdateUserFollow(id: [topicArray[indexPath.row].id ?? ""], isFav: (topicArray[indexPath.row].favorite ?? false), type: .topics) { status in
                    
                    if status {
                        print("status", status)
                    } else {
                        print("status", status)
                    }
                }
            }
        }
        else if locationsArray.count > 0 {
            if locationsArray[indexPath.row].favorite == false {
                locationsArray[indexPath.row].favorite = true
            }
            if self.isOpenForAddOther == false  {
                SharedManager.shared.performWSToUpdateUserFollow(id: [locationsArray[indexPath.row].id ?? ""], isFav: (locationsArray[indexPath.row].favorite ?? false), type: .locations) { status in
                    
                    if status {
                        print("status", status)
                    } else {
                        print("status", status)
                    }
                }
            }
        }
        
        
        
        reloadCollectionViews()
        self.delegate?.didCellReloaded(cell: self)
        
    }
    
    
}

extension TopicsCC: SelectTopicCCDelegate {
    
    func didTapClose(cell: SelectTopicCC) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        
        let cell = collectionView.cellForItem(at: indexPath)
        if (cell as? SelectTopicCC)?.titleLabel.text == "Add" {
            
            self.delegate?.openAddOther(cell: self)
        }
        else if topicArray.count > 0 {
            topicArray[indexPath.row].favorite = false
            if self.isOpenForAddOther == false  {
                SharedManager.shared.performWSToUpdateUserFollow(id: [topicArray[indexPath.row].id ?? ""], isFav: (topicArray[indexPath.row].favorite ?? false), type: .topics) { status in
                    
                    if status {
                        print("status", status)
                    } else {
                        print("status", status)
                    }
                }
            }
            
        }
        else if locationsArray.count > 0 {
            locationsArray[indexPath.row].favorite = false
            if self.isOpenForAddOther == false  {
                SharedManager.shared.performWSToUpdateUserFollow(id: [locationsArray[indexPath.row].id ?? ""], isFav: (locationsArray[indexPath.row].favorite ?? false), type: .locations) { status in
                    
                    if status {
                        print("status", status)
                    } else {
                        print("status", status)
                    }
                }
            }
            
        }
        
        
        reloadCollectionViews()
        
        self.delegate?.didCellReloaded(cell: self)
        
        
    }
    
    
}
