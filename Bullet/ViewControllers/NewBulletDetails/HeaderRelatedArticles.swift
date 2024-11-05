//
//  HeaderRelatedArticles.swift
//  Bullet
//
//  Created by Faris Muhammed on 14/04/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol HeaderRelatedArticlesDelegate: AnyObject {
    
    func didTapOnHeadlineFeedsCell(header: UITableViewHeaderFooterView, row: Int)
    func didTapOnHeadlineFeedsSource(header: UITableViewHeaderFooterView, row: Int)
}

class HeaderRelatedArticles: UITableViewHeaderFooterView {
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var viewSimilarArticle: UIView!
    @IBOutlet weak var clvSimilar: UICollectionView!
//    @IBOutlet weak var lblSimilarTitle: UILabel!
    
    weak var delegateHeader: HeaderRelatedArticlesDelegate?

    var similarArr: [articlesData]?
    var similarReelsArr: [Reel]?
    
    var isRequiredSimilarData = false
    var isRequiredRelatedData = true
    
    
    func setHeaderSimilarArticlesData(_ arr: [articlesData]?, reels: [Reel]?) {
                
        lblTitle.text = NSLocalizedString("Suggested Articles", comment: "")
//        lblSimilarTitle.text = "" //NSLocalizedString("Similar Articles", comment: "")

        lblTitle.theme_textColor = GlobalPicker.textBWColor
//        lblSimilarTitle.theme_textColor = GlobalPicker.textBWColor

        similarArr = arr
        self.similarReelsArr = reels
        
        lblTitle.isHidden = true
        viewSimilarArticle.isHidden = true
        
        if isRequiredRelatedData {
            lblTitle.isHidden = false
        }
        
        if isRequiredSimilarData {
            viewSimilarArticle.isHidden = false
        }
        
        clvSimilar.register(UINib(nibName: "HeadlineCC", bundle: nil), forCellWithReuseIdentifier: "HeadlineCC")
        clvSimilar.register(UINib(nibName: "suggestedReelsCC", bundle: nil), forCellWithReuseIdentifier: "suggestedReelsCC")
        
        //clvSimilar.register(UINib(nibName: "HeadlineFooterCC", bundle: nil), forCellWithReuseIdentifier: "HeadlineFooterCC")
        
        clvSimilar.delegate = self
        clvSimilar.dataSource = self
        clvSimilar.reloadData()
    }
}

//UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension HeaderRelatedArticles: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if (self.similarReelsArr?.count ?? 0) > 0 {
            return similarReelsArr?.count ?? 0
        }
        return similarArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if (self.similarReelsArr?.count ?? 0) > 0 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "suggestedReelsCC", for: indexPath) as! suggestedReelsCC
            
            //Check Upload Processing/scheduled on Article by User
            if let reel = similarReelsArr?[indexPath.row] {
                cell.setupCell(model: reel)
            }
            cell.layoutIfNeeded()
            
            return cell
        }
        else {
            
            let feed = similarArr?[indexPath.item]
            //print("\(indexPath.item)...", feed?.title ?? "")
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
        
        if (self.similarReelsArr?.count ?? 0) > 0 {
            // reels
            let width = collectionView.frame.size.width / 3.25
            let height = collectionView.frame.size.height
            return CGSize(width: width, height: height)
        }
        
        let width = collectionView.frame.size.width / 2.25
        return CGSize(width: width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
        self.delegateHeader?.didTapOnHeadlineFeedsCell(header: self, row: indexPath.row)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
    
    
//    @objc func didTapAddTopic(button: UIButton) {
//
//        let item = button.tag
//        let feed = similarArr?[item]
//        let fav = feed?.followed ?? true
//        similarArr?[item].followed = !fav
//        clvSimilar.reloadItems(at: [IndexPath(item: item, section: 0)])
//        SharedManager.shared.performWSToUpdateUserFollow(vc: UIApplication.shared.keyWindow?.rootViewController ?? UIViewController(), id: feed?.id ?? "", isFav: !fav, type: .topics) { (status) in
//        }
//    }
    
}

//delegate
extension HeaderRelatedArticles: HeadlineCCDelegate {
    
    func didTapSourceHorizontal(_ cell: UICollectionViewCell) {
        
        guard let indexPath = clvSimilar.indexPath(for: cell) else { return }
        
        self.delegateHeader?.didTapOnHeadlineFeedsSource(header: self, row: indexPath.row)
    }
}
