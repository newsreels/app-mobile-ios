//
//  AuthorsDiscoverCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 30/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol AuthorsDiscoverCCDelegate: AnyObject {
    
    func didTapOnChannelCell(cell: AuthorsDiscoverCC, secondaryIndexPath: IndexPath)
    func didTapAddButton(cell: AuthorsDiscoverCC, secondaryIndex: IndexPath, favorite: Bool)
}

class AuthorsDiscoverCC: UICollectionViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var suggAuthorsArr: [Author]?
    
    weak var delegate: AuthorsDiscoverCCDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblTitle.textColor = .black
        lblTitle.text = NSLocalizedString("Suggested Authors", comment: "")
    }
    
    func setupCell(model: DiscoverData?) {
        
        lblTitle.text = model?.title ?? ""
        
        suggAuthorsArr = model?.data?.authors
        collectionView.register(UINib(nibName: "AuthorDiscCC", bundle: nil), forCellWithReuseIdentifier: "AuthorDiscCC")

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

extension AuthorsDiscoverCC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return suggAuthorsArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AuthorDiscCC", for: indexPath) as! AuthorDiscCC
        if let author = suggAuthorsArr?[indexPath.row] {
            cell.setupCell(model: author)
        }
        cell.delegate = self
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = 173//200//collectionView.frame.size.width / 2.5
        let height = collectionView.frame.size.height // 280
        
        return CGSize(width: width, height: height)
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        self.delegateSugAuthor?.didTapFollowAuthorCollection(content: content, authorIdx: indexPath.row, tapOnFollow: false)
        self.delegate?.didTapOnChannelCell(cell: self, secondaryIndexPath: indexPath)
    }
    
}


extension AuthorsDiscoverCC: AuthorDiscCCDelegate {
    
    func didTapFollow(cell: AuthorDiscCC) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let newFav = !(suggAuthorsArr?[indexPath.row].favorite ?? false)
        suggAuthorsArr?[indexPath.row].favorite = newFav
        collectionView.reloadItems(at: [indexPath])
        
        self.delegate?.didTapAddButton(cell: self, secondaryIndex: indexPath, favorite: suggAuthorsArr?[indexPath.row].favorite ?? false)
        
    }
}
