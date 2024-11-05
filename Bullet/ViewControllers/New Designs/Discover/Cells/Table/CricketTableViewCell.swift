//
//  CricketTableViewCell.swift
//  NewsReels2.0
//
//  Created by Harlene James Cruz on 6/1/22.
//

import UIKit

class CricketTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    static let identifier = "CricketTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "CricketTableViewCell", bundle: nil)
    }
    
    func configure(with models: [Cricket]) {
        self.cricketModels = models
        cricketCollectionView.reloadData()
    }
    
    var cricketModels = [Cricket]()
    var numberCellPerRow = 2
    @IBOutlet var cricketCollectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        cricketCollectionView.register(CricketCollectionViewCell.nib(), forCellWithReuseIdentifier: CricketCollectionViewCell.identifier)
        cricketCollectionView.delegate = self
        cricketCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cricketModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cricketCollectionView.dequeueReusableCell(withReuseIdentifier: CricketCollectionViewCell.identifier, for: indexPath) as! CricketCollectionViewCell
        
        cell.configure(with: cricketModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 700, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
    }
}
