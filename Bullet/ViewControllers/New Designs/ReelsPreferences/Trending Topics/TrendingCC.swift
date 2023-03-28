//
//  TrendingCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 22/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol TrendingCCDelegate: AnyObject {
    
    func didTapSeeallTopics(cell: TrendingCC)
    func didTapCell(cell: TrendingCC, index: Int)
    func didTapFollow(cell: TrendingCC, secondaryIndex: IndexPath)
    
}

class TrendingCC: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnSeeall: UIButton!
    
//    @IBOutlet var collectionViewheightConstraint: NSLayoutConstraint!
    
    weak var delegate: TrendingCCDelegate?
    var suggestedArray = [TopicData]()
    var suggestedLocationsArray = [Location]()
    var isOnLoadingLocations = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    func setupCell(model: [TopicData], isOnDiscover: Bool = false) {
        
        if isOnDiscover {
            titleTopConstraint.constant = 20
        }
        self.suggestedArray = model
        registerCells()
        collectionView.delegate = self
        collectionView.dataSource = self
        
//        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        collectionView.reloadData()

    }
    
    func setupCell(model: [Location], isOnDiscover: Bool = false) {
        
        isOnLoadingLocations = true
        if isOnDiscover {
            titleTopConstraint.constant = 20
        }
        self.suggestedLocationsArray = model
        registerCells()
        collectionView.delegate = self
        collectionView.dataSource = self
        
//        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        collectionView.reloadData()
        
        
    }
    
    
    func registerCells() {
        
        collectionView.register(UINib(nibName: "TrendingTopicsCC", bundle: nil), forCellWithReuseIdentifier: "TrendingTopicsCC")
    }
    
    @IBAction func didTapSeeAllTopics(_ sender: Any) {
        
        self.delegate?.didTapSeeallTopics(cell: self)
    }
    
    
}

extension TrendingCC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isOnLoadingLocations {
            return self.suggestedLocationsArray.count
        }
        return self.suggestedArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendingTopicsCC", for: indexPath) as! TrendingTopicsCC
        
        if isOnLoadingLocations {
            
            cell.setupCellLocations(model: suggestedLocationsArray[indexPath.item])
        }
        else {
            
            cell.setupCellTopics(model: suggestedArray[indexPath.item])
        }
        cell.delegate = self
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.delegate?.didTapCell(cell: self, index: indexPath.item)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width
//        let height = collectionView.frame.size.height
        return CGSize(width: width, height: 60)
    }
    
}

extension TrendingCC: TrendingTopicsCCDelegate {
    
    func didTapFollow(cell: TrendingTopicsCC) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        self.delegate?.didTapFollow(cell: self, secondaryIndex: indexPath)
    }
}
