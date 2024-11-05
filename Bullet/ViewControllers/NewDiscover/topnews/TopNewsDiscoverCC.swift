//
//  TopNewsDiscoverCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 30/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol TopNewsDiscoverCCDelegate: AnyObject {
    func didSelectItem(cell: TopNewsDiscoverCC, secondaryIndex: IndexPath)
}

class TopNewsDiscoverCC: UICollectionViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var isVertical = false
    var articlesArray = [articlesData]()
    weak var delegate: TopNewsDiscoverCCDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(model: DiscoverData?) {
        
        lblTitle.textColor = .black
        lblTitle.text = model?.title ?? ""
        
        self.isVertical = !(model?.data?.top ?? false)
//
//        self.idxRow = row
//        self.content = content
//        suggReelsArr = content.suggestedReels
        if let articles = model?.data?.articles {
            self.articlesArray = articles
        }
        
        collectionView.register(UINib(nibName: "HeadlinesDiscoverCC", bundle: nil), forCellWithReuseIdentifier: "HeadlinesDiscoverCC")
        collectionView.register(UINib(nibName: "HeadlineVerticalDiscoverCC", bundle: nil), forCellWithReuseIdentifier: "HeadlineVerticalDiscoverCC")
        

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

extension TopNewsDiscoverCC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.articlesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isVertical {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeadlineVerticalDiscoverCC", for: indexPath) as! HeadlineVerticalDiscoverCC
            
            //Check Upload Processing/scheduled on Article by User
            cell.setupCell(model: articlesArray[indexPath.item])
            cell.lblHeadline.textColor = .white
            cell.layoutIfNeeded()
            
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeadlinesDiscoverCC", for: indexPath) as! HeadlinesDiscoverCC
            
            cell.setupCell(model: articlesArray[indexPath.item], indexForNews: indexPath.item)
            
            cell.layoutIfNeeded()
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width / 2.5
//        let height: CGFloat = 230.0
        return CGSize(width: width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.delegateSugReels?.didTapOnReelsCell(cell: self, reelRow: indexPath.row)
        

        self.delegate?.didSelectItem(cell: self, secondaryIndex: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
}
