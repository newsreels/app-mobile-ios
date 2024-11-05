//
//  TabView.swift
//  TabPageViewController
//
//  Created by EndouMari on 2016/02/24.
//  Copyright © 2016年 EndouMari. All rights reserved.
//

import UIKit

protocol TabViewDelegate: AnyObject {
    
    func didTapBtnSubCategory()
}

internal class TabView: UIView {

    var pageItemPressedBlock: ((_ index: Int, _ direction: UIPageViewController.NavigationDirection) -> Void)?

    var pageTabItems: [String] = [] {
        didSet {
            pageTabItemsCount = pageTabItems.count
            beforeIndex = pageTabItems.count
        }
    }
    var layouted: Bool = false

    fileprivate var isInfinity: Bool = false
    fileprivate var option: TabPageOption = TabPageOption()
    fileprivate var beforeIndex: Int = 0
    fileprivate var currentIndex: Int = 0
    fileprivate var pageTabItemsCount: Int = 0
    fileprivate var shouldScrollToItem: Bool = false
    fileprivate var pageTabItemsWidth: CGFloat = 0.0
    fileprivate var collectionViewContentOffsetX: CGFloat = 0.0
    fileprivate var currentBarViewWidth: CGFloat = 0.0
    fileprivate var cellForSize: TabCollectionCell!
    fileprivate var cachedCellSizes: [IndexPath: CGSize] = [:]
    fileprivate var currentBarViewLeftConstraint: NSLayoutConstraint?
//    fileprivate var setFirstCell: TabCollectionCell!
    weak var delegate: TabViewDelegate?
    
    
    var isGradientRequired = false {
        didSet {
            setGradient()
        }
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnSubCategory: UIButton!
    @IBOutlet weak var imgGradient: UIImageView!
    @IBOutlet weak var viewMenu: UIView!

    @IBOutlet fileprivate weak var currentBarView: UIView!
    @IBOutlet fileprivate weak var currentBarViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var currentBarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var bottomBarViewHeightConstraint: NSLayoutConstraint!

    override func layoutSubviews() {
        
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
                self.imgGradient.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
            
        } else {
            DispatchQueue.main.async {
                self.imgGradient.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }
    
    init(isInfinity: Bool, option: TabPageOption) {
        super.init(frame: CGRect.zero)
        
        self.option = option
        self.isInfinity = isInfinity
        Bundle(for: TabView.self).loadNibNamed("TabView", owner: self, options: nil)
//        contentView.backgroundColor = option.tabBackgroundColor.withAlphaComponent(option.tabBarAlpha)
//        contentView.theme_backgroundColor = GlobalPicker.customTabbarBGColor
        addSubview(contentView)

        //btnSubCategory.theme_setImage(GlobalPicker.btImgMenu, forState: .normal)
        
        let top = NSLayoutConstraint(item: contentView as Any,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 0.0)

        let left = NSLayoutConstraint(item: contentView as Any,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0.0)

        let bottom = NSLayoutConstraint (item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0.0)

        let right = NSLayoutConstraint(item: self,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0.0)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([top, left, bottom, right])

        let bundle = Bundle(for: TabView.self)
        let nib = UINib(nibName: TabCollectionCell.cellIdentifier(), bundle: bundle)
        collectionView.register(nib, forCellWithReuseIdentifier: TabCollectionCell.cellIdentifier())
        cellForSize = nib.instantiate(withOwner: nil, options: nil).first as! TabCollectionCell
        
//        if SharedManager.shared.isLanguageRTL {
//            collectionView.transform = CGAffineTransform.init(scaleX: -1, y: 1)
//        } else {
//            collectionView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
//        }
//        collectionView.setContentOffset(.zero, animated: false)
        collectionView.scrollsToTop = false
        
        NotificationCenter.default.removeObserver(Notification.Name.notifyTapSubcategories)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyTapSubcategories, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapSubcategories(notification:)), name: Notification.Name.notifyTapSubcategories, object: nil)
        
        //collectionView.backgroundColor = UIColor.green
        //currentBarView.theme_backgroundColor = GlobalPicker.tabCurrentViewBG
//        currentBarView.backgroundColor = "#3AD9D2".hexStringToUIColor()
//        currentBarView.layer.cornerRadius = currentBarView.frame.height / 2
//        currentBarViewHeightConstraint.constant = option.currentBarHeight

        //currentBarView.backgroundColor = .green
//        currentBarView.theme_backgroundColor = GlobalPicker.textMainTabSelectedLineColor
        
        currentBarView.backgroundColor = Constant.appColor.lightRed
        currentBarViewHeightConstraint.constant = option.currentBarHeight
        
        if !isInfinity {
            currentBarView.removeFromSuperview()
            collectionView.addSubview(currentBarView)
            currentBarView.translatesAutoresizingMaskIntoConstraints = false
            let top = NSLayoutConstraint(item: currentBarView,
                attribute: .top,
                relatedBy: .equal,
                toItem: collectionView,
                attribute: .top,
                multiplier: 1.0,
                constant: option.tabHeight - currentBarViewHeightConstraint.constant)

            let left = NSLayoutConstraint(item: currentBarView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: collectionView,
                attribute: .leading,
                multiplier: 1.0,
                constant: 0.0)
            currentBarViewLeftConstraint = left
            collectionView.addConstraints([top, left])
            
            currentBarView.roundCorners([.topLeft, .topRight], currentBarView.frame.height / 2)
        }

        bottomBarViewHeightConstraint.constant = 1.0 / UIScreen.main.scale
                
//        viewGradient.dropShadow2(color: MyThemes.current == .dark ? UIColor.black : UIColor.white, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 5, scale: true)
//            = MyThemes.current == .dark ? UIColor.black : UIColor.white
//        viewVolumeContainer.bottomColor = MyThemes.current == .dark ? UIColor.black : UIColor.white
//        viewVolumeContainer.shadowColor = MyThemes.current == .dark ? UIColor.black : UIColor.white

        setGradient()
    }
    

    func setGradient() {
        
        btnSubCategory.isHidden = false
        imgGradient.isHidden = false

//        if isGradientRequired {
//            btnSubCategory.isHidden = false
//            imgGradient.isHidden = false
//            imgGradient.theme_image = GlobalPicker.tabBarGradient
//        } else {
//            btnSubCategory.isHidden = true
//            imgGradient.isHidden = true
//        }
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func didTapBtnSubCategory(_ sender: Any) {
        delegate?.didTapBtnSubCategory()
    }
    
}


// MARK: - View

extension TabView {

    /**
     Called when you swipe in isInfinityTabPageViewController, moves the contentOffset of collectionView

     - parameter index: Next Index
     - parameter contentOffsetX: contentOffset.x of scrollView of isInfinityTabPageViewController
     */
    func scrollCurrentBarView(_ index: Int, contentOffsetX: CGFloat) {
        var nextIndex = isInfinity ? index + pageTabItemsCount : index
        if isInfinity && index == 0 && (beforeIndex - pageTabItemsCount) == pageTabItemsCount - 1 {
            // Calculate the index at the time of transition to the first item from the last item of pageTabItems
            nextIndex = pageTabItemsCount * 2
        } else if isInfinity && (index == pageTabItemsCount - 1) && (beforeIndex - pageTabItemsCount) == 0 {
            // Calculate the index at the time of transition from the first item of pageTabItems to the last item
            nextIndex = pageTabItemsCount - 1
        }

        if collectionViewContentOffsetX == 0.0 {
            collectionViewContentOffsetX = collectionView.contentOffset.x
        }

        let currentIndexPath = IndexPath(item: currentIndex, section: 0)
        let nextIndexPath = IndexPath(item: nextIndex, section: 0)
        if let currentCell = collectionView.cellForItem(at: currentIndexPath) as? TabCollectionCell, let nextCell = collectionView.cellForItem(at: nextIndexPath) as? TabCollectionCell {
            nextCell.hideCurrentBarView()
            currentCell.hideCurrentBarView()
            currentBarView.isHidden = false

            if currentBarViewWidth == 0.0 {
                currentBarViewWidth = currentCell.frame.width
            }

            let distance = (currentCell.frame.width / 2.0) + (nextCell.frame.width / 2.0)
            let scrollRate = contentOffsetX / frame.width

            if fabs(scrollRate) > 0.6 {
                nextCell.highlightTitle()
                currentCell.unHighlightTitle()
            } else {
                nextCell.unHighlightTitle()
                currentCell.highlightTitle()
            }

            let width = fabs(scrollRate) * (nextCell.frame.width - currentCell.frame.width)
            if isInfinity {
                let scroll = scrollRate * distance
                collectionView.contentOffset.x = collectionViewContentOffsetX + scroll
            } else {
                if scrollRate > 0 {
                currentBarViewLeftConstraint?.constant = currentCell.frame.minX + scrollRate * currentCell.frame.width
                } else {
                    currentBarViewLeftConstraint?.constant = currentCell.frame.minX + nextCell.frame.width * scrollRate
                }
            }
            currentBarViewWidthConstraint.constant = currentBarViewWidth + width
        }
    }

    /**
     Center the current cell after page swipe
     */
    func scrollToHorizontalCenter() {
        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        collectionViewContentOffsetX = collectionView.contentOffset.x
    }

    /**
     Called in after the transition is complete pages in isInfinityTabPageViewController in the process of updating the current

     - parameter index: Next Index
     */
    func updateCurrentIndex(_ index: Int, shouldScroll: Bool) {
        deselectVisibleCells()

        currentIndex = isInfinity ? index + pageTabItemsCount : index

        let indexPath = IndexPath(item: currentIndex, section: 0)
        moveCurrentBarView(indexPath, animated: !isInfinity, shouldScroll: shouldScroll)
    }

    /**
     Make the tapped cell the current if isInfinity is true

     - parameter index: Next IndexPath√
     */
    
    @objc func didTapSubcategories( notification: NSNotification) {
        
        //var catSelectedIndex = 0
        
        if let index = SharedManager.shared.reelsCategories.firstIndex(where: {$0.id == SharedManager.shared.curReelsCategoryId}) {
            
            SharedManager.shared.curCategoryIndex = index
            
            DispatchQueue.main.async {
                
                if SharedManager.shared.reelsCategories.count == self.collectionView.numberOfItems(inSection: 0) {
                    self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
                }
//                if let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? TabCollectionCell {

                    let indexPath = IndexPath(item: index, section: 0)
                    var direction: UIPageViewController.NavigationDirection = .forward
                    if self.isInfinity == true {
                        if (indexPath.item < self.pageTabItemsCount) || (indexPath.item < self.currentIndex) {
                            direction = .reverse
                        }
                    } else {
                        if indexPath.item < self.currentIndex {
                            direction = .reverse
                        }
                    }
                    
                    self.pageItemPressedBlock?(index, direction)
                    
//                    if cell.isCurrent == false {
//                        // Not accept touch events to scroll the animation is finished
//                        self.updateCollectionViewUserInteractionEnabled(false)
//                    }
                    
                    self.updateCurrentIndexForTap(indexPath.item)
//                }
                
//                self.updateCurrentIndexForTap(index)
            }
        }
    }
    
    fileprivate func updateCurrentIndexForTap(_ index: Int) {
        deselectVisibleCells()

        if isInfinity && (index < pageTabItemsCount) || (index >= pageTabItemsCount * 2) {
            currentIndex = (index < pageTabItemsCount) ? index + pageTabItemsCount : index - pageTabItemsCount
            shouldScrollToItem = true
        } else {
            currentIndex = index
        }
        let indexPath = IndexPath(item: index, section: 0)
        moveCurrentBarView(indexPath, animated: true, shouldScroll: true)
    }

    /**
     Move the collectionView to IndexPath of Current

     - parameter indexPath: Next IndexPath
     - parameter animated: true when you tap to move the isInfinityTabCollectionCell
     - parameter shouldScroll:
     */
    fileprivate func moveCurrentBarView(_ indexPath: IndexPath, animated: Bool, shouldScroll: Bool) {
        if shouldScroll {
            
            if SharedManager.shared.isAppLaunchFirstTIME {
                
                SharedManager.shared.isAppLaunchFirstTIME = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    
                    self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
                    self.layoutIfNeeded()
                }
            }
            
            if pageTabItemsCount == collectionView.numberOfItems(inSection: 0) {
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
                layoutIfNeeded()
                collectionViewContentOffsetX = 0.0
                currentBarViewWidth = 0.0
            }
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? TabCollectionCell {
            currentBarView.isHidden = false
            if animated && shouldScroll {
                cell.isCurrent = true
            }
            cell.hideCurrentBarView()
            currentBarViewWidthConstraint.constant = cell.frame.width
            if !isInfinity {
                currentBarViewLeftConstraint?.constant = cell.frame.origin.x
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.layoutIfNeeded()
                }, completion: { _ in
                    if !animated && shouldScroll {
                        cell.isCurrent = true
                    }

                    self.updateCollectionViewUserInteractionEnabled(true)
            })
        }
        beforeIndex = currentIndex
    }
//    fileprivate func moveCurrentBarView(_ indexPath: IndexPath, animated: Bool, shouldScroll: Bool) {
//
//        if shouldScroll {
//
//            if SharedManager.shared.isAppLaunchFirstTIME {
//
//                SharedManager.shared.isAppLaunchFirstTIME = false
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//
//                    self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
//                    self.layoutIfNeeded()
//                }
//            }
//
//            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
//            layoutIfNeeded()
//            collectionViewContentOffsetX = 0.0
//            currentBarViewWidth = 0.0
//        }
//
//        if let cell = collectionView.cellForItem(at: indexPath) as? TabCollectionCell {
////            currentBarView.isHidden = false
//            if animated && shouldScroll {
//                cell.isCurrent = true
//            }
////            cell.hideCurrentBarView()
////            currentBarViewWidthConstraint.constant = cell.frame.width
//            if !isInfinity {
//                currentBarViewLeftConstraint?.constant = cell.frame.origin.x
//            }
//
//            UIView.animate(withDuration: 0.2, animations: {
//                self.layoutIfNeeded()
//            }, completion: { _ in
//                if !animated && shouldScroll {
//                    cell.isCurrent = true
//                }
//
//                self.updateCollectionViewUserInteractionEnabled(true)
//            })
//        }
//
//        beforeIndex = currentIndex
//    }

    /**
     Touch event control of collectionView

     - parameter userInteractionEnabled: collectionViewに渡すuserInteractionEnabled
     */
    func updateCollectionViewUserInteractionEnabled(_ userInteractionEnabled: Bool) {
        collectionView.isUserInteractionEnabled = userInteractionEnabled
    }

    /**
     Update all of the cells in the display to the unselected state
     */
    fileprivate func deselectVisibleCells() {
        collectionView
            .visibleCells
            .compactMap { $0 as? TabCollectionCell }
            .forEach { $0.isCurrent = false }
    }
}


// MARK: - UICollectionViewDataSource

extension TabView: UICollectionViewDataSource {

    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isInfinity ? pageTabItemsCount * 3 : pageTabItemsCount
    }

    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabCollectionCell.cellIdentifier(), for: indexPath) as! TabCollectionCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }

    fileprivate func configureCell(_ cell: TabCollectionCell, indexPath: IndexPath) {
        let fixedIndex = isInfinity ? indexPath.item % pageTabItemsCount : indexPath.item
        cell.item = pageTabItems[fixedIndex]
        cell.option = option
        cell.istheme = isGradientRequired
        cell.isCurrent = fixedIndex == (currentIndex % pageTabItemsCount)
        cell.tabItemButtonPressedBlock = { [weak self, weak cell] in
            var direction: UIPageViewController.NavigationDirection = .forward
            if let pageTabItemsCount = self?.pageTabItemsCount, let currentIndex = self?.currentIndex {
                if self?.isInfinity == true {
                    if (indexPath.item < pageTabItemsCount) || (indexPath.item < currentIndex) {
                        direction = .reverse
                    }
                } else {
                    if indexPath.item < currentIndex {
                        direction = .reverse
                    }
                }
            }
            self?.pageItemPressedBlock?(fixedIndex, direction)

            if cell?.isCurrent == false {
                // Not accept touch events to scroll the animation is finished
                self?.updateCollectionViewUserInteractionEnabled(false)
            }
            self?.updateCurrentIndexForTap(indexPath.item)
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // FIXME: Tabs are not displayed when processing is performed during introduction display
        if let cell = cell as? TabCollectionCell, layouted {
            let fixedIndex = isInfinity ? indexPath.item % pageTabItemsCount : indexPath.item
            cell.isCurrent = fixedIndex == (currentIndex % pageTabItemsCount)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        if isGradientRequired {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 18)
        }
        return UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 41)
    }

}


// MARK: - UIScrollViewDelegate

//extension TabView: UICollectionViewDelegate {
//
//    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.isDragging {
////            currentBarView.isHidden = true
//            let indexPath = IndexPath(item: currentIndex, section: 0)
//            if let cell = collectionView.cellForItem(at: indexPath) as? TabCollectionCell {
//                cell.showCurrentBarView()
//            }
//        }
//
//        guard isInfinity else {
//            return
//        }
//
//        if pageTabItemsWidth == 0.0 {
//            pageTabItemsWidth = floor(scrollView.contentSize.width / 3.0)
//        }
//
//        if (scrollView.contentOffset.x <= 0.0) || (scrollView.contentOffset.x > pageTabItemsWidth * 2.0) {
//            scrollView.contentOffset.x = pageTabItemsWidth
//        }
//    }
//
//    internal func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        // Accept the touch event because animation is complete
//        updateCollectionViewUserInteractionEnabled(true)
//
//        guard isInfinity else {
//            return
//        }
//
//        let indexPath = IndexPath(item: currentIndex, section: 0)
//        if shouldScrollToItem {
//            // After the moved so as not to sense of incongruity, to adjust the contentOffset at the currentIndex
//            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
//            shouldScrollToItem = false
//        }
//    }
//}

extension TabView: UICollectionViewDelegate {

    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            currentBarView.isHidden = true
            let indexPath = IndexPath(item: currentIndex, section: 0)
            if let cell = collectionView.cellForItem(at: indexPath) as? TabCollectionCell {
                cell.showCurrentBarView()
            }
        }

        guard isInfinity else {
            return
        }

        if pageTabItemsWidth == 0.0 {
            pageTabItemsWidth = floor(scrollView.contentSize.width / 3.0)
        }

        if (scrollView.contentOffset.x <= 0.0) || (scrollView.contentOffset.x > pageTabItemsWidth * 2.0) {
            scrollView.contentOffset.x = pageTabItemsWidth
        }

    }

    internal func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // Accept the touch event because animation is complete
        updateCollectionViewUserInteractionEnabled(true)

        guard isInfinity else {
            return
        }

        let indexPath = IndexPath(item: currentIndex, section: 0)
        if shouldScrollToItem {
            // After the moved so as not to sense of incongruity, to adjust the contentOffset at the currentIndex
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            shouldScrollToItem = false
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TabView: UICollectionViewDelegateFlowLayout {

    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if let size = cachedCellSizes[indexPath] {
            return size
        }

        configureCell(cellForSize, indexPath: indexPath)

        let size = cellForSize.sizeThatFits(CGSize(width: collectionView.bounds.width, height: option.tabHeight))
        cachedCellSizes[indexPath] = size

        return size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

