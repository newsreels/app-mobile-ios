//
//  TrendingTableViewCell.swift
//  NewsReels
//
//  Created by jhude lapuz on 6/2/22.
//

import UIKit

class TrendingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // The width of each cell with respect to the screen.
    // Can be a constant or a percentage.
    let cellPercentWidth: CGFloat = 0.50
    
    var titleNames: [String] = ["Philippines", "Canada", "Australia", "New Zealand", "Dubai"]
    var flagImages: [String] = ["PH-flag", "Canada-flag", "Australia-flag", "NewZealand-flag", "Dubai-flag"]
    var rankNumber: [String] = ["#232", "#123", "#321", "#323", "#333"]
    
    static let identifier = "TrendingTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "TrendingTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register( UINib(nibName: "TrendingCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TrendingCollectionViewCell")
        
        // Assign delegate and data source
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Get rid of scrolling indicators
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }
}

extension TrendingTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Grab our cell from dequeueReusableCell, wtih the same identifier we set in our storyboard.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendingCollectionViewCell", for: indexPath) as? TrendingCollectionViewCell?
        
        // Error checking, if our cell is somehow not able to be cast
        guard let carouselCell = cell else {
            print("Unable to instantiate user cell at index \(indexPath.row)")
            return UICollectionViewCell()
        }
        if indexPath.row == 1 {
            carouselCell?.photoView.image = UIImage(named: flagImages[indexPath.row])
            carouselCell?.titleLabel.text = titleNames[indexPath.row]
            carouselCell?.rankLabel.text = "Rank"
            carouselCell?.rankNumberLabel.text = rankNumber.randomElement()
        } else if indexPath.row == 2 {
            carouselCell?.photoView.image = UIImage(named: flagImages[indexPath.row])
            carouselCell?.titleLabel.text = titleNames[indexPath.row]
            carouselCell?.rankLabel.text = "Rank"
            carouselCell?.rankNumberLabel.text = rankNumber.randomElement()
        } else if indexPath.row == 3 {
            carouselCell?.photoView.image = UIImage(named: flagImages[indexPath.row])
            carouselCell?.titleLabel.text = titleNames[indexPath.row]
            carouselCell?.rankLabel.text = "Rank"
            carouselCell?.rankNumberLabel.text = rankNumber.randomElement()
        } else if indexPath.row == 4 {
            carouselCell?.photoView.image = UIImage(named: flagImages[indexPath.row])
            carouselCell?.titleLabel.text = titleNames[indexPath.row]
            carouselCell?.rankLabel.text = "Rank"
            carouselCell?.rankNumberLabel.text = rankNumber.randomElement()
        } else {
            carouselCell?.photoView.image = UIImage(named: flagImages[indexPath.row])
            carouselCell?.titleLabel.text = titleNames[indexPath.row]
            carouselCell?.rankLabel.text = "Rank"
            carouselCell?.rankNumberLabel.text = rankNumber.randomElement()
        }
        
        
        return carouselCell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let size = CGSize(width: self.bounds.width * cellPercentWidth, height: self.bounds.height)

        return size
    }
    
    // Add spaces at the beginning and the end of the collection view
      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
          return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
      }
}
