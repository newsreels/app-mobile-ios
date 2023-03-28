//
//  CryptoPricesTableViewCell.swift
//  NewsReels2.0
//
//  Created by Harlene James Cruz on 6/1/22.
//

import UIKit

class CryptoPricesTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    static let identifier = "CryptoPricesTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "CryptoPricesTableViewCell", bundle: nil)
    }
    
    func configure(with models: [CryptoPrice]) {
        self.cryptoPricesModels = models
        cryptoPricesCollectionView.reloadData()
    }
    
    @IBOutlet var cryptoPricesCollectionView: UICollectionView!
    
    var cryptoPricesModels = [CryptoPrice]()
    let numberCellPerRow: CGFloat = 2
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cryptoPricesCollectionView.register(CryptoPricesCollectionViewCell.nib(), forCellWithReuseIdentifier: CryptoPricesCollectionViewCell.identifier)
        cryptoPricesCollectionView.delegate = self
        cryptoPricesCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cryptoPricesModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cryptoPricesCollectionView.dequeueReusableCell(withReuseIdentifier: CryptoPricesCollectionViewCell.identifier, for: indexPath) as! CryptoPricesCollectionViewCell
        
        cell.configure(with: cryptoPricesModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (cryptoPricesCollectionView.frame.width) / numberCellPerRow, height: 140 / numberCellPerRow)
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
