//
//  RelatedSourcesCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 04/04/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol RelatedSourcesCCDelegate: AnyObject {
    func didSelectItem(cell: RelatedSourcesCC, secondaryIndex: IndexPath)
    func didTapFollowing(cell: RelatedSourcesCC, secondaryIndex: IndexPath)
    func didTapSeeAll(cell: RelatedSourcesCC)
}


class RelatedSourcesCC: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var channelsArray = [ChannelInfo]()
    weak var delegate: RelatedSourcesCCDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
    func setupCell(model: [ChannelInfo]?, title: String) {
        
        titleLabel.textColor = .black
        titleLabel.text = title
//
//        self.idxRow = row
//        self.content = content
//        suggReelsArr = content.suggestedReels
        if let articles = model {
            self.channelsArray = articles
        }
        
        collectionView.register(UINib(nibName: "SuggestedSourcesCC", bundle: nil), forCellWithReuseIdentifier: "SuggestedSourcesCC")
        

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
    @IBAction func didTapSeeAll(_ sender: Any) {
        
        self.delegate?.didTapSeeAll(cell: self)
    }
    
    
    
}

extension RelatedSourcesCC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.channelsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestedSourcesCC", for: indexPath) as! SuggestedSourcesCC
        cell.setupCell(model: channelsArray[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width
        let height = collectionView.frame.size.height
        if self.channelsArray.count == 1 {
            return CGSize(width: width, height: (height) - 10)
        }
        else if self.channelsArray.count == 2 {
            return CGSize(width: width, height: (height)/2 - 10)
        }
        else {
            return CGSize(width: width, height: (height)/3 - 10)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.delegate?.didSelectItem(cell: self, secondaryIndex: indexPath)
    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
//
}

extension RelatedSourcesCC: SuggestedSourcesCCDelegate {
    
    func didTapFollowing(cell: SuggestedSourcesCC) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        self.delegate?.didTapFollowing(cell: self, secondaryIndex: indexPath)
    }
    
}
