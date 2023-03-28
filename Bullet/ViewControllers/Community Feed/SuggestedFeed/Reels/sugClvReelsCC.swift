//
//  sugClvReelsCC.swift
//  Bullet
//
//  Created by Mahesh on 07/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

let COLLECTION_HEIGHT_REELS: CGFloat             = 225 + 50 //cell + header title

protocol sugClvReelsCCDelegate: AnyObject {
    
    func didTapOnReelsCell(cell: UITableViewCell, reelRow: Int)
}

class sugClvReelsCC: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var suggReelsArr: [Reel]?
    var idxRow = 0

    weak var delegateSugReels: sugClvReelsCCDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setupCell(content: articlesData, row: Int, isHomeFeed: Bool = false) {
        
        //Set when display reels in topicDetails
        DispatchQueue.main.async {
            self.lblTitle.font =  SharedManager.shared.getHeaderTitleFont()
        }
        lblTitle.textColor = Constant.appColor.lightRed        
        //lblTitle.theme_textColor = GlobalPicker.textColor
        if isHomeFeed {
            lblTitle.text = content.title
        }
        else {
            lblTitle.text = NSLocalizedString("Related Reels", comment: "")
        }

        self.idxRow = row
        suggReelsArr = content.suggestedReels
        collectionView.register(UINib(nibName: "suggestedReelsCC", bundle: nil), forCellWithReuseIdentifier: "suggestedReelsCC")

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
    func setupCell(content: DiscoverData?, row: Int, isHomeFeed: Bool = false) {
        
        lblTitle.theme_textColor = GlobalPicker.textColor
        if isHomeFeed {
            lblTitle.text = content?.title
        }
        else {
            lblTitle.text = NSLocalizedString("Related Reels", comment: "")
        }

        self.idxRow = row
        suggReelsArr = content?.data?.reels
        collectionView.register(UINib(nibName: "suggestedReelsCC", bundle: nil), forCellWithReuseIdentifier: "suggestedReelsCC")

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
}

extension sugClvReelsCC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
        self.delegateSugReels?.didTapOnReelsCell(cell: self, reelRow: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
    
}
