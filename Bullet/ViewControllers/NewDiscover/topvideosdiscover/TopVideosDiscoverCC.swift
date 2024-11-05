//
//  TopVideosDiscoverCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 30/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol TopVideosDiscoverCCDelegate: AnyObject {
    func didSelectItem(cell: TopVideosDiscoverCC, secondaryIndex: IndexPath)
    
    func setCurrentFocusedSelected(cell: TopVideosDiscoverCC)
    
    func scrollViewScrolling(collection: TopVideosDiscoverCC, status: Bool)
}

class TopVideosDiscoverCC: UICollectionViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var flowLayout = ZoomAndSnapFlowLayout()
    var cellSize = CGSize(width: 100, height: 150)
    
    var articlesArray = [articlesData]()
    weak var delegate: TopVideosDiscoverCCDelegate?
    var currentlyFocusedIndexPath = IndexPath(item: 0, section: 0)

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        lblTitle.textColor = .black
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            cellSize = CGSize(width: UIScreen.main.bounds.size.width/2.6, height: self.frame.size.height)
        }
        else {
            cellSize = CGSize(width: UIScreen.main.bounds.size.width/1.4, height: self.frame.size.height - 55)
        }
        if cellSize.width < 0 || cellSize.height < 0 {
            cellSize = CGSize(width: 0, height: 0)
        }
        let horizontalInsets = (collectionView.frame.width - collectionView.adjustedContentInset.right - collectionView.adjustedContentInset.left - cellSize.width) / 2
        let sectionInset = UIEdgeInsets(top: 0, left: horizontalInsets, bottom: 0, right: horizontalInsets)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            flowLayout = ZoomAndSnapFlowLayout(itemSize: CGSize(width: cellSize.width, height: cellSize.height), minimumLineSpacing: 50, sectionInset: sectionInset)
        }
        else {
            flowLayout = ZoomAndSnapFlowLayout(itemSize: CGSize(width: cellSize.width, height: cellSize.height), minimumLineSpacing: 22, sectionInset: sectionInset)

        }
        
        collectionView.register(UINib(nibName: "VideoCarouselCC", bundle: nil), forCellWithReuseIdentifier: "VideoCarouselCC")
        
    }

    
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
            }
            
        } else {
            
            DispatchQueue.main.async {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
            }
            
        }
        
    }
    
    
    
    func setUpCell(model: DiscoverData?) {
        
        if let videos = model?.data?.articles {
            articlesArray = videos
        }
        
        self.lblTitle.text = model?.title ?? ""
//        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.decelerationRate = .fast
               //collectionView.decelerationRate = .fast // uncomment if necessary
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.collectionViewLayout = flowLayout
        
        collectionView.reloadData()
    }
    
    
}


extension TopVideosDiscoverCC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.delegate?.didSelectItem(cell: self, secondaryIndex: indexPath)
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.discoverVideosOpen, article_id: articlesArray[indexPath.item].id ?? "", section_name: lblTitle.text ?? "")

        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articlesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCarouselCC", for: indexPath) as! VideoCarouselCC
        cell.setupCell(model: articlesArray[indexPath.item])
        cell.delegate = self
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? VideoCarouselCC {
            cell.stopVideo()
        }
        
    }
}


extension TopVideosDiscoverCC {
    
    
    func pauseAllCurrentlyFocusedMedia() {
        
        if let cell = collectionView.cellForItem(at: currentlyFocusedIndexPath) as? VideoCarouselCC {
           
            cell.stopVideo()
            
        }
        
    }
    
    func playCurrentlyFocusedMedia() {
        
        if let cell = collectionView.cellForItem(at: currentlyFocusedIndexPath) as? VideoCarouselCC {
           
            if SharedManager.shared.videoAutoPlay {
                cell.playVideo()
            }
            self.delegate?.setCurrentFocusedSelected(cell: self)
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.discoverVideosWatch, article_id: articlesArray[currentlyFocusedIndexPath.item].id ?? "", section_name: lblTitle.text ?? "")

        }
        
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        SharedManager.shared.isOnDiscover = true
        pauseAllCurrentlyFocusedMedia()
        
        self.delegate?.scrollViewScrolling(collection: self, status: true)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        scrollView.decelerationRate = .fast//UIScrollView.DecelerationRate(rawValue: 0.994000); //0.998000
    }
        
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        self.scrollToTopVisibleCell()
        
        self.delegate?.scrollViewScrolling(collection: self, status: false)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        //ScrollView for ListView Mode
        if decelerate { return }
        self.scrollToTopVisibleCell()
        
        self.delegate?.scrollViewScrolling(collection: self, status: false)
    }

    func centerCellIndexPath() -> IndexPath? {
        
        let initialPinchPoint = CGPoint(x: self.collectionView.center.x + self.collectionView.contentOffset.x,
                                        y: self.collectionView.center.y + self.collectionView.contentOffset.y)
        
        return collectionView.indexPathForItem(at: initialPinchPoint)
    }
    
    
    func scrollToTopVisibleCell() {
        
        guard let indexPathVisible: IndexPath = centerCellIndexPath() else {
            return
        }
        if self.articlesArray.count > 0 {
            
            if let cell = collectionView.cellForItem(at: indexPathVisible) as? VideoCarouselCC {
                
                pauseAllCurrentlyFocusedMedia()
                
                currentlyFocusedIndexPath = indexPathVisible
                
                playCurrentlyFocusedMedia()
            }
            
//            if indexPathVisible.item != indexPathVisible.item {
//
//                if let cell = collectionViewDiscover.cellForItem(at: indexPathVisible) as? VideoCarouselCC {
//
//                    cell.playVideo()
//                }
//
//            } else {
//
//cell.playCurrentlyFocusedMedia()cell.playCurrentlyFocusedMedia()cell.playCurrentlyFocusedMedia()cell.playCurrentlyFocusedMedia()cell.playCurrentlyFocusedMedia()
//
//            }
            
            
        }
    }
    
}

extension TopVideosDiscoverCC: VideoCarouselCCDelegate {
    
    func openDetailsVC(cell: VideoCarouselCC) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        self.delegate?.didSelectItem(cell: self, secondaryIndex: indexPath)
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.discoverVideosOpen, article_id: articlesArray[indexPath.item].id ?? "", section_name: lblTitle.text ?? "")

        
    }
    
    func playVideo(cell: VideoCarouselCC) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        if currentlyFocusedIndexPath != indexPath {
            return
        }
        
        
        pauseAllCurrentlyFocusedMedia()
        currentlyFocusedIndexPath = indexPath
        cell.playVideo()
        self.delegate?.setCurrentFocusedSelected(cell: self)
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.discoverVideosWatch, article_id: articlesArray[indexPath.item].id ?? "", section_name: lblTitle.text ?? "")

        
    }
    
}
