//
//  RelatedArticlesCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 04/04/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit


protocol RelatedArticlesCCDelegate: AnyObject {
    func didSelectItem(cell: RelatedArticlesCC, secondaryIndex: IndexPath)
}


class RelatedArticlesCC: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var articlesArray = [articlesData]()
    weak var delegate: RelatedArticlesCCDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
    func setupCell(model: DiscoverData?) {
        
        titleLabel.textColor = .black
        titleLabel.text = model?.title ?? ""
//
//        self.idxRow = row
//        self.content = content
//        suggReelsArr = content.suggestedReels
        if let articles = model?.data?.articles {
            self.articlesArray = articles
        }
        
        collectionView.register(UINib(nibName: "SuggestedArticlesCC", bundle: nil), forCellWithReuseIdentifier: "SuggestedArticlesCC")
        

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
}

extension RelatedArticlesCC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.articlesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestedArticlesCC", for: indexPath) as! SuggestedArticlesCC
        
        //Check Upload Processing/scheduled on Article by User
        cell.setupCellBulletsView(article: articlesArray[indexPath.item])
        cell.layoutIfNeeded()
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width
//        let height: CGFloat = 230.0
        return CGSize(width: width, height: (collectionView.frame.size.height)/2 - 10)
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

