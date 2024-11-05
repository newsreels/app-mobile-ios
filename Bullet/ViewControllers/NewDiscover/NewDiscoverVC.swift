//
//  NewDiscoverVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 26/08/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import DataCache
//import SkeletonView

class NewDiscoverVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let pagingLoader = UIActivityIndicatorView()
    var isPagingLoaderAdded = false
    var discoverListArr = [DiscoverData]()
    var nextPageData = ""
    
    var isFirstTimeLoaded = false
    var isAPIPaginationRunning = false
    var lastModified = ""
    var currentlyFocusedIndexPath = IndexPath(item: 0, section: 0)
    
    var showingLoader = false

    
    var isVCVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        ANLoader.hide()
        
        
        registerCells()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        
        loadData()
        
    }
    
    
    func loadData() {
        
        if SharedManager.shared.isDiscoverTabReload {
            self.nextPageData = ""
            self.lastModified = ""
            self.discoverListArr.removeAll()
            self.collectionView.reloadData()
            self.performWSToDiscoverList(page: "")
        }
        else if let arrCache = self.readCache(), arrCache.count > 0 {
            self.getDiscoverPageData()
        }
        else {
            self.showLoader()
            self.performWSToDiscoverList(page: "")
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        
//        DispatchQueue.main.async {
//            if SharedManager.shared.isSelectedLanguageRTL() {
//                self.lblTitle.semanticContentAttribute = .forceRightToLeft
//                self.lblTitle.textAlignment = .right
//                self.lblEmail.semanticContentAttribute = .forceRightToLeft
//                self.lblEmail.textAlignment = .right
//            } else {
//                self.lblTitle.semanticContentAttribute = .forceLeftToRight
//                self.lblTitle.textAlignment = .left
//                self.lblEmail.semanticContentAttribute = .forceLeftToRight
//                self.lblEmail.textAlignment = .left
//                self.lblViewProfile.semanticContentAttribute = .forceLeftToRight
//                self.lblViewProfile.textAlignment = .left
//            }
//
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        isVCVisible = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        isVCVisible = false
        pauseAllCurrentlyFocusedMedia()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        
        
        collectionView.layoutIfNeeded()
        
        if isFirstTimeLoaded {
            loadData()
            
            if discoverListArr.count > 0 {
//                playCurrentlyFocusedMedia()
                scrollToTopVisibleCell()
            }
        }
        isFirstTimeLoaded = true
        
        playCurrentlyFocusedMedia()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        pauseAllCurrentlyFocusedMedia()
    }
    
    // MARK: - Methods
    func registerCells() {
        
        collectionView.register(UINib(nibName: "carouselDiscoverCell", bundle: nil), forCellWithReuseIdentifier: "carouselDiscoverCell")
        collectionView.register(UINib(nibName: "TopicsDiscoverCC", bundle: nil), forCellWithReuseIdentifier: "TopicsDiscoverCC")
        collectionView.register(UINib(nibName: "SingleArticleCC", bundle: nil), forCellWithReuseIdentifier: "SingleArticleCC")
        collectionView.register(UINib(nibName: "TopNewsDiscoverCC", bundle: nil), forCellWithReuseIdentifier: "TopNewsDiscoverCC")
        collectionView.register(UINib(nibName: "ChannelsDiscoverCC", bundle: nil), forCellWithReuseIdentifier: "ChannelsDiscoverCC")
        collectionView.register(UINib(nibName: "AuthorsDiscoverCC", bundle: nil), forCellWithReuseIdentifier: "AuthorsDiscoverCC")
        collectionView.register(UINib(nibName: "TopVideosDiscoverCC", bundle: nil), forCellWithReuseIdentifier: "TopVideosDiscoverCC")
        collectionView.register(UINib(nibName: "ReelsSuggestedDiscoverCC", bundle: nil), forCellWithReuseIdentifier: "ReelsSuggestedDiscoverCC")
        collectionView.register(UINib(nibName: "locationDiscoverCC", bundle: nil), forCellWithReuseIdentifier: "locationDiscoverCC")
        collectionView.register(UINib(nibName: "ReelCarouselCell", bundle: nil), forCellWithReuseIdentifier: "ReelCarouselCell")
        collectionView.register(UINib(nibName: "EmptyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EmptyCollectionViewCell")
        
        collectionView.register(UINib(nibName: "EmptyCollectionViewCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier:"EmptyCollectionViewCell")
        
        collectionView.register(UINib(nibName: "EmptyCell", bundle: nil), forCellWithReuseIdentifier: "EmptyCell")

        
    }
    
    func showLoader() {
        
        
        DispatchQueue.main.async {

//
//            let animation = GradientDirection.leftRight.slidingAnimation()
//                //        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftToRight)
//            self.collectionView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient.init(baseColor: MyThemes.current == .light ? GlobalPicker.skeletonColorLightMode : GlobalPicker.skeletonColorDarkMode), animation: animation, transition: .crossDissolve(0.25))
//            self.tblExtendedView.showSkeleton()
            
//            ANLoader.showLoading()
        }
        
        
    }
    
    func addPagingLoader() {
        
        isPagingLoaderAdded = true
        if pagingLoader.isAnimating {
            
            self.pagingLoader.stopAnimating()
            self.pagingLoader.hidesWhenStopped = true
        }
        
        if self.collectionView.footer != pagingLoader {
            if #available(iOS 13.0, *) {
                pagingLoader.style = .medium
            }
            pagingLoader.theme_color = GlobalPicker.activityViewColor
            
            pagingLoader.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: collectionView.bounds.width, height: CGFloat(62))
            
            self.collectionView.footer = ESRefreshFooterView()
            self.collectionView.footer?.isHidden = false
        }
        
        
    }
    
    private func getDiscoverPageData() {
        
        if let arrCache = self.readCache(), arrCache.count > 0 {
            
            self.discoverListArr = arrCache
                 
            //Reload data
            UIView.performWithoutAnimation {
                self.collectionView.reloadData()
                
                playCurrentlyFocusedMedia()
                
            }
            
            DispatchQueue.background(background: {
                // do something in background
                self.performWSToDiscoverListBackgroundTask(arrCache)
            }, completion: {
                // when background job finished, do something in main thread
                self.pagingLoader.stopAnimating()
                self.pagingLoader.hidesWhenStopped = true
            })
        }
        else {
            self.performWSToDiscoverList(page: "")
        }

    }
    
    
    private func writeCache(arrCacheDiscover: DiscoverModel) {
        
        //write articles data in cache
        do {
            try DataCache.instance.write(codable: arrCacheDiscover, forKey: Constant.CACHE_DISCOVER_PAGE)
        } catch {
            print("Write error \(error.localizedDescription)")
        }
    }
    
    private func readCache() -> [DiscoverData]? {
        
        //read articles data from cache
        do {
            let object: DiscoverModel? = try DataCache.instance.readCodable(forKey: Constant.CACHE_DISCOVER_PAGE)
            let array = object?.discover
            
            if let next = object?.meta?.next, next.isEmpty == false {
                self.nextPageData = next
            } else {
                self.nextPageData = ""
            }
            
            lastModified = object?.lastModified ?? ""
            return array
        } catch {
            print("Read error \(error.localizedDescription)")
            return nil
        }
    }
    

    func openSelectedItem(indexPath: IndexPath, secondaryIndexPath: IndexPath?) {
        
        if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.REELS.rawValue {
            
            guard let secondaryIndex = secondaryIndexPath  else { return }
            
            let reel = self.discoverListArr[indexPath.item].data?.reels?[secondaryIndex.item]
            openReels(title: "", context: reel?.context, isOpenForTags: false)
            
        }
        if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.TOPICS.rawValue {
            
            guard let secondaryIndex = secondaryIndexPath  else { return }
            
            let topic = self.discoverListArr[indexPath.item].data?.topics?[secondaryIndex.item]
            performWSToOpenTopics(id: topic?.id ?? "", title: topic?.name ?? "", favorite: topic?.favorite ?? false)
            
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.ARTICLE.rawValue {
            
            let article = self.discoverListArr[indexPath.row].data?.article
            openBulletDetails(indexPath: indexPath, article: article)
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.ARTICLES.rawValue {
            
            guard let secondaryIndex = secondaryIndexPath  else { return }
            
            let article = self.discoverListArr[indexPath.item].data?.articles?[secondaryIndex.item]
            openBulletDetails(indexPath: indexPath, article: article)
            
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.discoverDailyroundupClick, article_id: article?.id ?? "")

            
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.ARTICLE_VIDEOS.rawValue {
            
            guard let secondaryIndex = secondaryIndexPath  else { return }
            
            let article = self.discoverListArr[indexPath.item].data?.articles?[secondaryIndex.item]
            openBulletDetails(indexPath: indexPath, article: article)
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.CHANNELS.rawValue {
            
            guard let secondaryIndex = secondaryIndexPath  else { return }
            
            let channel = self.discoverListArr[indexPath.item].data?.sources?[secondaryIndex.item]
            //openChannels(channel: channel)
            performGoToSource(channel?.id ?? "")
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.AUTHORS.rawValue {
            
            guard let secondaryIndex = secondaryIndexPath  else { return }
            
            let author = self.discoverListArr[indexPath.item].data?.authors?[secondaryIndex.item]
            openAuthors(author: author)
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.PLACES.rawValue {
            
            guard let secondaryIndex = secondaryIndexPath  else { return }
            
            let location = self.discoverListArr[indexPath.item].data?.locations?[secondaryIndex.item]
            openLocationNews(loc: location)
        }
        
    }
    
    func openBulletDetails(indexPath: IndexPath, article: articlesData?) {
        
        pauseAllCurrentlyFocusedMedia()
        
        let vc = BulletDetailsVC.instantiate(fromAppStoryboard: .Home)
        vc.selectedArticleData = article
        
        vc.delegate = self
        vc.delegateVC = self
        let navVC = UINavigationController(rootViewController: vc)
        navVC.navigationBar.isHidden = true
        navVC.modalPresentationStyle = .overFullScreen
        navVC.modalTransitionStyle = .crossDissolve
        
        SharedManager.shared.isOnDiscover = false
        self.present(navVC, animated: true, completion: nil)
        
    }
    
    func openReels(title: String, context: String?, isOpenForTags: Bool) {
        
        pauseAllCurrentlyFocusedMedia()
        
        let vc = ReelsVC.instantiate(fromAppStoryboard: .Reels)
//        vc.contextID = context ?? ""
        vc.titleText = title
        vc.isBackButtonNeeded = true
        vc.isOpenFromTags = isOpenForTags
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        self.present(nav, animated: true, completion: nil)
        
    }
    
    func openChannels(channel: ChannelInfo?) {
        
        pauseAllCurrentlyFocusedMedia()
        
        let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
        detailsVC.channelInfo = channel
        //detailsVC.delegateVC = self
        //detailsVC.isOpenFromDiscoverCustomListVC = true
        detailsVC.modalPresentationStyle = .fullScreen
        let nav = AppNavigationController(rootViewController: detailsVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
        
    }
    
    func openAuthors(author: Author?) {
        
        guard let author = author else { return }
        if (author.id ?? "") == SharedManager.shared.userId {
            
            pauseAllCurrentlyFocusedMedia()
            
            let vc = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
            let navVC = AppNavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            //vc.delegate = self
            self.present(navVC, animated: true, completion: nil)
        }
        else {
            
            pauseAllCurrentlyFocusedMedia()
            
            let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
            let authorObj = Authors(id: author.id, context: author.context, name: author.first_name, username: author.username, image: author.profile_image, favorite: author.favorite)
            vc.authors = [authorObj]
            let navVC = AppNavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            //vc.delegate = self
            self.present(navVC, animated: true, completion: nil)
        }
        
    }
    
    func openLocationNews(loc: Location?) {
        
        guard let location = loc else {
            return
        }
        
        pauseAllCurrentlyFocusedMedia()
        
        
        SharedManager.shared.subLocationList = [location]
        let vc = HomeVC.instantiate(fromAppStoryboard: .Main)
        vc.showArticleType = .places
        vc.selectedID = location.id ?? ""
        vc.isFav = location.favorite ?? false
        vc.placeContextId = location.context ?? ""
        vc.subTopicTitle = location.city ?? ""
        
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
        
    }
    
    // MARK: - Button Actions
    func didTapSearch() {
        
        pauseAllCurrentlyFocusedMedia()
        
        let vc = SearchAllVC.instantiate(fromAppStoryboard: .Main)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    
}


extension NewDiscoverVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//extension NewDiscoverVC: UICollectionViewDataSource, UICollectionViewDelegate {

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        openSelectedItem(indexPath: indexPath, secondaryIndexPath: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if showingLoader {
            return 1
        }
        return self.discoverListArr.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        
//        if kind == UICollectionView.elementKindSectionHeader || discoverListArr.count == 0 {
//
//        }
//        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EmptyReusableView", for: indexPath) as! EmptyReusableView
//        view.frame = .zero
//        return view

        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EmptyCollectionViewCell", for: indexPath) as! EmptyCollectionViewCell
        view.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 100)
            //CGSize(width: self.view.frame.size.width, height: 100)
        view.delegate = self
        return view
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if showingLoader {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath) as! EmptyCell
            return cell
            
        }
        
        if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.REELS.rawValue {
            
            if self.discoverListArr[indexPath.item].data?.large ?? false {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "carouselDiscoverCell", for: indexPath) as! carouselDiscoverCell
                cell.setUpCell(content: self.discoverListArr[indexPath.item])
                cell.delegate = self
                cell.layoutIfNeeded()
                return cell
            } else {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReelsSuggestedDiscoverCC", for: indexPath) as! ReelsSuggestedDiscoverCC
                cell.setupCell(content: self.discoverListArr[indexPath.item], row: indexPath.item, isHomeFeed: false)
                cell.delegate = self
                cell.layoutIfNeeded()
                return cell
            }
            
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.TOPICS.rawValue {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopicsDiscoverCC", for: indexPath) as! TopicsDiscoverCC
            cell.setUpCell(model: self.discoverListArr[indexPath.item])
            cell.delegate = self
            cell.layoutIfNeeded()
            return cell
            
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.ARTICLE.rawValue  {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleArticleCC", for: indexPath) as! SingleArticleCC
            cell.setUpCell(model: self.discoverListArr[indexPath.item])
            cell.delegate = self
            cell.layoutIfNeeded()
            return cell
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.ARTICLES.rawValue  {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopNewsDiscoverCC", for: indexPath) as! TopNewsDiscoverCC
            cell.setupCell(model: self.discoverListArr[indexPath.item])
            cell.delegate = self
            cell.layoutIfNeeded()
            return cell
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.CHANNELS.rawValue  {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChannelsDiscoverCC", for: indexPath) as! ChannelsDiscoverCC
            cell.setupCell(model: self.discoverListArr[indexPath.item], indexPath: indexPath)
            cell.delegate = self
            cell.layoutIfNeeded()
            return cell
            
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.AUTHORS.rawValue  {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AuthorsDiscoverCC", for: indexPath) as! AuthorsDiscoverCC
            cell.setupCell(model: self.discoverListArr[indexPath.item])
            cell.delegate = self
            cell.layoutIfNeeded()
            return cell
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.ARTICLE_VIDEOS.rawValue  {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopVideosDiscoverCC", for: indexPath) as! TopVideosDiscoverCC
            cell.setUpCell(model: self.discoverListArr[indexPath.item])
            cell.delegate = self
            cell.layoutIfNeeded()
            return cell
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.PLACES.rawValue  {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationDiscoverCC", for: indexPath) as! locationDiscoverCC
            cell.setupCell(model: self.discoverListArr[indexPath.item])
            cell.delegate = self
            cell.layoutIfNeeded()
            return cell
        }
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopVideosDiscoverCC", for: indexPath) as! TopVideosDiscoverCC
//            cell.setUpCell()
            return cell
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        self.viewWillLayoutSubviews()
        
        if self.isAPIPaginationRunning {
            return
        }
        
        let count = (self.discoverListArr.count)
        if count > 0 && indexPath.row >= count/2 {  //numberofitem count
            if nextPageData.isEmpty == false {
                
                if isPagingLoaderAdded == false {
                    addPagingLoader()
                }
                pagingLoader.startAnimating()
                self.pagingLoader.hidesWhenStopped = true
                performWSToDiscoverList(page: nextPageData)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if showingLoader {
            return .zero
        }
        
        if discoverListArr.count == 0 {
//            return CGSize(width: collectionView.frame.size.width, height: 600)
            return CGSize(width: 0, height: 0)
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.REELS.rawValue {
            if self.discoverListArr[indexPath.item].data?.large ?? false {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return CGSize(width: collectionView.frame.size.width, height: 700)
                }
                return CGSize(width: collectionView.frame.size.width, height: 500)
            } else {
                return CGSize(width: collectionView.frame.size.width, height: 280)
            }
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.TOPICS.rawValue {
            if self.discoverListArr[indexPath.item].data?.large ?? false {
                
                return CGSize(width: collectionView.frame.size.width, height: 405)
                
            } else {
                
                return CGSize(width: collectionView.frame.size.width, height: 295)
                
            }
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.ARTICLE.rawValue  {
            if self.discoverListArr[indexPath.item].data?.article?.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO || self.discoverListArr[indexPath.item].data?.article?.type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
                return CGSize(width: collectionView.frame.size.width, height: 310)
                
            } else {
                return CGSize(width: collectionView.frame.size.width, height: 500)
            }
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.ARTICLES.rawValue  {
            if self.discoverListArr[indexPath.item].data?.top ?? false {
                
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return CGSize(width: collectionView.frame.size.width, height: 280)
                }
                return CGSize(width: collectionView.frame.size.width, height: (collectionView.frame.size.width / 2.5) / 1.05)
                
            } else {
                return CGSize(width: collectionView.frame.size.width, height: 310)
            }
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.CHANNELS.rawValue  {
            
            return CGSize(width: collectionView.frame.size.width, height: 310)
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.AUTHORS.rawValue  {
            return CGSize(width: collectionView.frame.size.width, height: 220 + 71)
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.ARTICLE_VIDEOS.rawValue  {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return CGSize(width: collectionView.frame.size.width, height: 450)
            } 
            return CGSize(width: collectionView.frame.size.width, height: 400)
        }
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.PLACES.rawValue  {
            return CGSize(width: collectionView.frame.size.width, height: 460)
        }
        else {
            return CGSize.zero
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? carouselDiscoverCell {
           
            cell.pauseAllCurrentlyFocusedMedia()
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? TopVideosDiscoverCC {
            
            cell.pauseAllCurrentlyFocusedMedia()
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? SingleArticleCC {
           
            cell.stopVideo()
        }
    }
  
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 0, left: 0, bottom: 35, right: 0)
    }
    
    
    
}


// MARK: - Webservices
extension NewDiscoverVC {
    
    func performWSToDiscoverListBackgroundTask(_ arrCache: [DiscoverData]) {
        
        let param = [
            "page": "",
            "theme": "dark"
        ] as [String : Any]
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/discover", method: .get, parameters: param, headers: token, withSuccess: { [weak self] (response)  in
            self?.pagingLoader.stopAnimating()
            self?.pagingLoader.hidesWhenStopped = true
            
            do{
                var FULLResponse = try
                    JSONDecoder().decode(DiscoverModel.self, from: response)
                
                if let discovers = FULLResponse.discover {
                                        
                    if SharedManager.shared.lastModifiedTimeDiscover != self?.lastModified || SharedManager.shared.lastModifiedTimeDiscover == "" {
                        
                        //                        self?.pauseAllCurrentlyFocusedMedia()
                        self?.currentlyFocusedIndexPath = IndexPath(item: 0, section: 0)
                        self?.discoverListArr.removeAll()
                        self?.collectionView.contentOffset = .zero
                        
                        //                        if (self?.discoverListArr.count ?? 0) == 0 {
                        //                            self?.discoverListArr = discovers
                        ////                            SharedManager.shared.videoFocusedIndex = 0
                        //                        }
                        //                        else {
                        //                            self?.discoverListArr += discovers
                        //                            SharedManager.shared.videoFocusedIndex = 0
                        //                        }
                        
                        self?.discoverListArr = discovers
                        UIView.performWithoutAnimation {
                            self?.collectionView.reloadData()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self?.scrollToTopVisibleCell()
                            }
                        }
                        
                        self?.lastModified = SharedManager.shared.lastModifiedTimeDiscover
                        FULLResponse.lastModified = self?.lastModified
                        self?.writeCache(arrCacheDiscover: FULLResponse)
                        
                        
                        if let next = FULLResponse.meta?.next, next.isEmpty == false {
                            self?.nextPageData = next
                        } else {
                            self?.nextPageData = ""
                        }
                    }
                }
                
//                // Meta data
//                if let next = FULLResponse.meta?.next, next.isEmpty == false {
//                    self?.nextPageData = next
//                } else {
//                    self?.nextPageData = ""
//                }

                
            } catch let jsonerror {

                print("error parsing json objects", jsonerror)
            }
            ANLoader.hide()
            
        }) { (error) in

            print("error parsing json objects", error)
        }
    }
    
    func performWSToDiscoverList(page: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        if (self.discoverListArr.count) == 0 {
            ANLoader.showLoading()
        }
        let param = [
            "page": page,
            "theme": "dark"
        ] as [String : Any]
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        
        self.isAPIPaginationRunning = true
        
        
        WebService.URLResponse("news/discover", method: .get, parameters: param, headers: token, withSuccess: { [weak self] (response)  in
            
            ANLoader.hide()
            self?.pagingLoader.stopAnimating()
            self?.pagingLoader.hidesWhenStopped = true
            
            self?.isAPIPaginationRunning = false
            do{
                var FULLResponse = try
                    JSONDecoder().decode(DiscoverModel.self, from: response)
                
                if let discovers = FULLResponse.discover {
                    
                    SharedManager.shared.isDiscoverTabReload = false

                    if (self?.discoverListArr.count ?? 0) == 0 {
                        
                        self?.currentlyFocusedIndexPath = IndexPath(item: 0, section: 0)
                        self?.discoverListArr = discovers
                        SharedManager.shared.videoFocusedIndex = 0
                        
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                            self?.playCurrentlyFocusedMedia()
//                        }
                        
                        
                        self?.currentlyFocusedIndexPath = IndexPath(item: 0, section: 0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self?.scrollToTopVisibleCell()
                        }
                        
                        // last modeified date of first one
                        self?.lastModified =  SharedManager.shared.lastModifiedTimeDiscover
                        FULLResponse.lastModified = self?.lastModified
                        
                    } else {
                        
                        for disc in discovers {
                            
                            if self?.discoverListArr.contains(where: { $0.title == disc.title }) == false {
                                self?.discoverListArr.append(disc)
                            }
                        }
                        
                        //self?.discoverListArr! += discovers
                        SharedManager.shared.videoFocusedIndex = 0
                    }
                    
                }
                
                
                DispatchQueue.main.async {
                    if self?.showingLoader ?? false {
                        self?.showingLoader = false
                    }
                    UIView.performWithoutAnimation {
                        self?.collectionView.reloadData()
                    }
                    
                }
//                UIView.performWithoutAnimation {
//                    self?.collectionView.reloadData()
//                }
                
                
                
//
                // Meta data
                if let next = FULLResponse.meta?.next, next.isEmpty == false {
                    self?.nextPageData = next
                } else {
                    self?.nextPageData = ""
                }
                
                // Insert cache
                var response = FULLResponse
                response.lastModified = self?.lastModified
                response.discover = self?.discoverListArr
                self?.writeCache(arrCacheDiscover: response)
                
            } catch let jsonerror {
                
                ANLoader.hide()
                self?.isAPIPaginationRunning = false
                DispatchQueue.main.async {
                    
                    if self?.showingLoader ?? false {
                        self?.showingLoader = false
                    }
                    UIView.performWithoutAnimation {
                        self?.collectionView.reloadData()
                    }
                    
                }
                self?.pagingLoader.stopAnimating()
                self?.pagingLoader.hidesWhenStopped = true
                SharedManager.shared.logAPIError(url: "news/discover", error: jsonerror.localizedDescription, code: "")
                SharedManager.shared.showAPIFailureAlert()
                ANLoader.hide()
                print("error parsing json objects", jsonerror)
            }
            ANLoader.hide()
            
        }) { (error) in
            
            ANLoader.hide()
            self.isAPIPaginationRunning = false
            DispatchQueue.main.async {
                if self.showingLoader {
                    self.showingLoader = false
                }
                UIView.performWithoutAnimation {
                    self.collectionView.reloadData()
                }
                
            }
            self.pagingLoader.stopAnimating()
            self.pagingLoader.hidesWhenStopped = true
            ANLoader.hide()
            print("error parsing json objects", error)
        }
    }
    
    func performWSToOpenTopics(id: String, title: String, favorite: Bool) {
                            
        ANLoader.showLoading(disableUI: false)
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        
        let url = "news/topics/related/\(id)"
        WebService.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do {
                let FULLResponse = try
                    JSONDecoder().decode(SubTopicDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    if let topics = FULLResponse.topics {
                        
                        SharedManager.shared.subTopicsList = topics
                        
                        let vc = HomeVC.instantiate(fromAppStoryboard: .Main)
                        vc.showArticleType = .topic
                        vc.selectedID = id
                        vc.isFav = favorite
                        vc.subTopicTitle = title
                        
                        let nav = AppNavigationController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true, completion: nil)
                    }
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.showAPIFailureAlert()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            //SharedManager.shared.showAPIFailureAlert()
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performGoToSource(_ id: String) {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponse("news/sources/data/\(id)", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ChannelListDC.self, from: response)
                
                DispatchQueue.main.async {
                    
                    if let Info = FULLResponse.channel {
                        
                        let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
                        detailsVC.channelInfo = Info
                        //detailsVC.delegateVC = self
                        //detailsVC.isOpenFromDiscoverCustomListVC = true
                        detailsVC.modalPresentationStyle = .fullScreen
                        let nav = AppNavigationController(rootViewController: detailsVC)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true, completion: nil)

                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: NSLocalizedString("Related Sources not available", comment: ""))
                    }
                }
                
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/sources/data/\(id)", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
}

// MARK: Cell Selection Delegates

extension NewDiscoverVC: carouselDiscoverCellDelegate, ReelsSuggestedDiscoverCCDelegate, TopicsDiscoverCCDelegate, TopVideosDiscoverCCDelegate,TopNewsDiscoverCCDelegate, ChannelsDiscoverCCDelegate, AuthorsDiscoverCCDelegate,locationDiscoverCCDelegate {
   
   
    func scrollViewScrolling(collection: carouselDiscoverCell, status: Bool) {
        
        if status {
            collectionView.isScrollEnabled = false
        } else {
            collectionView.isScrollEnabled = true
        }
        
    }
    func scrollViewScrolling(collection: TopVideosDiscoverCC, status: Bool) {
        
        if status {
            collectionView.isScrollEnabled = false
        } else {
            collectionView.isScrollEnabled = true
        }
        
    }
    
    
    func setCurrentFocusedSelected(cell: TopVideosDiscoverCC) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        if currentlyFocusedIndexPath != indexPath {
            pauseAllCurrentlyFocusedMedia()
            currentlyFocusedIndexPath = indexPath
        }
        
    }
    
    func setCurrentFocusedSelected(cell: carouselDiscoverCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        if currentlyFocusedIndexPath != indexPath {
            pauseAllCurrentlyFocusedMedia()
            currentlyFocusedIndexPath = indexPath
        }
        
    }
    
    func didSelectItem(cell: carouselDiscoverCell, secondaryIndex: IndexPath) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        openSelectedItem(indexPath: indexPath, secondaryIndexPath: secondaryIndex)
    }
    
    func didTapOnChannel(cell: carouselDiscoverCell, secondaryIndex: IndexPath) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.REELS.rawValue {
                        
            let reel = self.discoverListArr[indexPath.item].data?.reels?[secondaryIndex.item]
            
            if let source = reel?.source {
                                
                self.performGoToSource(source.id ?? "")
            }
            else {
                                
                let authors = reel?.authors
                if (authors?.first?.id ?? "") == SharedManager.shared.userId {
    
                    let vc = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
                    let navVC = AppNavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .overFullScreen
                    //vc.delegate = self
                    self.present(navVC, animated: true, completion: nil)
                }
                else {
    
                    let vc = AuthorProfileVC.instantiate(fromAppStoryboard: .Main)
                    vc.authors = authors
                    let navVC = AppNavigationController(rootViewController: vc)
                    navVC.modalPresentationStyle = .overFullScreen
    //                vc.delegateVC = self
                    self.present(navVC, animated: true, completion: nil)
                }
            }

            
        }
    }
    
    func didSelectItem(cell: ReelsSuggestedDiscoverCC, secondaryIndex: IndexPath) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        openSelectedItem(indexPath: indexPath, secondaryIndexPath: secondaryIndex)
    }
    
    func didSelectItem(cell: TopicsDiscoverCC, secondaryIndex: IndexPath) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        openSelectedItem(indexPath: indexPath, secondaryIndexPath: secondaryIndex)
    }
    
    func didTapAddButton(cell: TopicsDiscoverCC, secondaryIndex: IndexPath, favorite: Bool) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        self.discoverListArr[indexPath.item].data?.topics?[secondaryIndex.item].favorite = favorite
        
        let content = self.discoverListArr[indexPath.item].data?.topics?[secondaryIndex.item]
        SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [content?.id ?? ""], isFav: content?.favorite ?? false, type: .topics) { status in
            if status {
                print("status", status)
            } else {
                print("status", status)
            }
        }
    }
    
    func didSelectItem(cell: TopNewsDiscoverCC, secondaryIndex: IndexPath) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        openSelectedItem(indexPath: indexPath, secondaryIndexPath: secondaryIndex)
        
    }
    
    func didSelectItem(cell: TopVideosDiscoverCC, secondaryIndex: IndexPath) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        openSelectedItem(indexPath: indexPath, secondaryIndexPath: secondaryIndex)
    }
    
    
    func didTapOnChannelCell(cell: ChannelsDiscoverCC, secondaryIndexPath: IndexPath) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        openSelectedItem(indexPath: indexPath, secondaryIndexPath: secondaryIndexPath)
    }
    
    func didTapAddButton(cell: ChannelsDiscoverCC, secondaryIndex: IndexPath, favorite: Bool) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        self.discoverListArr[indexPath.item].data?.sources?[secondaryIndex.item].favorite = favorite
        
        let content = self.discoverListArr[indexPath.item].data?.sources?[secondaryIndex.item]
        
        SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [content?.id ?? ""], isFav: content?.favorite ?? false, type: .sources) { status in
            if status {
                print("status", status)
                
                //read articles data from cache
                do {
                    var object: DiscoverModel? = try DataCache.instance.readCodable(forKey: Constant.CACHE_DISCOVER_PAGE)
                    object?.discover = self.discoverListArr
                    if let obj = object {
                        self.writeCache(arrCacheDiscover: obj)
                    }
                } catch {
                    print("Read error \(error.localizedDescription)")
                }

            } else {
                print("status", status)
            }
        }
    }
    
    
    func didTapOnChannelCell(cell: AuthorsDiscoverCC, secondaryIndexPath: IndexPath) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        openSelectedItem(indexPath: indexPath, secondaryIndexPath: secondaryIndexPath)
    }
    
    func didTapAddButton(cell: AuthorsDiscoverCC, secondaryIndex: IndexPath, favorite: Bool) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        self.discoverListArr[indexPath.item].data?.authors?[secondaryIndex.item].favorite = favorite
        
        let content = self.discoverListArr[indexPath.item].data?.authors?[secondaryIndex.item]
        SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [content?.id ?? ""], isFav: content?.favorite ?? false, type: .authors) { status in
            if status {
                print("status", status)
            } else {
                print("status", status)
            }
        }
    }
    
    func didSelectItem(cell: locationDiscoverCC, secondaryIndex: IndexPath) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        openSelectedItem(indexPath: indexPath, secondaryIndexPath: secondaryIndex)
    }
    
}

extension NewDiscoverVC: BulletDetailsVCLikeDelegate, BulletDetailsVCDelegate {
    
    func dismissBulletDetailsVC(selectedArticle: articlesData?) {
        
    }
    
    func backButtonPressed(cell: HomeDetailCardCell?) {
        
        playCurrentlyFocusedMedia()
    }
    
    //Not in use in this class
    func likeUpdated(articleID: String, isLiked: Bool, count: Int) {
        
//        updateLikeComment(articleID: articleID)
        var rowIndex: Int?
        for (index,objects) in discoverListArr.enumerated() {
            if objects.type == "ARTICLES" {
                rowIndex = index
            }
        }
        
        if rowIndex != nil {
            
            
            if let selectedIndex = discoverListArr[rowIndex!].data?.articles?.firstIndex(where: { $0.id == articleID }) {
//                    self.articles[selectedIndex].info = info
                self.discoverListArr[rowIndex!].data?.articles?[selectedIndex].info?.likeCount = count
                self.discoverListArr[rowIndex!].data?.articles?[selectedIndex].info?.isLiked = isLiked
                
//                if let cell = self.tbDiscover.cellForRow(at: IndexPath(row: rowIndex!, section: 0)) {
//                    (cell as? GenericTableView)?.articlesArr = self.discoverListArr?[rowIndex!].data?.articles
//                    (cell as? GenericTableView)?.tbList.reloadData()
//                }
                
            }
            
        }
        
        print("likeUpdated")
        
    }
    
    func commentUpdated(articleID: String, count: Int) {
        
//        updateLikeComment(articleID: articleID)
        var rowIndex: Int?
        for (index,objects) in discoverListArr.enumerated() {
            if objects.type == "ARTICLES" {
                rowIndex = index
            }
        }
        
        if rowIndex != nil {
            
            
            if let selectedIndex = discoverListArr[rowIndex!].data?.articles?.firstIndex(where: { $0.id == articleID }) {
//                    self.articles[selectedIndex].info = info
                self.discoverListArr[rowIndex!].data?.articles?[selectedIndex].info?.commentCount = count
                
//                if let cell = self.tbDiscover.cellForRow(at: IndexPath(row: rowIndex!, section: 0)) {
//                    (cell as? GenericTableView)?.articlesArr = self.discoverListArr?[rowIndex!].data?.articles
//                    (cell as? GenericTableView)?.tbList.reloadData()
//                }
                
            }
            
        }
        print("comment updated")
        
    }
}


extension NewDiscoverVC: ReelsVCDelegate {
    
    func changeScreen(pageIndex: Int) {
    }
    
    func switchBackToForYou() {
        
    }
    
    func loaderShowing(status: Bool) {
    }
    
    func backButtonPressed(_ isUpdateSavedArticle: Bool) {
        
        playCurrentlyFocusedMedia()
    }
    
    func currentPlayingVideoChanged(newIndex: IndexPath) {
    }
    
}

extension NewDiscoverVC: DiscoverReusableViewDelegate {
    
    func didTapSearchHeader() {
        
        self.didTapSearch()
    }
    
}


extension NewDiscoverVC {
    
    func pauseAllCurrentlyFocusedMedia() {
        if discoverListArr.count > 0 && collectionView != nil {
            
            if let cell = collectionView.cellForItem(at: currentlyFocusedIndexPath) as? carouselDiscoverCell {
                
                cell.pauseAllCurrentlyFocusedMedia()
            }
            
            if let cell = collectionView.cellForItem(at: currentlyFocusedIndexPath) as? TopVideosDiscoverCC {
                
                cell.pauseAllCurrentlyFocusedMedia()
            }
            
            if let cell = collectionView.cellForItem(at: currentlyFocusedIndexPath) as? SingleArticleCC {
                
                cell.stopVideo()
            }
        }
    }
    
    func playCurrentlyFocusedMedia() {
        
        collectionView.layoutIfNeeded()
        
        if let cell = collectionView.cellForItem(at: currentlyFocusedIndexPath) as? carouselDiscoverCell {
           
            if SharedManager.shared.reelsAutoPlay {
                cell.playCurrentlyFocusedMedia()
            }
            
        }
        
        if let cell = collectionView.cellForItem(at: currentlyFocusedIndexPath) as? TopVideosDiscoverCC {
            
            if SharedManager.shared.videoAutoPlay {
                cell.playCurrentlyFocusedMedia()
            }
            
        }
        
        if let cell = collectionView.cellForItem(at: currentlyFocusedIndexPath) as? SingleArticleCC {
           
            if SharedManager.shared.videoAutoPlay {
                cell.playVideo()
            }
            
        }
        
    }
    
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        SharedManager.shared.isOnDiscover = true
        pauseAllCurrentlyFocusedMedia()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        scrollView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.994000); //0.998000
    }
        
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        self.scrollToTopVisibleCell()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        //ScrollView for ListView Mode
        if decelerate { return }
        self.scrollToTopVisibleCell()
    }

    func fullyVisibleCells(_ inCollectionView: UICollectionView) -> [IndexPath] {

        var returnCells = [IndexPath]()

        var vCells = inCollectionView.visibleCells
        vCells = vCells.filter({ cell -> Bool in
            let cellRect = inCollectionView.convert(cell.frame, to: inCollectionView.superview)
            return inCollectionView.frame.contains(cellRect)
        })

        vCells.forEach({
            if let pth = inCollectionView.indexPath(for: $0) {
                returnCells.append(pth)
            }
        })

        return returnCells

    }
    
    func scrollToTopVisibleCell() {
        
        
        let visibleCells = fullyVisibleCells(collectionView).sorted(by: <)
        
        if visibleCells.count == 0 {
            return
        }
        
        
        var indexPathVisible = visibleCells.first
        
        let contentOffsetY = collectionView.contentOffset.y
        if contentOffsetY >= (collectionView.contentSize.height - collectionView.bounds.height) - 20 /* Needed offset */ {
            
            // last item
            indexPathVisible = visibleCells.last
        }
        
        
        
        if self.discoverListArr.count > 0 {
            
            let content = self.discoverListArr[indexPathVisible!.item]
            print("cell type:", content.type ?? "")
            
            pauseAllCurrentlyFocusedMedia()
            currentlyFocusedIndexPath = indexPathVisible!
            
            playCurrentlyFocusedMedia()
            
            
//            if SharedManager.shared.videoFocusedIndex != indexPathVisible.row {
//
//                pauseAllCurrentlyFocusedMedia()
//                pauseAllCurrentlyFocusedMedia()
//
//            } else {
//
//
//            }
        }
    }
    
}


extension NewDiscoverVC: SingleArticleCCDelegate {
    
    func openDetailsVC(cell: SingleArticleCC) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        openSelectedItem(indexPath: indexPath, secondaryIndexPath: nil)
        
    }
    
    
    func didTapPlayVideo(cell: SingleArticleCC) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        if currentlyFocusedIndexPath != indexPath {
            pauseAllCurrentlyFocusedMedia()
            currentlyFocusedIndexPath = indexPath
        }
    }
    
}
