//
//  RelevantCell.swift
//  Bullet
//
//  Created by Khadim Hussain on 18/05/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit


protocol RelevantCellDelegate: AnyObject {
    
    func didSelectCategory(location: Location?, topics: TopicData?, source: ChannelInfo?, author: Author?, reels: Reel?)
//    func didSelectViewAll(type: RelevantVC.searchType)
    func didSelectViewAll(type: RelevantVC.searchType, currentModel: Relevant)
    
    func didTapAddButton(cell: RelevantCell, secondaryIndex: IndexPath, favorite: Bool)
}

class RelevantCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!

    var type = ""
    var currentModel: Relevant?
    weak var delegate: RelevantCellDelegate?
    
    enum searchType: String {
        case topics
        case sources
        case locations
        case authors
    }
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        registerCell()
    }
    
    func registerCell() {
        collectionView.register(UINib(nibName: "RelevantClvCell", bundle: nil), forCellWithReuseIdentifier: "RelevantClvCell")
        collectionView.register(UINib(nibName: "AuthorDiscCC", bundle: nil), forCellWithReuseIdentifier: "AuthorDiscCC")
        collectionView.register(UINib(nibName: "OnboardingTopicsCC", bundle: nil), forCellWithReuseIdentifier: "OnboardingTopicsCC")
        collectionView.register(UINib(nibName: "sugChannelCC", bundle: nil), forCellWithReuseIdentifier: "sugChannelCC")
        collectionView.register(UINib(nibName: "locationDiscCC", bundle: nil), forCellWithReuseIdentifier: "locationDiscCC")
        collectionView.register(UINib(nibName: "suggestedReelsCC", bundle: nil), forCellWithReuseIdentifier: "suggestedReelsCC")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func layoutSubviews() {
//        if SharedManager.shared.isSelectedLanguageRTL() {
//            DispatchQueue.main.async {
//                self.imgArrow.transform = CGAffineTransform(scaleX: -1, y: 1)
//            }
//            
//        } else {
//            DispatchQueue.main.async {
//                self.imgArrow.transform = CGAffineTransform.identity
//            }
//        }
    }
    
    
    func setupCell(model: Relevant) {
        
        currentModel = model
        
//        viewSeeAll.isHidden = true
//        if currentModel?.type == .locations {
//            if (currentModel?.locations?.count ?? 0) > 1 {
//                viewSeeAll.isHidden = false
//            }
//        }
//        if currentModel?.type == .topics {
//            if (currentModel?.topics?.count ?? 0) > 1 {
//                viewSeeAll.isHidden = true
//            }
//        }
//        if currentModel?.type == .sources {
//            if (currentModel?.sources?.count ?? 0) > 1 {
//                viewSeeAll.isHidden = false
//            }        }
//        if currentModel?.type == .authors {
//            if (currentModel?.authors?.count ?? 0) > 1 {
//                viewSeeAll.isHidden = false
//            }
//        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    
    @IBAction func didTapSeeAll(_ sender: Any) {
        
        if let model = self.currentModel {
            
            self.delegate?.didSelectViewAll(type: currentModel?.type ?? .articles, currentModel: model)
        }
    }
}

//MARK: - CollectionView delegates and data sources
extension RelevantCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if currentModel?.type == .locations {
            return currentModel?.locations?.count ?? 0
        }
        if currentModel?.type == .topics {
            return currentModel?.topics?.count ?? 0
        }
        if currentModel?.type == .sources {
            return currentModel?.sources?.count ?? 0
        }
        if currentModel?.type == .authors {
            return currentModel?.authors?.count ?? 0
        }
        if currentModel?.type == .reels {
            return currentModel?.reels?.count ?? 0
        }
        
       return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cell = cell as? AuthorDiscCC {
            
            cell.updateCorner()
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if currentModel?.type == .authors {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AuthorDiscCC", for: indexPath) as! AuthorDiscCC
            cell.setupCell(model: currentModel?.authors?[indexPath.row])
            cell.delegate = self
            cell.layoutIfNeeded()
            return cell
        }
        
        else if currentModel?.type == .topics {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingTopicsCC", for: indexPath) as! OnboardingTopicsCC
            if let topics = currentModel?.topics?[indexPath.row] {
                
                cell.setupTopicCell(topic: topics, isFavorite: topics.favorite ?? false)
                cell.btnFav.tag = indexPath.row
//                cell.btnFav.addTarget(self, action: #selector(didTapTopicsFavButton), for: .touchUpInside)
                cell.delegate = self
            }
            cell.layoutIfNeeded()
            return cell
        }
        else if currentModel?.type == .sources {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sugChannelCC", for: indexPath) as! sugChannelCC
            cell.delegate = self

            if let channel = currentModel?.sources?[indexPath.row] {
                
                cell.setupCellSourceModel(model: channel)
            }
            return cell
        }
        else if currentModel?.type == .locations {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationDiscCC", for: indexPath) as! locationDiscCC
            if let location = currentModel?.locations?[indexPath.row] {
                
                cell.setupChannelInfoCell(model: location)
            }
            cell.layoutIfNeeded()
            return cell
        }
        else if currentModel?.type == .reels {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "suggestedReelsCC", for: indexPath) as! suggestedReelsCC
            if let reels = currentModel?.reels?[indexPath.row] {
                
                cell.setupCell(model: reels)
                //cell.imgProfile.isHidden = true
            }
            cell.layoutIfNeeded()
            return cell
        }
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RelevantClvCell", for: indexPath) as! RelevantClvCell
      
            var title = ""
            var image = ""
            if currentModel?.type == .locations {
                title = currentModel?.locations?[indexPath.row].name ?? ""
                image = currentModel?.locations?[indexPath.row].image ?? ""
            }
//            if currentModel?.type == .topics {
//                title = currentModel?.topics?[indexPath.row].name ?? ""
//                image = currentModel?.topics?[indexPath.row].image ?? ""
//            }
//            if currentModel?.type == .sources {
//                title = currentModel?.sources?[indexPath.row].name ?? ""
//                image = currentModel?.sources?[indexPath.row].image ?? ""
//            }
//            
            cell.setupCell(image: image, title: title)
            cell.layoutIfNeeded()
            return cell
        }
       
//        return UICollectionViewCell()
    }
    
    
    
    //MARK:- UICOLLECTIONVIEW DELEGATE FLOW LAYOUT
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        let lineSpacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? 0
        if currentModel?.type == .authors {
            let width: CGFloat = 173//250//((collectionView.frame.size.width - (lineSpacing * 2))/2)
            return CGSize(width: width, height: 220)//CGSize(width: width, height: (collectionView.frame.size.height))
        }
        else if currentModel?.type == .topics {
            
            return CGSize(width: 245 , height: 116)
        }
        else if currentModel?.type == .sources {
            
            let width = collectionView.frame.size.width / 2.5
            return CGSize(width: width, height: 200)
        }
        else if currentModel?.type == .locations {
            
            let height = collectionView.frame.size.height
            return CGSize(width: height - 10, height: height)
        }
        else if currentModel?.type == .reels {
            
            let height = collectionView.frame.size.height
            return CGSize(width: height - 80, height: height)
        }
        else {
            let width: CGFloat = 200//((collectionView.frame.size.width - (lineSpacing * 2))/2)
            return CGSize(width: width, height: (collectionView.frame.size.height))
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if currentModel?.type == .locations {
            let location = currentModel?.locations?[indexPath.row]
            self.delegate?.didSelectCategory(location: location, topics: nil, source: nil, author: nil, reels: nil)
        }
        if currentModel?.type == .topics {
            let topics = currentModel?.topics?[indexPath.row]
            self.delegate?.didSelectCategory(location: nil, topics: topics, source: nil, author: nil, reels: nil)
        }
        if currentModel?.type == .sources {
            let source = currentModel?.sources?[indexPath.row]
            self.delegate?.didSelectCategory(location: nil, topics: nil, source: source, author: nil, reels: nil)
        }
        if currentModel?.type == .authors {
            let author = currentModel?.authors?[indexPath.row]
            self.delegate?.didSelectCategory(location: nil, topics: nil, source: nil, author: author, reels: nil)
        }
        if currentModel?.type == .reels {
            let reels = currentModel?.reels?[indexPath.row]
            self.delegate?.didSelectCategory(location: nil, topics: nil, source: nil, author: nil, reels: reels)
        }
    }
    
    //Topics favourite button Action
//    @objc func didTapTopicsFavButton(sender: UIButton) {
//
//        if let cell = collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? OnboardingTopicsCC {
//
//            cell.isUserInteractionEnabled = false
//            if let topic = currentModel?.topics?[sender.tag] {
//
//                let fav = topic.favorite ?? false
//                self.performWSToUpdateUserFollow(id: topic.id ?? "", isFav: fav, type: .topics) { [weak self] status in
//                    cell.isUserInteractionEnabled = true
//                    if status {
//
//                        //We are updating array locally
//                        self?.currentModel?.topics?[sender.tag].favorite = fav ? false : true
//                        self?.collectionView.reloadItems(at: [IndexPath(row: sender.tag, section: 0)])
//                    }
//                }
//            }
//        }
//    }

}

//MARK: - Update User Follow Webservices
extension RelevantCell {
    
    func performWSToUpdateUserFollow(id:String, isFav: Bool, type: searchType, completionHandler: @escaping CompletionHandler) {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
        //    SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        var params = ["topics":id]
        var url = isFav ? "news/topics/unfollow" : "news/topics/follow"
        if type == .sources {
            params = ["sources":id]
            url = isFav ? "news/sources/unfollow" : "news/sources/follow"
        }
        if type == .locations {
            params = ["locations":id]
            url = isFav ? "news/locations/unfollow" : "news/locations/follow"
        }
        if type == .authors {
            params = ["authors":id]
            url = isFav ? "news/authors/unfollow" : "news/authors/follow"
        }
        
        WebService.URLResponse(url, method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateTopicDC.self, from: response)
                
                if FULLResponse.message == "Success" {
                   completionHandler(true)
                } else {
                    completionHandler(false)
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                completionHandler(false)
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            
            completionHandler(false)
            print("error parsing json objects",error)
        }
    }
}


extension RelevantCell: AuthorDiscCCDelegate {
    
    func didTapFollow(cell: AuthorDiscCC) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let newFav = !(currentModel?.authors?[indexPath.row].favorite ?? false)
        currentModel?.authors?[indexPath.row].favorite = newFav
        collectionView.reloadItems(at: [indexPath])
        
        self.delegate?.didTapAddButton(cell: self, secondaryIndex: indexPath, favorite: currentModel?.authors?[indexPath.row].favorite ?? false)
    }
}

extension RelevantCell: OnboardingTopicsCCDelegate {
    
    
    func didTapAddButton(cell: OnboardingTopicsCC) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let newFav = !(currentModel?.topics?[indexPath.row].favorite ?? false)
        currentModel?.topics?[indexPath.row].favorite = newFav
        collectionView.reloadItems(at: [indexPath])
        self.delegate?.didTapAddButton(cell: self, secondaryIndex: indexPath, favorite: currentModel?.topics?[indexPath.row].favorite ?? false)
        
    }
    
}

extension RelevantCell: sugChannelCCDelegate {
    
    func addChannelTapped(cell: sugChannelCC) {

        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let newFav = !(currentModel?.sources?[indexPath.row].favorite ?? false)
        currentModel?.sources?[indexPath.row].favorite = newFav
        collectionView.reloadItems(at: [indexPath])
        self.delegate?.didTapAddButton(cell: self, secondaryIndex: indexPath, favorite: currentModel?.sources?[indexPath.row].favorite ?? false)
    }
    
}
