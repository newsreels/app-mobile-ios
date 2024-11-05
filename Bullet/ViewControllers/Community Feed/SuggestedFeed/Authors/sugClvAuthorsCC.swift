//
//  suggestedFeedCC.swift
//  Bullet
//
//  Created by Mahesh on 07/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

let COLLECTION_HEIGHT_AUTHORS: CGFloat           = 180 + 50 //cell + header title

protocol sugClvAuthorsCCDelegate: AnyObject {
    
    func didTapFollowAuthorCollection(content: articlesData, authorIdx: Int, tapOnFollow: Bool)
}

class sugClvAuthorsCC: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var content: articlesData?
    var suggAuthorsArr: [Author]?
    
    weak var delegateSugAuthor: sugClvAuthorsCCDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblTitle.theme_textColor = GlobalPicker.textColor
        lblTitle.text = NSLocalizedString("Suggested Authors", comment: "")
    }
    
    func setupCell(content: articlesData) {
        
        self.content = content
        
        suggAuthorsArr = content.suggestedAuthors
        collectionView.register(UINib(nibName: "suggestedAuthorsCC", bundle: nil), forCellWithReuseIdentifier: "suggestedAuthorsCC")

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
}

extension sugClvAuthorsCC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return suggAuthorsArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "suggestedAuthorsCC", for: indexPath) as! suggestedAuthorsCC
        if let author = suggAuthorsArr?[indexPath.row] {
            cell.setupCell(model: author)
            cell.btnFollow.tag = indexPath.row
            cell.btnFollow.addTarget(self, action: #selector(didTapFollow(button:)), for: .touchUpInside)
        }
        
        cell.layoutIfNeeded()
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.size.height - 40)
        let height = collectionView.frame.size.height
        return CGSize(width: width, height: height)
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
        self.delegateSugAuthor?.didTapFollowAuthorCollection(content: content!, authorIdx: indexPath.row, tapOnFollow: false)
    }
    
    //MARK:- IB Action
    @objc func didTapFollow(button: UIButton) {

        let tag = button.tag
        let author = self.suggAuthorsArr?[tag]
        let fav = author?.favorite ?? false
        suggAuthorsArr?[tag].favorite = !fav
        collectionView.reloadItems(at: [IndexPath(item: tag, section: 0)])
        content?.suggestedAuthors = suggAuthorsArr
        self.delegateSugAuthor?.didTapFollowAuthorCollection(content: content!, authorIdx: tag, tapOnFollow: true)

//        self.performWSToAuthorFollowUnfollow(id: author?.id ?? "", isFav: author?.favorite ?? false)
    }
    
//    func performWSToAuthorFollowUnfollow(id: String, isFav: Bool) {
//
//        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
//        let params = ["authors":id]
//        let url = isFav ? "news/authors/follow" : "news/authors/unfollow"
//
//        WebService.URLResponse(url, method: .post, parameters: params, headers: token, withSuccess: { (response) in
//
//            do{
//                let _ = try
//                    JSONDecoder().decode(messageDC.self, from: response)
//
//
//            } catch let jsonerror {
//
//                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
//                print("error parsing json objects",jsonerror)
//            }
//        }) { (error) in
//
//            print("error parsing json objects",error)
//        }
//    }
}
