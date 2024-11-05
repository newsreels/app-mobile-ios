//
//  ReelsSuggestedDiscoverCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 31/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol ReelsSuggestedDiscoverCCDelegate: AnyObject {
    
    func didSelectItem(cell: ReelsSuggestedDiscoverCC, secondaryIndex: IndexPath)
}

class ReelsSuggestedDiscoverCC: UICollectionViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var content: DiscoverData?
    var suggReelsArr: [Reel]?
    var idxRow = 0

    weak var delegate: ReelsSuggestedDiscoverCCDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setupCell(content: DiscoverData?, row: Int, isHomeFeed: Bool = false) {
        
        lblTitle.textColor = .black
        lblTitle.text = content?.title

        self.idxRow = row
        self.content = content
        suggReelsArr = content?.data?.reels
        collectionView.register(UINib(nibName: "suggestedReelsCC", bundle: nil), forCellWithReuseIdentifier: "suggestedReelsCC")

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.async {
            if SharedManager.shared.isSelectedLanguageRTL() {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
            } else {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
            }
        }
        
    }
    
    
}

extension ReelsSuggestedDiscoverCC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return suggReelsArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "suggestedReelsCC", for: indexPath) as! suggestedReelsCC
        
        //Check Upload Processing/scheduled on Article by User
        if let reel = suggReelsArr?[indexPath.row] {
            cell.setupCell(model: reel)
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width / 3.25
        let height = collectionView.frame.size.height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.delegate?.didSelectItem(cell: self, secondaryIndex: indexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
}
