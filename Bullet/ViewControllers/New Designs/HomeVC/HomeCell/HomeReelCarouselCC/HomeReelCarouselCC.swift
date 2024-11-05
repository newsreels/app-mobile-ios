//
//  HomeReelCarouselCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 26/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol HomeReelCarouselCCDelegate: AnyObject {
    func didSelectItem(cell: HomeReelCarouselCC, secondaryIndex: IndexPath)
    func didTapOnChannel(cell: HomeReelCarouselCC, secondaryIndex: IndexPath)
    func setCurrentFocusedSelected(cell: HomeReelCarouselCC)
}

class HomeReelCarouselCC: UITableViewCell {

    @IBOutlet weak var collectionViewDiscover: UICollectionView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var flowLayout = ZoomAndSnapFlowLayout()
    var cellSize = CGSize(width: 100, height: 150)
    
    var suggReelsArr: [Reel]?
    
    
    weak var delegate: HomeReelCarouselCCDelegate?
    
    var currentlyFocusedIndexPath = IndexPath(item: 0, section: 0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            cellSize = CGSize(width: UIScreen.main.bounds.size.width/1.5, height: self.frame.size.height - 20)
        }
        else {
            cellSize = CGSize(width: UIScreen.main.bounds.size.width/1.5, height: self.frame.size.height - 175)
        }
        
        if cellSize.width < 0 || cellSize.height < 0 {
            cellSize = CGSize(width: 0, height: 0)
        }
        let horizontalInsets = (collectionViewDiscover.frame.width - collectionViewDiscover.adjustedContentInset.right - collectionViewDiscover.adjustedContentInset.left - cellSize.width) / 2
        let sectionInset = UIEdgeInsets(top: 0, left: horizontalInsets, bottom: 0, right: horizontalInsets)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            flowLayout = ZoomAndSnapFlowLayout(itemSize: CGSize(width: cellSize.width, height: cellSize.height), minimumLineSpacing: 62, sectionInset: sectionInset)
        }
        else {
            flowLayout = ZoomAndSnapFlowLayout(itemSize: CGSize(width: cellSize.width, height: cellSize.height), minimumLineSpacing: 22, sectionInset: sectionInset)

        }
        
        collectionViewDiscover.register(UINib(nibName: "ReelsCarouselCC", bundle: nil), forCellWithReuseIdentifier: "ReelsCarouselCC")
        
//        collectionViewDiscover.isPagingEnabled = true
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
    
    
    func setUpCell(content: articlesData?) {
        
        self.backgroundColor = .clear
        lblTitle.textColor = .black
        lblTitle.text = content?.title
        
        suggReelsArr = content?.suggestedReels
        
        collectionViewDiscover.delegate = self
        collectionViewDiscover.dataSource = self
        collectionViewDiscover.decelerationRate = .fast // uncomment if necessary
        collectionViewDiscover.contentInsetAdjustmentBehavior = .always
        collectionViewDiscover.collectionViewLayout = flowLayout
        
        collectionViewDiscover.reloadData()
    }
    
    func setUpCell(content: DiscoverData?) {
        
        self.backgroundColor = .clear
        lblTitle.textColor = .black
        lblTitle.text = content?.title
        
        suggReelsArr = content?.data?.reels
        
        collectionViewDiscover.delegate = self
        collectionViewDiscover.dataSource = self
        collectionViewDiscover.decelerationRate = .fast // uncomment if necessary
        collectionViewDiscover.contentInsetAdjustmentBehavior = .always
        collectionViewDiscover.collectionViewLayout = flowLayout
        
        collectionViewDiscover.reloadData()
    }
    
}


extension HomeReelCarouselCC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.delegate?.didSelectItem(cell: self, secondaryIndex: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return suggReelsArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionViewDiscover.dequeueReusableCell(withReuseIdentifier: "ReelsCarouselCC", for: indexPath) as! ReelsCarouselCC
        cell.setUpCell(reel: suggReelsArr?[indexPath.item])
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cell = collectionViewDiscover.cellForItem(at: indexPath) as? ReelsCarouselCC {
            cell.stopVideo()
        }
        
    }
}

extension HomeReelCarouselCC {
    
    
    func pauseAllCurrentlyFocusedMedia() {
        
        if let cell = collectionViewDiscover.cellForItem(at: currentlyFocusedIndexPath) as? ReelsCarouselCC {
           
            cell.stopVideo()
            
        }
        
    }
    
    func playCurrentlyFocusedMedia() {
        
        
        if SharedManager.shared.reelsAutoPlay {
            
            if let cell = collectionViewDiscover.cellForItem(at: currentlyFocusedIndexPath) as? ReelsCarouselCC {
                cell.playVideo()
            }
            
            self.delegate?.setCurrentFocusedSelected(cell: self)
        }
        
        
        
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        SharedManager.shared.isOnDiscover = true
        pauseAllCurrentlyFocusedMedia()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        scrollView.decelerationRate = .fast//UIScrollView.DecelerationRate(rawValue: 0.994000); //0.998000
    }
        
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        self.scrollToTopVisibleCell()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        //ScrollView for ListView Mode
        if decelerate { return }
        self.scrollToTopVisibleCell()
    }

    func centerCellIndexPath() -> IndexPath? {
        
        let initialPinchPoint = CGPoint(x: self.collectionViewDiscover.center.x + self.collectionViewDiscover.contentOffset.x,
                                        y: self.collectionViewDiscover.center.y + self.collectionViewDiscover.contentOffset.y)
        
        return collectionViewDiscover.indexPathForItem(at: initialPinchPoint)
    }
    
    
    func scrollToTopVisibleCell() {
        
        guard let indexPathVisible: IndexPath = centerCellIndexPath() else {
            return
        }
        if let arr = self.suggReelsArr, arr.count > 0 {
            
            if let cell = collectionViewDiscover.cellForItem(at: indexPathVisible) as? ReelsCarouselCC {
                
                pauseAllCurrentlyFocusedMedia()
                
                currentlyFocusedIndexPath = indexPathVisible
                
                playCurrentlyFocusedMedia()
            }
            
//            if indexPathVisible.item != indexPathVisible.item {
//
//                if let cell = collectionViewDiscover.cellForItem(at: indexPathVisible) as? ReelsCarouselCC {
//
//                    cell.playVideo()
//                }
//
//            } else {
//
//
//
//            }
            
        }
    }
    
}

extension HomeReelCarouselCC: ReelsCarouselCCDelegate {
    
    func playVideo(cell: ReelsCarouselCC) {
        
        guard let indexPath = collectionViewDiscover.indexPath(for: cell) else {
            return
        }
        if currentlyFocusedIndexPath != indexPath {
            return
        }
        pauseAllCurrentlyFocusedMedia()
        currentlyFocusedIndexPath = indexPath
        cell.playVideo()
        self.delegate?.setCurrentFocusedSelected(cell: self)
    }
    
    
    func openDetailsVC(cell: ReelsCarouselCC) {
        
        guard let indexPath = collectionViewDiscover.indexPath(for: cell) else {
            return
        }
        self.delegate?.didSelectItem(cell: self, secondaryIndex: indexPath)
        
    }
    
    func openChannelDetailVC(cell: ReelsCarouselCC) {
        
        guard let indexPath = collectionViewDiscover.indexPath(for: cell) else {
            return
        }
        self.delegate?.didTapOnChannel(cell: self, secondaryIndex: indexPath)
    }
}
