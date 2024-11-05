//
//  sugClvChannelsCC.swift
//  Bullet
//
//  Created by Mahesh on 07/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

let COLLECTION_HEIGHT_TOPICS: CGFloat      = 340 + 50 //cell + header title

protocol sugClvTopicsCCDelegate: AnyObject {
    
    func didTapOnTopicCell(cell: UITableViewCell, row: Int, isTapOnButton: Bool)
    
}

class sugClvTopicsCC: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var clv1: UICollectionView!
    @IBOutlet weak var clv2: UICollectionView!
    @IBOutlet weak var clv3: UICollectionView!
    
    @IBOutlet weak var stackviewwidthConstraint: NSLayoutConstraint!
    
    var content: articlesData?
    var allTopicsArray = [TopicData]()
    var topicArray1 = [TopicData]()
    var topicArray2 = [TopicData]()
    var topicArray3 = [TopicData]()
    //var idxRow = 0
    var cellColors = ["E01335","5025E1","975D1B","E13300","641E58","83A52C","1E3264", "850000", "15B9C5"]

    weak var delegateSugTopics: sugClvTopicsCCDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    override func layoutSubviews() {
        self.layoutIfNeeded()
        
        let width = max(clv1.contentSize.width, clv2.contentSize.width, clv3.contentSize.width)

        self.stackviewwidthConstraint.constant = width + 20
    }
    
    func setupCell(content: articlesData, row: Int) {
        
        lblTitle.theme_textColor = GlobalPicker.textColor
        lblTitle.text = content.title

        //self.idxRow = row
        self.content = content
        if let topic = content.suggestedTopics {
            allTopicsArray = topic
        }
        
        clv1.register(UINib(nibName: "SelectTopicCC", bundle: nil), forCellWithReuseIdentifier: "SelectTopicCC")
        clv2.register(UINib(nibName: "SelectTopicCC", bundle: nil), forCellWithReuseIdentifier: "SelectTopicCC")
        clv3.register(UINib(nibName: "SelectTopicCC", bundle: nil), forCellWithReuseIdentifier: "SelectTopicCC")

        setupCollectionView()
    }
    
    
    func setupCollectionView() {
        
        clv1.isScrollEnabled = false
        clv2.isScrollEnabled = false
        clv3.isScrollEnabled = false
        
        clv1.delegate = self
        clv1.dataSource = self
        clv1.backgroundColor = .clear
        
        clv2.delegate = self
        clv2.dataSource = self
        clv2.backgroundColor = .clear
        
        clv3.delegate = self
        clv3.dataSource = self
        clv3.backgroundColor = .clear
        
        let part1 = Int((Double(allTopicsArray.count)/3).rounded(.awayFromZero))
        let part2 = (part1)*2
        let part3 = allTopicsArray.count
        
        topicArray1.removeAll()
        topicArray2.removeAll()
        topicArray3.removeAll()
        
        if part1 >= 3 {
            for i in 0...(part1 - 1) {
//                print("parts index1 ",i)
                topicArray1.append(allTopicsArray[i])
            }
            for i in part1...(part2 - 1) {
//                print("parts index2 ",i)
                topicArray2.append(allTopicsArray[i])
            }
            for i in part2...(part3 - 1) {
//                print("parts index3 ",i)
                topicArray3.append(allTopicsArray[i])
            }
        }
        else {
            topicArray1 = allTopicsArray
        }
        if topicArray1.count == 0 {
            clv1.isHidden = true
        }
        if topicArray2.count == 0 {
            clv2.isHidden = true
        }
        if topicArray3.count == 0 {
            clv3.isHidden = true
        }
        
        
        
        reloadCollectionViews()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        clv2.setContentOffset(clv1.contentOffset, animated: true)
        clv3.setContentOffset(clv1.contentOffset, animated: true)
        
    }
    
    
    func reloadCollectionViews() {
        
        clv1.collectionViewLayout.invalidateLayout()
        clv2.collectionViewLayout.invalidateLayout()
        clv3.collectionViewLayout.invalidateLayout()
        
        clv1.reloadData()
        clv2.reloadData()
        clv3.reloadData()
        
        self.layoutSubviews()
    }
    
}

extension sugClvTopicsCC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == clv1 {
            return topicArray1.count
        }
        else if collectionView == clv2 {
            return topicArray2.count
        }
        else {
            return topicArray3.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectTopicCC", for: indexPath) as! SelectTopicCC
        
        //Check Upload Processing/scheduled on Article by User
//        if let topic = sugTopicsArr?[indexPath.row] {
//
//            cell.lblTopic.textColor = .white
//            cell.lblTopic.text = topic.name?.uppercased()
//            cell.lblTopic.addTextSpacing(spacing: 2.6)
//            cell.imgTopic.sd_setImage(with: URL(string: topic.image ?? "") , placeholderImage: nil)
//            cell.updateFavoriteStatus(isFavorite: (topic.favorite ?? false) ? true : false)
//        }
        /*
        if let topic = sugTopicsArr?[indexPath.row] {
            cell.setUpReelsTopicsCells(topic: topic)
       //     cell.viewBG.backgroundColor = cellColors[indexPath.row % cellColors.count].hexStringToUIColor()
            cell.restorationIdentifier = "suggested"
            cell.delegate = self
        }*/
        if collectionView == clv1 {
            let topic = topicArray1[indexPath.row]
            cell.setupCell(topic: topic, isShowingTrending: true)
        }
        else if collectionView == clv2 {
            let topic = topicArray2[indexPath.row]
            cell.setupCell(topic: topic, isShowingTrending: true)
        }
        else {
            let topic = topicArray3[indexPath.row]
            cell.setupCell(topic: topic, isShowingTrending: true)
        }
        cell.delegate = self
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var id = ""
        if collectionView == clv1 {
            id = topicArray1[indexPath.item].id ?? ""
        }
        else if collectionView == clv2 {
            id = topicArray2[indexPath.item].id ?? ""
        }
        else if collectionView == clv3 {
            id = topicArray3[indexPath.item].id ?? ""
        }
        else {
            return
        }
        
        guard let selectedIndex = allTopicsArray.firstIndex(where: { $0.id == id }) else { return }
        self.delegateSugTopics?.didTapOnTopicCell(cell: self, row: selectedIndex, isTapOnButton: false)
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 8
//    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width: CGFloat = 0
        if collectionView == clv1 {
            let topic = topicArray1[indexPath.row]
            let size = topic.name?.textSize(UIFont(name: Constant.FONT_ROBOTO_REGULAR, size: 14) ?? .systemFont(ofSize: 16))
            width = (size?.width ?? 0) + 55
        }
        else if collectionView == clv2 {
            let topic = topicArray2[indexPath.row]
            let size = topic.name?.textSize(UIFont(name: Constant.FONT_ROBOTO_REGULAR, size: 14) ?? .systemFont(ofSize: 16))
            width = (size?.width ?? 0) + 55
        }
        else {
            let topic = topicArray3[indexPath.row]
            let size = topic.name?.textSize(UIFont(name: Constant.FONT_ROBOTO_REGULAR, size: 14) ?? .systemFont(ofSize: 16))
            width = (size?.width ?? 0) + 55
        }
        if width < 50 {
            width = 120
        }
        
        return CGSize(width: width, height: collectionView.frame.size.height - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}


extension sugClvTopicsCC: OnboardingTopicsCCDelegate {
    
    func didTapAddButton(cell: OnboardingTopicsCC) {
        
//        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        /*
        let fav = sugTopicsArr?[indexPath.row].favorite ?? false
        sugTopicsArr?[indexPath.row].favorite = !fav
        collectionView.reloadItems(at: [indexPath])
        self.delegateSugTopics?.didTapOnTopicCell(cell: self, row: indexPath.row, isTapOnButton: true)*/
    }
}


extension sugClvTopicsCC: SelectTopicCCDelegate {
    
    func didTapClose(cell: SelectTopicCC) {
        
        var indexP = IndexPath(item: 0, section: 0)
        var id = ""
        if let indexPath = clv1.indexPath(for: cell) {
            indexP = indexPath
            id = topicArray1[indexP.row].id ?? ""
        }
        else if let indexPath = clv2.indexPath(for: cell) {
            indexP = indexPath
            id = topicArray2[indexP.row].id ?? ""
        }
        else if let indexPath = clv3.indexPath(for: cell) {
            indexP = indexPath
            id = topicArray3[indexP.row].id ?? ""
        }
        else {
            return
        }
        
        guard let selectedIndex = allTopicsArray.firstIndex(where: { $0.id == id }) else { return }
        
        self.delegateSugTopics?.didTapOnTopicCell(cell: self, row: selectedIndex, isTapOnButton: true)
        
        
    }
    
    
}

