//
//  SuggestedAuthorsCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 22/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol SuggestedAuthorsCCDelegate: AnyObject {
    func didTapFollow(cell: SuggestedCC, index: Int)
    func didTapSeeAll(cell: SuggestedCC)
    func didTapChannel(cell: SuggestedCC, channel: ChannelInfo)
}

class SuggestedCC: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var btnSeeAll: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var followingView: UIView!
    
    weak var delegate: SuggestedAuthorsCCDelegate?
    var authorsArray = [Author]()
    var channelArray = [ChannelInfo]()
    var isOnChannel = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupCell(model: [Author]) {
        
        self.isOnChannel = false
        
        self.authorsArray = model
        
        registerCells()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        collectionView.reloadData()
        
        followingView.cornerRadius = followingView.frame.size.height/2
        
    }
    
    func setupCell(model: [ChannelInfo]) {
        
        self.isOnChannel = true
        
        self.channelArray = model
        
        registerCells()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        collectionView.reloadData()
        
        followingView.cornerRadius = followingView.frame.size.height/2
        
    }
    
    
    
    func registerCells() {
        
        collectionView.register(UINib(nibName: "AuthorsFollowingCell", bundle: nil), forCellWithReuseIdentifier: "AuthorsFollowingCell")
    }
    
    @IBAction func didTapSeeAll(_ sender: Any) {
        self.delegate?.didTapSeeAll(cell: self)
    }
    
}

extension SuggestedCC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.isOnChannel ? channelArray.count : authorsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AuthorsFollowingCell", for: indexPath) as! AuthorsFollowingCell
        if isOnChannel {
            cell.setupCell(model: channelArray[indexPath.item])
        }
        else {
            cell.setupCell(model: authorsArray[indexPath.item])
        }
        cell.delegate = self
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 130, height: self.collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if isOnChannel {
            self.delegate?.didTapChannel(cell: self, channel: channelArray[indexPath.item])
        }
        else {
//            self.delegate?.didTapChannel(cell: self, channel: authorsArray[indexPath.item])
        }
        
        
    }
    
    
}

extension SuggestedCC: AuthorsFollowingCellDelegate {
    
    func didTapFollow(cell: AuthorsFollowingCell) {
        
        let indexPath = self.collectionView.indexPath(for: cell)
        self.delegate?.didTapFollow(cell: self, index: indexPath?.row ?? 0)
        
        
    }
}
