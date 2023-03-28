//
//  PageTabMenuViewController.swift
//  Bullet
//
//  Created by Tamanyan on 3/7/17.
//  Copyright © 2017 Tamanyan. All rights reserved.
//

import UIKit


open class PageTabMenuViewController: UIPageViewController {
    
    @IBOutlet weak var viewBG: UIView!
    
    var topics = [TopicData]()
    open var isInfinity: Bool = false
    open var option: TabPageOption = TabPageOption()
    open var tabItems: [(viewController: UIViewController, title: String)] = []
    
    var currentIndex: Int? {
        guard let viewController = viewControllers?.first else {
            return nil
        }
        return tabItems.map{ $0.viewController }.firstIndex(of: viewController)
    }
    
    fileprivate var beforeIndex: Int = 0
    fileprivate var tabItemsCount: Int {
        return tabItems.count
    }
    fileprivate var defaultContentOffsetX: CGFloat {
        return self.view.bounds.width
    }
    fileprivate var shouldScrollCurrentBar: Bool = true
    lazy fileprivate var tabView: TabView = self.configuredTabView()
    fileprivate var statusView: UIView?
    fileprivate var statusViewHeightConstraint: NSLayoutConstraint?
    fileprivate var tabBarTopConstraint: NSLayoutConstraint?
    var isFirstLoadView = true
    var delegateTabView: TabViewDelegate?
    var topTabBarConstraint: NSLayoutConstraint?
    let normalTopTabBarConstraint: CGFloat = 0
    let hiddenTopTabBarConstraint: CGFloat = -100
    
    var showArticleType: ArticleType = .home

    var isGradientRequired = false
    
    init(type: ArticleType, isGradientRequired: Bool) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.showArticleType = type
        self.isGradientRequired = isGradientRequired
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    
    let pageViewNormalY: CGFloat = 0
    let pageViewScrollY: CGFloat = -70
    var viewNormalHeight: CGFloat = 0
    weak var delegateBulletDetails: BulletDetailsVCLikeDelegate?
    
    deinit {
        removeNSNotifications()
        print("deinit...")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        
        viewNormalHeight = view.frame.size.height
        //HOME---TOPIC---SOURCE---HEADLINE----LOCAL---FORYOU
        if showArticleType == .topic || showArticleType == .savedArticle || showArticleType == .source || showArticleType == .places {
            SharedManager.shared.curCategoryIndex = 0
        }
                
        if showArticleType == .savedArticle {
            
            tabItems.append((HomeVC.instantiate(fromAppStoryboard: .Main), ""))
        }
        else if showArticleType == .places {
            
            tabItems.append((HomeVC.instantiate(fromAppStoryboard: .Main), ""))
        }
        else {
            
           // if SharedManager.shared.isShowSource || SharedManager.shared.isViewArticleSourceNotification {
            if showArticleType == .source {
                
                for (_, source) in SharedManager.shared.subSourcesList.enumerated() {
                    
                    let title = source.name ?? ""
                    tabItems.append((HomeVC.instantiate(fromAppStoryboard: .Main), title))
                }
            }
            else if showArticleType == .topic {
                
                tabItems.append((HomeVC.instantiate(fromAppStoryboard: .Main), ""))
//                if SharedManager.shared.subTopicsList.count == 0 {
//                    tabItems.append((HomeVC.instantiate(fromAppStoryboard: .Main), ""))
//                }
//                else {
//                    for (_, topic) in SharedManager.shared.subTopicsList.enumerated() {
//
//                        let title = topic.name ?? ""
//                        tabItems.append((HomeVC.instantiate(fromAppStoryboard: .Main), title))
//                    }
//                }
            }
            else {
                
                for (_, headline) in SharedManager.shared.reelsCategories.enumerated() {
                    
                    let title = headline.title ?? ""
                    tabItems.append((HomeVC.instantiate(fromAppStoryboard: .Main), title))
                }
            }
        }
        
        isInfinity = false
        option.tabHeight = 60
        option.tabMargin = 8
        
        isFirstLoadView = true
        SharedManager.shared.isUserTapOnTabbar = false
        
        if showArticleType == .home {
            
            if SharedManager.shared.isAppLaunchFirstTIME {
                
                //SharedManager.shared.isAppLaunchFirstTIME = false
                    
                if let index = SharedManager.shared.reelsCategories.firstIndex(where: {$0.id == SharedManager.shared.curReelsCategoryId}) {
                    
                    self.beforeIndex = index
                }
            }
            else {
                
                if SharedManager.shared.isTabReload == false {

                    if let index = SharedManager.shared.reelsCategories.firstIndex(where: { $0.id == SharedManager.shared.curReelsCategoryId }) {

                        self.beforeIndex = index
                        tabView.updateCurrentIndex(index, shouldScroll: true)
                    }
                }
                else {
                    
                    SharedManager.shared.curReelsCategoryId = SharedManager.shared.reelsCategories.first?.id ?? ""
                    self.beforeIndex = 0
                }
            }
        }
        else {
            
            self.beforeIndex = 0
        }
        
        setupPageViewController()
        setupScrollView()
        
    }
    
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        addNSNotifications()

        if isFirstLoadView {
            
            if self.showArticleType == .savedArticle || self.showArticleType == .places || self.showArticleType == .topic {
                
                homeScrollViewDidScroll(delta: 0)
            }
            else {
                
                homeScrollViewDidScroll(delta: -1)
            }
            
            SharedManager.shared.isTopTabBarCurrentlHidden = false
            
            isFirstLoadView = false
        }
        else {
            SharedManager.shared.isUserTapOnTabbar = true
            
            (self.viewControllers?.first as? HomeVC)?.pageViewControllerViewWillAppear()
        }
        
        if tabView.superview == nil {
            tabView = configuredTabView()
        }
        
        if let currentIndex = currentIndex , isInfinity {
            tabView.updateCurrentIndex(currentIndex, shouldScroll: true)
        }
        
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        
        SharedManager.shared.isTopTabBarCurrentlHidden = false
        
        removeNSNotifications()
        (self.viewControllers?.first as? HomeVC)?.pageViewControllerViewWillDisappear()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabView.layouted = true
    }

    
    func addNSNotifications() {
        NotificationCenter.default.removeObserver(self)
//        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyToRemoveVCObservers, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapRemoveObserver(_:)), name: Notification.Name.notifyToRemoveVCObservers, object: nil)
        
//        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyPauseAudio, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapOpenEdition(_:)), name: Notification.Name.notifyPauseAudio, object: nil)
                        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyAppFromBackground, object: nil)
//        NotificationCenter.default.removeObserver(SharedManager.shared.observerArray)
        NotificationCenter.default.addObserver(forName: Notification.Name.notifyAppFromBackground, object: nil, queue: nil) { [weak self] notification in
            
            (self?.viewControllers?.first as? HomeVC)?.notifyAppBackgroundEvent()
        }
        
        
//        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self] notification in
//
//            if self?.showArticleType != .topic && self?.showArticleType != .places {
//
//                let killTime = SharedManager.shared.refreshFeedOnKillApp ?? Date()
//                let interval = Date().timeIntervalSince(killTime)
//                let minutes = (interval / 60).truncatingRemainder(dividingBy: 60)
//                if minutes >= 5 {
//                    SharedManager.shared.showLoaderInWindow()
//                }
//            }
//        }

        
//        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyCallDuringAppUse, object: nil)
//        let _ = NotificationCenter.default.addObserver(forName: Notification.Name.notifyCallDuringAppUse, object: nil, queue: nil) { notification in
//
//            (self.viewControllers?[self.currentIndex ?? 0] as? HomeVC)?.notifyCallRecievedInApp()
//        }

        
//        SharedManager.shared.bulletPlayer?.stop()
//        SharedManager.shared.bulletPlayer?.currentTime = 0
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyHomeVolumn, object: nil)
        NotificationCenter.default.addObserver(forName: Notification.Name.notifyHomeVolumn, object: nil, queue: nil) { [weak self] notification in
            
            (self?.viewControllers?.first as? HomeVC)?.didTapVolume()
        }
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyVideoVolumeStatus, object: nil)
        NotificationCenter.default.addObserver(forName: Notification.Name.notifyVideoVolumeStatus, object: nil, queue: nil) { [weak self] notification in
            
            (self?.viewControllers?.first as? HomeVC)?.didTapUpdateVideoVolumeStatus(notification: notification)
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: Notification.Name.notifyOrientationChange, object: nil)
        
        NotificationCenter.default.addObserver(forName: .EZPlayerStatusDidChange, object: nil, queue: nil) { [weak self] notification in
            (self?.viewControllers?.first as? HomeVC)?.videoPlayerStatus(notification)

        }
    }
    
    func removeNSNotifications() {
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyAppFromBackground, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyVideoVolumeStatus, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.notifyHomeVolumn, object: nil)
    }
    
    
    @objc func orientationChanged() {
        
        (self.viewControllers?.first as? HomeVC)?.orientationChange()
        
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            // Your code here
            
//            (UIApplication.shared.delegate as! AppDelegate).setOrientationPortraitInly()
//            (UIApplication.shared.delegate as! AppDelegate).setpo
            
//            (self.viewControllers?.first as? HomeVC)?.
        }
    }
    
}



// MARK: - Public Interface
public extension PageTabMenuViewController {
    
    func displayControllerWithIndex(_ index: Int, direction: UIPageViewController.NavigationDirection, animated: Bool) {
        
        beforeIndex = index
        shouldScrollCurrentBar = false

        if tabItems.count > index {
            
            tabView.updateCollectionViewUserInteractionEnabled(false)
            let nextViewControllers: [UIViewController] = [tabItems[index].viewController]
            
            let completion: ((Bool) -> Void) = { [weak self] _ in
                self?.shouldScrollCurrentBar = true
                self?.beforeIndex = index
                self?.tabView.updateCollectionViewUserInteractionEnabled(true)
            }
            
            (tabItems[index].viewController as? HomeVC)?.scrollDelegate = self
            (tabItems[index].viewController as? HomeVC)?.pageIndex = index
            (tabItems[index].viewController as? HomeVC)?.showArticleType = self.showArticleType
            (tabItems[index].viewController as? HomeVC)?.delegateBulletDetails = delegateBulletDetails
            
            if self.showArticleType != .topic && self.showArticleType != .source && self.showArticleType != .places {
                SharedManager.shared.curReelsCategoryId = SharedManager.shared.reelsCategories[index].id ?? ""
            }
            
            SharedManager.shared.curCategoryIndex = index
            
            NotificationCenter.default.post(name: Notification.Name.notifyToRemoveVCObservers, object: nil)
            
            self.setViewControllers(
                nextViewControllers,
                direction: direction,
                animated: animated,
                completion: completion)
            
            guard isViewLoaded else { return }
            tabView.updateCurrentIndex(index, shouldScroll: true)
        }
    }
}


// MARK: - View

extension PageTabMenuViewController {
    
    fileprivate func setupPageViewController() {
        
        if tabItems.count != 0 && beforeIndex < tabItems.count {
            
            dataSource = self
            delegate = self
            
            let vc = tabItems[beforeIndex].viewController
            (vc as? HomeVC)?.scrollDelegate = self
            (vc as? HomeVC)?.delegateBulletDetails = delegateBulletDetails
            (vc as? HomeVC)?.pageIndex = beforeIndex
            (vc as? HomeVC)?.showArticleType = self.showArticleType

            SharedManager.shared.curCategoryIndex = beforeIndex
            setViewControllers([vc],
                               direction: .forward,
                               animated: false,
                               completion: nil)
        }
        else {
            print("tabItems setupPageViewController zero")
        }
    }
    
    fileprivate func setupScrollView() {
        
        // Disable PageViewController's ScrollView bounce
        let scrollView = view.subviews.compactMap { $0 as? UIScrollView }.first
        scrollView?.scrollsToTop = false
        scrollView?.delegate = self
        scrollView?.isScrollEnabled = false
        scrollView?.contentInsetAdjustmentBehavior = .never
        scrollView?.backgroundColor = option.pageBackgoundColor
    }
    
    fileprivate func configuredTabView() -> TabView {
        let tabView = TabView(isInfinity: isInfinity, option: option)
        tabView.translatesAutoresizingMaskIntoConstraints = false
        
        if showArticleType == .savedArticle || showArticleType == .places || showArticleType == .topic {
            tabView.isGradientRequired = true
            tabView.contentView.backgroundColor = .clear
            //tabView.contentView.theme_backgroundColor = GlobalPicker.customTabbarBGColor
            tabView.viewMenu.isHidden = true
        }
        else {
            tabView.isGradientRequired = false
            tabView.contentView.backgroundColor = .white
            tabView.viewMenu.isHidden = false
        }
        
        
        let height = NSLayoutConstraint(item: tabView,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .height,
                                        multiplier: 1.0,
                                        constant: option.tabHeight)
        tabView.addConstraint(height)
        view.addSubview(tabView)
        
        topTabBarConstraint = NSLayoutConstraint(item: tabView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: topLayoutGuide,
                                     attribute: .bottom,
                                     multiplier:1.0,
                                     constant: 0.0)
        
        let left = NSLayoutConstraint(item: tabView,
                                      attribute: .left,
                                      relatedBy: .equal,
                                      toItem: view,
                                      attribute: .left,
                                      multiplier: 1.0,
                                      constant: 0)
        
        let right = NSLayoutConstraint(item: view as Any,
                                       attribute: .right,
                                       relatedBy: .equal,
                                       toItem: tabView,
                                       attribute: .right,
                                       multiplier: 1.0,
                                       constant: 0)
        
        view.addConstraints([topTabBarConstraint!, left, right])
        
        tabView.pageTabItems = tabItems.map({ $0.title})
        tabView.updateCurrentIndex(beforeIndex, shouldScroll: true)
        
        tabView.pageItemPressedBlock = { [weak self] (index: Int, direction: UIPageViewController.NavigationDirection) in
            self?.displayControllerWithIndex(index, direction: direction, animated: true)
        }
        
        
        tabView.delegate = delegateTabView
        return tabView
    }
    
//    private func setupStatusView() {
//
//        let statusView = UIView()
//        statusView.backgroundColor = option.tabBackgroundColor
//        statusView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(statusView)
//
//        let top = NSLayoutConstraint(item: statusView,
//                                     attribute: .top,
//                                     relatedBy: .equal,
//                                     toItem: view,
//                                     attribute: .top,
//                                     multiplier: 1.0,
//                                     constant: 0.0)
//
//        let left = NSLayoutConstraint(item: statusView,
//                                      attribute: .leading,
//                                      relatedBy: .equal,
//                                      toItem: view,
//                                      attribute: .leading,
//                                      multiplier: 1.0,
//                                      constant: 0.0)
//
//        let right = NSLayoutConstraint(item: view as Any,
//                                       attribute: .trailing,
//                                       relatedBy: .equal,
//                                       toItem: statusView,
//                                       attribute: .trailing,
//                                       multiplier: 1.0,
//                                       constant: 0.0)
//
//        let height = NSLayoutConstraint(item: statusView,
//                                        attribute: .height,
//                                        relatedBy: .equal,
//                                        toItem: nil,
//                                        attribute: .height,
//                                        multiplier: 1.0,
//                                        constant: topLayoutGuide.length)
//
//        view.addConstraints([top, left, right, height])
//
//        statusViewHeightConstraint = height
//        self.statusView = statusView
//    }
}


// MARK: - UIPageViewControllerDataSource

extension PageTabMenuViewController: UIPageViewControllerDataSource {
    
    fileprivate func nextViewController(_ viewController: UIViewController, isAfter: Bool) -> UIViewController? {
        
        guard var index = tabItems.map({$0.viewController}).firstIndex(of: viewController) else {
            return nil
        }
        
        if isAfter {
            index += 1
        } else {
            index -= 1
        }
        
        if isInfinity {
            if index < 0 {
                index = tabItems.count - 1
            } else if index == tabItems.count {
                index = 0
            }
        }
        
        if index >= 0 && index < tabItems.count {

            (tabItems[index].viewController as? HomeVC)?.pageIndex = index
            (tabItems[index].viewController as? HomeVC)?.showArticleType = self.showArticleType
            (tabItems[index].viewController as? HomeVC)?.scrollDelegate = self
            (tabItems[index].viewController as? HomeVC)?.delegateBulletDetails = delegateBulletDetails
            
            return tabItems[index].viewController
        }
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController, isAfter: true)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController, isAfter: false)
    }
}


// MARK: - UIPageViewControllerDelegate

extension PageTabMenuViewController: UIPageViewControllerDelegate {
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
//        pageViewController.view?.isUserInteractionEnabled = false
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
//            pageViewController.view?.isUserInteractionEnabled = true
//        }

        
        shouldScrollCurrentBar = true
        tabView.scrollToHorizontalCenter()
        
        // Order to prevent the the hit repeatedly during animation
        tabView.updateCollectionViewUserInteractionEnabled(false)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
                
        if let currentIndex = currentIndex , currentIndex < tabItemsCount {
            
            if completed {
                
                NotificationCenter.default.post(name: Notification.Name.notifyToRemoveVCObservers, object: nil)
                
                if showArticleType != .topic && showArticleType != .source {
                    SharedManager.shared.curReelsCategoryId = SharedManager.shared.reelsCategories[currentIndex].id ?? ""
                }
                SharedManager.shared.curCategoryIndex = currentIndex
            }
            
            tabView.updateCurrentIndex(currentIndex, shouldScroll: false)
            beforeIndex = currentIndex
        }
        
        tabView.updateCollectionViewUserInteractionEnabled(true)
    }
}


// MARK: - UIScrollViewDelegate

extension PageTabMenuViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.x == defaultContentOffsetX || !shouldScrollCurrentBar {
            return
        }
        
        // (0..<tabItemsCount)
        var index: Int
        if scrollView.contentOffset.x > defaultContentOffsetX {
            index = beforeIndex + 1
        } else {
            index = beforeIndex - 1
        }
        
        if index == tabItemsCount {
            index = 0
        } else if index < 0 {
            index = tabItemsCount - 1
        }
        
        let scrollOffsetX = scrollView.contentOffset.x - view.frame.width
        tabView.scrollCurrentBarView(index, contentOffsetX: scrollOffsetX)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        tabView.updateCurrentIndex(beforeIndex, shouldScroll: true)
    }
}


extension PageTabMenuViewController: HomeVCScrollDelegate {
    
    func homeScrollViewDidScroll(delta: CGFloat) {

        DispatchQueue.main.async {
            if delta < 0 {
                // the value is negative, so we're scrolling up and the view is moving back into view.
                // take whatever is smaller, the constant minus delta or 0
                SharedManager.shared.isTopTabBarCurrentlHidden = false
                if self.topTabBarConstraint?.constant != self.normalTopTabBarConstraint {
                    UIView.animate(withDuration: 0.25) {
                        if self.showArticleType == .savedArticle || self.showArticleType == .places || self.showArticleType == .topic {
                            self.topTabBarConstraint?.constant = self.hiddenTopTabBarConstraint
                        }
                        else {
                            self.topTabBarConstraint?.constant = self.normalTopTabBarConstraint
                        }
                        self.view.layoutIfNeeded()
    //                    self.view.frame.origin.y = self.pageViewNormalY
    //                    self.view.frame.size.height = self.viewNormalHeight
        //                    if self.view.frame.origin.y + delta <= self.pageViewNormalY {
        //                        self.view.frame.origin.y = self.view.frame.origin.y + delta
        //                        print("scroll test 1")
        //                    } else {
        //                        self.view.frame.origin.y = self.pageViewNormalY
        //                    }
                    }
                }
                //min(pageViewNormalY - delta, 0)
            } else {
                // the value is positive, so we're scrolling down and the view is moving out of sight.
                // take whatever is "larger," the constant minus delta, or the minimumConstantValue.
                SharedManager.shared.isTopTabBarCurrentlHidden = true
                if self.topTabBarConstraint?.constant != self.hiddenTopTabBarConstraint {
                    UIView.animate(withDuration: 0.25) {
                        self.topTabBarConstraint?.constant = self.hiddenTopTabBarConstraint
                        self.view.layoutIfNeeded()
    //                    self.view.frame.origin.y = self.pageViewScrollY
    //                    self.view.frame.size.height = self.viewNormalHeight - self.pageViewScrollY
        //                    if self.view.frame.origin.y - delta >= self.pageViewScrollY {
        //                        self.view.frame.origin.y = self.view.frame.origin.y - delta
        //                    } else {
        //                        self.view.frame.origin.y = self.pageViewScrollY
        //                    }
                    }
                }
                
                
    //                UIView.animate(withDuration: 0.25) {
    //                    if self.view.frame.origin.y - delta <= self.pageViewScrollY {
    //                        self.view.frame.origin.y = self.view.frame.origin.y - delta
    //                    } else {
    //                        self.view.frame.origin.y = self.pageViewScrollY
    //                    }
    //                    self.view.layoutIfNeeded()
    //                }
            }
        }
        
    }
}
