//
//  ChannelsTableViewCell.swift
//  NewsReels2.0
//
//  Created by Harlene James Cruz on 6/3/22.
//

import UIKit

class ChannelsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    static let identifier = "ChannelsTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ChannelsTableViewCell", bundle: nil)
    }
    
    func configure(with models: [Channel]) {
        self.channelModels = models
        self.channelsCollectionView.cardView()
        channelsCollectionView.reloadData()
    }
    
    @IBOutlet var channelsCollectionView: UICollectionView!
    
    var channelModels = [Channel]()
    var numberCellPerRow = 2
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        channelsCollectionView.register(ChannelsCollectionViewCell.nib(), forCellWithReuseIdentifier: ChannelsCollectionViewCell.identifier)
        channelsCollectionView.delegate = self
        channelsCollectionView.dataSource = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channelModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = channelsCollectionView.dequeueReusableCell(withReuseIdentifier: ChannelsCollectionViewCell.identifier, for: indexPath) as! ChannelsCollectionViewCell
        
        cell.configure(with: channelModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 380, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
