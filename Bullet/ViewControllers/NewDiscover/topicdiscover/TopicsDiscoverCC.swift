//
//  TopicsDiscoverCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 29/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol TopicsDiscoverCCDelegate: AnyObject {
    func didSelectItem(cell: TopicsDiscoverCC, secondaryIndex: IndexPath)
    func didTapAddButton(cell: TopicsDiscoverCC, secondaryIndex: IndexPath, favorite: Bool)
}

class TopicsDiscoverCC: UICollectionViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var topicsArray = [TopicData]()
    weak var delegate: TopicsDiscoverCCDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(UINib(nibName: "OnboardingTopicsCC", bundle: nil), forCellWithReuseIdentifier: "OnboardingTopicsCC")
        
    }

    
    func setUpCell(model: DiscoverData?) {
        
        lblTitle.textColor = .black
        lblTitle.text = model?.title ?? ""
        if let topics = model?.data?.topics {
            self.topicsArray = topics
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        
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

extension TopicsDiscoverCC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return topicsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingTopicsCC", for: indexPath) as! OnboardingTopicsCC
        let topic = topicsArray[indexPath.row]
        cell.setUpReelsTopicsCells(topic: topic)
        cell.viewBG.backgroundColor = Constant.cellColors[indexPath.row % Constant.cellColors.count].hexStringToUIColor()
//        cell.restorationIdentifier = "topics"
        cell.delegate = self
        cell.layoutIfNeeded()
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //Topics CollectionView
        var topicName = ""
        topicName = topicsArray[indexPath.row].name ?? ""
        
        return CGSize(width: 245, height: 110)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        var topicName = ""
//        topicName = topicsArray[indexPath.row].name ?? ""
//        openTopic(text: topicName)
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.discoverTopicsOpen, topics_id: topicsArray[indexPath.item].id ?? "", section_name: lblTitle.text ?? "")

        self.delegate?.didSelectItem(cell: self, secondaryIndex: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    func openTopic(text: String) {
//        let vc = ReelsVC.instantiate(fromAppStoryboard: .Reels)
//        vc.titleText = "\(text)"
//        vc.isBackButtonNeeded = true
//        vc.modalPresentationStyle = .fullScreen
////        vc.delegate = self
//        vc.isOpenFromTags = true
//        let nav = AppNavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
//        self.present(nav, animated: true, completion: nil)
    }
}


extension TopicsDiscoverCC: OnboardingTopicsCCDelegate {
    
    func didTapAddButton(cell: OnboardingTopicsCC) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let newFav = !(topicsArray[indexPath.row].favorite ?? false)
        topicsArray[indexPath.row].favorite = newFav
        collectionView.reloadItems(at: [indexPath])
        
        
        if (topicsArray[indexPath.row].favorite ?? false) {
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.discoverTopicsFollow, topics_id: topicsArray[indexPath.item].id ?? "", section_name: lblTitle.text ?? "")
        } else {
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.discoverTopicsUnfollow, topics_id: topicsArray[indexPath.item].id ?? "", section_name: lblTitle.text ?? "")
        }
        
        
        self.delegate?.didTapAddButton(cell: self, secondaryIndex: indexPath, favorite: topicsArray[indexPath.row].favorite ?? false)
//        performWSToUpdateUserFollow(id: topicsArray[indexPath.row].id ?? "", isFav: topicsArray[indexPath.row].favorite ?? false) { status in
//            if status {
//                print("status", status)
//            } else {
//                print("status", status)
//            }
//        }
    }
    
}
