//
//  sugClvChannelsCC.swift
//  Bullet
//
//  Created by Mahesh on 07/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

let COLLECTION_HEIGHT_CHANNEL: CGFloat      = 225 + 50 //cell + header title

protocol sugClvChannelsCCDelegate: AnyObject {
    
    func didTapOnChannelCell(cell: UITableViewCell, row: Int, isTapOnButton: Bool)
}

class sugClvChannelsCC: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var content: articlesData?
    var sugChannelsArr: [ChannelInfo]?
    var idxRow = 0

    weak var delegateSugChannels: sugClvChannelsCCDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setupCell(content: articlesData, row: Int) {
        
        lblTitle.theme_textColor = GlobalPicker.textColor
        lblTitle.text = content.title

        self.idxRow = row
        self.content = content
        sugChannelsArr = content.suggestedChannels
        collectionView.register(UINib(nibName: "sugChannelCC", bundle: nil), forCellWithReuseIdentifier: "sugChannelCC")

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
}

extension sugClvChannelsCC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return sugChannelsArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sugChannelCC", for: indexPath) as! sugChannelCC
        
        //Check Upload Processing/scheduled on Article by User
        if let channel = sugChannelsArr?[indexPath.row] {
            cell.setupCell(model: channel)
            
            
            cell.langCode = channel.language ?? ""
            
            cell.channelButtonPressedBlock = {

//                cell.isUserInteractionEnabled = false
                let fav = channel.favorite ?? false
                self.sugChannelsArr?[indexPath.row].favorite = fav ? false : true
                self.collectionView.reloadItems(at: [indexPath])
                self.delegateSugChannels?.didTapOnChannelCell(cell: self, row: indexPath.row, isTapOnButton: true)

//                self.performWSToUpdateUserFollow(id: channel.id ?? "", isFav: fav) { [weak self] status in
//                    cell.isUserInteractionEnabled = true
//                    if status { }
//                }
            }
        }
        
        
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width / 2.2
        let height = collectionView.frame.size.height        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.delegateSugChannels?.didTapOnChannelCell(cell: self, row: indexPath.row, isTapOnButton: false)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
}
