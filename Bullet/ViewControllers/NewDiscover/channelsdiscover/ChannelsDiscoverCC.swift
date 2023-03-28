//
//  ChannelsDiscoverCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 30/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol ChannelsDiscoverCCDelegate: AnyObject {
    
    func didTapOnChannelCell(cell: ChannelsDiscoverCC, secondaryIndexPath: IndexPath)
    func didTapAddButton(cell: ChannelsDiscoverCC, secondaryIndex: IndexPath, favorite: Bool)
}

class ChannelsDiscoverCC: UICollectionViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var content: DiscoverData?
    var sugChannelsArr: [ChannelInfo]?
    var idxRow = 0

    weak var delegate: ChannelsDiscoverCCDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setupCell(model: DiscoverData?, indexPath: IndexPath) {
        
        lblTitle.textColor = .black// GlobalPicker.textColor
        lblTitle.text = model?.title ?? ""

        self.idxRow = indexPath.row
        self.content = model
        sugChannelsArr = content?.data?.sources
        collectionView.register(UINib(nibName: "sugChannelCC", bundle: nil), forCellWithReuseIdentifier: "sugChannelCC")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        collectionView.reloadData()
//        collectionView.layoutIfNeeded()
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

extension ChannelsDiscoverCC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return sugChannelsArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sugChannelCC", for: indexPath) as! sugChannelCC
        
        //Check Upload Processing/scheduled on Article by User
        if let channel = sugChannelsArr?[indexPath.item] {
            cell.setupCell(model: channel)
        }
        cell.delegate = self
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width = collectionView.frame.size.width / 2.5
        if UIDevice.current.userInterfaceIdiom == .pad {
            width = 180
        }
        let height = collectionView.frame.size.height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.delegate?.didTapOnChannelCell(cell: self, secondaryIndexPath: indexPath)
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.discoverChannelOpen, channel_id: sugChannelsArr?[indexPath.item].id ?? "", section_name: lblTitle.text ?? "")

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}

extension ChannelsDiscoverCC: sugChannelCCDelegate {
    
    func addChannelTapped(cell: sugChannelCC) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let newFav = !(sugChannelsArr?[indexPath.row].favorite ?? false)
        sugChannelsArr?[indexPath.row].favorite = newFav
        collectionView.reloadItems(at: [indexPath])
        
        if (sugChannelsArr?[indexPath.row].favorite ?? false) {
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.discoverChannelFollow, channel_id: sugChannelsArr?[indexPath.item].id ?? "", section_name: lblTitle.text ?? "")
        } else {
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.discoverChannelUnfollow, channel_id: sugChannelsArr?[indexPath.item].id ?? "", section_name: lblTitle.text ?? "")
        }
        
        self.delegate?.didTapAddButton(cell: self, secondaryIndex: indexPath, favorite: sugChannelsArr?[indexPath.row].favorite ?? false)
        
    }
}
