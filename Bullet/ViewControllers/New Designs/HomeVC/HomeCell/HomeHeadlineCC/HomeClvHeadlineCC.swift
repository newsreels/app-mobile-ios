//
//  HomeClvHeadlineCC.swift
//  Bullet
//
//  Created by Mahesh on 18/08/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

let COLLECTION_HEIGHT_HOME_HEADLINE: CGFloat    = 225 + 48 //cell + header title

internal let CELL_IDENTIFIER_HOME_HEADLINE_CLV      = "HomeClvHeadlineCC"

protocol HomeClvHeadlineCCDelegate: AnyObject {
    
    func didTapOnHeadlineFeedsCell(cell: UITableViewCell, row: Int)
    func didTapOnHeadlineFeedsSource(cell: UITableViewCell, row: Int)
}

class HomeClvHeadlineCC: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backView: UIView!
    
    var contentData: articlesData?
    var sugFeedArr: [articlesData]?
    var idxRow = 0

    weak var delegateSugFeeds: HomeClvHeadlineCCDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        collectionView.setContentOffset(.zero, animated: false)
    }
    
    func setupCell(content: articlesData, row: Int) {
        
        idxRow = row
        contentData = content
        sugFeedArr = content.suggestedFeeds
        
        collectionView.register(UINib(nibName: "HeadlineCC", bundle: nil), forCellWithReuseIdentifier: "HeadlineCC")
        collectionView.register(UINib(nibName: "HeadlineFooterCC", bundle: nil), forCellWithReuseIdentifier: "HeadlineFooterCC")

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        collectionView.reloadData()
        //collectionView.layoutIfNeeded()
    }
}

extension HomeClvHeadlineCC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return sugFeedArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let feed = sugFeedArr?[indexPath.item]
        //print("\(indexPath.item)...", feed?.title ?? "")
        if feed?.type ?? "" == "FOLLOWED_CARD" {
            
            let fCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeadlineFooterCC", for: indexPath) as! HeadlineFooterCC
            
            fCell.langCode = feed?.language ?? ""
            if let feed = feed {
                fCell.setupCell(model: feed)
            }
            
            fCell.btnAddTopic.tag = indexPath.item
            fCell.btnAddTopic.addTarget(self, action: #selector(didTapAddTopic(button:)), for: .touchUpInside)
            
            return fCell
        }
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeadlineCC", for: indexPath) as! HeadlineCC
            
            cell.delegateCell = self
            cell.langCode = feed?.language ?? ""
            if let feed = feed {
                cell.setupCell(model: feed, alwaysDark: false)
            }
    //        cell.layoutIfNeeded()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width = collectionView.frame.size.width / 2
        if UIDevice.current.userInterfaceIdiom == .pad {
            width = 300
        }
        return CGSize(width: width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
        self.delegateSugFeeds?.didTapOnHeadlineFeedsCell(cell: self, row: indexPath.row)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
    
    
    @objc func didTapAddTopic(button: UIButton) {
        
        let item = button.tag
        let feed = sugFeedArr?[item]
        let fav = feed?.followed ?? true
        sugFeedArr?[item].followed = !fav
        collectionView.reloadItems(at: [IndexPath(item: item, section: 0)])
        SharedManager.shared.performWSToUpdateUserFollow(vc: UIApplication.shared.keyWindow?.rootViewController ?? UIViewController(), id: [feed?.id ?? ""], isFav: !fav, type: .topics) { (status) in
        }
    }
    
}

//delegate
extension HomeClvHeadlineCC: HeadlineCCDelegate {
    
    func didTapSourceHorizontal(_ cell: UICollectionViewCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        self.delegateSugFeeds?.didTapOnHeadlineFeedsSource(cell: self, row: indexPath.row)
    }
}
