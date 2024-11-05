//
//  DiscoverVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 04/04/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit
import DataCache

class DiscoverVC: UIViewController {

    
    @IBOutlet weak var lblSearch: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchContainerView: UIView!
    
    var discoverArray = [DiscoverData]()
    var nextPageData = ""
    
    var isFirstTimeLoaded = false
    var isAPIPaginationRunning = false
    var lastModified = ""
    
    
    var showingLoader = false
    var isVCVisible = false
    var currentlyFocusedIndexPath = IndexPath(item: 0, section: 0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        registerCells()
        setupUI()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadData()
        
        setStatusBar()
        
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        isVCVisible = true
        
        if let ptcTBC = tabBarController as? PTCardTabBarController {
            ptcTBC.showTabBar(true, animated: animated)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        isVCVisible = false
        pauseAllCurrentlyFocusedMedia()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        pauseAllCurrentlyFocusedMedia()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        setStatusBar()
        
        tableView.layoutIfNeeded()
        
        if isFirstTimeLoaded {
            
//            loadData()
            
//            if discoverArray.count > 0 {
//                playCurrentlyFocusedMedia()
//                scrollToTopVisibleCell()
//            }
        }
        isFirstTimeLoaded = true
        
        playCurrentlyFocusedMedia()
        
        if let ptcTBC = tabBarController as? PTCardTabBarController {
            ptcTBC.showTabBar(true, animated: animated)
        }
    }
    
    
    // MARK: - Methods
    func setupUI() {
        searchContainerView.layer.cornerRadius = 8
        searchContainerView.layer.borderWidth = 1
        searchContainerView.layer.borderColor = UIColor(red: 0.871, green: 0.908, blue: 0.95, alpha: 1).cgColor
        
        
        lblSearch.textColor = Constant.appColor.lightGray
    }
    
    func setStatusBar() {
        var navVC = (self.navigationController?.navigationController as? AppNavigationController)
        if navVC == nil {
            navVC = (self.navigationController as? AppNavigationController)
        }
        if navVC?.showDarkStatusBar == false {
            navVC?.showDarkStatusBar = true
            navVC?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func registerCells() {
        
        self.tableView.register(UINib(nibName: "NewTopicsCC", bundle: nil), forCellReuseIdentifier: "NewTopicsCC")
        self.tableView.register(UINib(nibName: "HomeReelCarouselCC", bundle: nil), forCellReuseIdentifier: "HomeReelCarouselCC")
        self.tableView.register(UINib(nibName: "sugClvReelsCC", bundle: nil), forCellReuseIdentifier: "sugClvReelsCC")
        self.tableView.register(UINib(nibName: "TopicsCC", bundle: nil), forCellReuseIdentifier: "TopicsCC")
        self.tableView.register(UINib(nibName: "SuggestedCC", bundle: nil), forCellReuseIdentifier: "SuggestedCC")
        self.tableView.register(UINib(nibName: "HomeVideoCarouselCC", bundle: nil), forCellReuseIdentifier: "HomeVideoCarouselCC")
        self.tableView.register(UINib(nibName: "RelatedArticlesCC", bundle: nil), forCellReuseIdentifier: "RelatedArticlesCC")
        self.tableView.register(UINib(nibName: "RelatedSourcesCC", bundle: nil), forCellReuseIdentifier: "RelatedSourcesCC")
        
//        print("cells registered")
    }
    
    func loadData() {
        
        if SharedManager.shared.isDiscoverTabReload {
            self.nextPageData = ""
            self.lastModified = ""
            self.discoverArray.removeAll()
            self.tableView.reloadData()
            self.performWSToDiscoverList(page: "")
        }
        else if let arrCache = self.readCache(), arrCache.count > 0 {
            self.getDiscoverPageData()
        }
        else {
//            self.showLoader()
            self.performWSToDiscoverList(page: "")
        }
        
    }
    

    private func getDiscoverPageData() {
        
        if let arrCache = self.readCache(), arrCache.count > 0 {
            
            self.discoverArray = arrCache
                 
            //Reload data
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
                
                playCurrentlyFocusedMedia()
                
            }
            
            DispatchQueue.background(background: {
                // do something in background
                self.performWSToDiscoverListBackgroundTask(arrCache)
            }, completion: {
                // when background job finished, do something in main thread
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
    
    
    
    // MARK: - Actions
    @IBAction func didTapSearch(_ sender: Any) {
        
        if let ptcTBC = tabBarController as? PTCardTabBarController {
            ptcTBC.showTabBar(false, animated: false)
        }
        
        pauseAllCurrentlyFocusedMedia()
        
        let vc = SearchAllVC.instantiate(fromAppStoryboard: .Main)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    
}


extension DiscoverVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.discoverArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if showingLoader {
            
            return UITableViewCell()
            
        }
        
        
        let content = self.discoverArray[indexPath.row]
        if self.discoverArray[indexPath.item].type == Constant.DiscoverTypes.REELS.rawValue {
            
            if self.discoverArray[indexPath.item].data?.large ?? false {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "HomeReelCarouselCC", for: indexPath) as! HomeReelCarouselCC
                cell.setUpCell(content: content)
                cell.delegate = self
                cell.layoutIfNeeded()
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "sugClvReelsCC", for: indexPath) as! sugClvReelsCC
                cell.selectionStyle = .none
                cell.delegateSugReels = self
                cell.setupCell(content: content, row: indexPath.row, isHomeFeed: true)
                cell.layoutIfNeeded()
                return cell
            }
            
        }
        else if self.discoverArray[indexPath.item].type == Constant.DiscoverTypes.TOPICS.rawValue || self.discoverArray[indexPath.item].type == Constant.DiscoverTypes.PLACES.rawValue {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewTopicsCC", for: indexPath) as! NewTopicsCC
            if let topics = content.data?.topics {
                cell.setupTopicsCell(topics: topics, isOpenFromDiscover: true)
            }
            else if let locations = content.data?.locations {
                cell.setupLocationsCell(locations: locations, isOpenFromDiscover: true)
            }
            cell.delegate = self
            return cell
            
        }
        else if self.discoverArray[indexPath.item].type == Constant.DiscoverTypes.ARTICLE_VIDEOS.rawValue  {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeVideoCarouselCC", for: indexPath) as! HomeVideoCarouselCC
            cell.setUpCell(model: content)
            cell.delegate = self
            cell.layoutIfNeeded()
            return cell
        }
        
        else if self.discoverArray[indexPath.item].type == Constant.DiscoverTypes.ARTICLES.rawValue  {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RelatedArticlesCC", for: indexPath) as! RelatedArticlesCC
            cell.setupCell(model: self.discoverArray[indexPath.item])
            cell.delegate = self
            cell.layoutIfNeeded()
            return cell
        }
        
         
        else if self.discoverArray[indexPath.item].type == Constant.DiscoverTypes.CHANNELS.rawValue  {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RelatedSourcesCC", for: indexPath) as! RelatedSourcesCC
            cell.setupCell(model: self.discoverArray[indexPath.item].data?.sources, title: self.discoverArray[indexPath.item].title ?? "")
            cell.delegate = self
            cell.layoutIfNeeded()
            return cell
            
        }
        /*
        else if self.discoverListArr[indexPath.item].type == Constant.DiscoverTypes.AUTHORS.rawValue  {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AuthorsDiscoverCC", for: indexPath) as! AuthorsDiscoverCC
            cell.setupCell(model: self.discoverListArr[indexPath.item])
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
        */
        
        print("content type", content.type ?? "")
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let content = self.discoverArray[indexPath.item]
        if content.type == Constant.DiscoverTypes.REELS.rawValue {
            if content.data?.large ?? false {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return 700
                }
                return 500
            } else {
                return 280
            }
        }
        else if content.type == Constant.DiscoverTypes.ARTICLE_VIDEOS.rawValue {
        
            if UIDevice.current.userInterfaceIdiom == .pad {
                return 450
            }
            return 400
        }
        else if content.type == Constant.DiscoverTypes.TOPICS.rawValue || content.type == Constant.DiscoverTypes.PLACES.rawValue {
            return 123 + 76
        }
        else if content.type == Constant.DiscoverTypes.ARTICLES.rawValue {
            return (190 * 2)
        }
        else if content.type == Constant.DiscoverTypes.CHANNELS.rawValue {
            return (100 * 3)
        }
        return 0
        
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let content = self.discoverArray[indexPath.item]
        if content.type == Constant.DiscoverTypes.REELS.rawValue {
            if content.data?.large ?? false {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return 700
                }
                return 500
            } else {
                return 280
            }
        }
        else if content.type == Constant.DiscoverTypes.ARTICLE_VIDEOS.rawValue {
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                return 450
            }
            return 400
        }
        else if content.type == Constant.DiscoverTypes.TOPICS.rawValue || content.type == Constant.DiscoverTypes.PLACES.rawValue {
            return 123 + 76
        }
        else if content.type == Constant.DiscoverTypes.ARTICLES.rawValue {
            return (190 * 2)
        }
        else if content.type == Constant.DiscoverTypes.CHANNELS.rawValue {
            return (100 * 3)
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.isAPIPaginationRunning {
            return
        }
        
        let count = (self.discoverArray.count)
        if count > 0 && indexPath.row >= count/2 {  //numberofitem count
            if nextPageData.isEmpty == false {
                
//                if isPagingLoaderAdded == false {
//                    addPagingLoader()
//                }
//                pagingLoader.startAnimating()
//                self.pagingLoader.hidesWhenStopped = true
                performWSToDiscoverList(page: nextPageData)
            }
        }
        
    }
    
}



extension DiscoverVC {
    
    
    func performWSToDiscoverList(page: String) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        if (self.discoverArray.count) == 0 {
            self.showLoaderInVC()
        }
        let param = [
            "page": page,
            "theme": "dark"
        ] as [String : Any]
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        
        self.isAPIPaginationRunning = true
        
        
        WebService.URLResponse("news/discover", method: .get, parameters: param, headers: token, withSuccess: { [weak self] (response)  in
            
            self?.hideLoaderVC()
            
            self?.isAPIPaginationRunning = false
            do{
                var FULLResponse = try
                    JSONDecoder().decode(DiscoverModel.self, from: response)
                
                if let discovers = FULLResponse.discover {
                    
                    SharedManager.shared.isDiscoverTabReload = false

                    if (self?.discoverArray.count ?? 0) == 0 {
                        
                        self?.currentlyFocusedIndexPath = IndexPath(item: 0, section: 0)
                        self?.discoverArray = discovers
                        SharedManager.shared.videoFocusedIndex = 0
                        
                        
                        self?.currentlyFocusedIndexPath = IndexPath(item: 0, section: 0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self?.scrollToTopVisibleCell()
                        }
                        
                        // last modeified date of first one
                        self?.lastModified =  SharedManager.shared.lastModifiedTimeDiscover
                        FULLResponse.lastModified = self?.lastModified
                        
                    } else {
                        
                        for disc in discovers {
                            
                            if self?.discoverArray.contains(where: { $0.title == disc.title }) == false {
                                self?.discoverArray.append(disc)
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
                        self?.tableView.reloadData()
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
                response.discover = self?.discoverArray
                self?.writeCache(arrCacheDiscover: response)
                
            } catch let jsonerror {
                
                ANLoader.hide()
                self?.isAPIPaginationRunning = false
                DispatchQueue.main.async {
                    
                    if self?.showingLoader ?? false {
                        self?.showingLoader = false
                    }
                    UIView.performWithoutAnimation {
                        self?.tableView.reloadData()
                    }
                    
                }
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
                    self.tableView.reloadData()
                }
                
            }
            ANLoader.hide()
            print("error parsing json objects", error)
        }
    }
    
    
    func performWSToDiscoverListBackgroundTask(_ arrCache: [DiscoverData]) {
        
        let param = [
            "page": "",
            "theme": "dark"
        ] as [String : Any]
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/discover", method: .get, parameters: param, headers: token, withSuccess: { [weak self] (response)  in
            
            do{
                var FULLResponse = try
                    JSONDecoder().decode(DiscoverModel.self, from: response)
                
                if let discovers = FULLResponse.discover {
                                        
                    if SharedManager.shared.lastModifiedTimeDiscover != self?.lastModified || SharedManager.shared.lastModifiedTimeDiscover == "" {
                        
                        //                        self?.pauseAllCurrentlyFocusedMedia()
                        self?.currentlyFocusedIndexPath = IndexPath(item: 0, section: 0)
                        self?.discoverArray.removeAll()
                        self?.tableView.contentOffset = .zero
                        
                        //                        if (self?.discoverListArr.count ?? 0) == 0 {
                        //                            self?.discoverListArr = discovers
                        ////                            SharedManager.shared.videoFocusedIndex = 0
                        //                        }
                        //                        else {
                        //                            self?.discoverListArr += discovers
                        //                            SharedManager.shared.videoFocusedIndex = 0
                        //                        }
                        
                        self?.discoverArray = discovers
                        UIView.performWithoutAnimation {
                            self?.tableView.reloadData()
                            
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
    
}


extension DiscoverVC {
    
    func pauseAllCurrentlyFocusedMedia() {
        if discoverArray.count > 0 && tableView != nil {
            /*
            if let cell = collectionView.cellForItem(at: currentlyFocusedIndexPath) as? carouselDiscoverCell {
                
                cell.pauseAllCurrentlyFocusedMedia()
            }
            
            if let cell = collectionView.cellForItem(at: currentlyFocusedIndexPath) as? TopVideosDiscoverCC {
                
                cell.pauseAllCurrentlyFocusedMedia()
            }
            
            if let cell = collectionView.cellForItem(at: currentlyFocusedIndexPath) as? SingleArticleCC {
                
                cell.stopVideo()
            }*/
            
            if let cell = tableView.cellForRow(at: currentlyFocusedIndexPath) as? HomeReelCarouselCC {
               
                cell.pauseAllCurrentlyFocusedMedia()
            }
            
            if let cell = tableView.cellForRow(at: currentlyFocusedIndexPath) as? HomeVideoCarouselCC{
               
                cell.pauseAllCurrentlyFocusedMedia()
            }
            
            
        }
    }
    
    func playCurrentlyFocusedMedia() {
        
        if isVCVisible == false {
            return
        }
        
        tableView.layoutIfNeeded()
        /*
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
            
        }*/
        
        if let cell = tableView.cellForRow(at: currentlyFocusedIndexPath) as? HomeReelCarouselCC {
           
            cell.playCurrentlyFocusedMedia()
        }
        
        if let cell = tableView.cellForRow(at: currentlyFocusedIndexPath) as? HomeVideoCarouselCC{
           
            cell.playCurrentlyFocusedMedia()
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
    
    func scrollToTopVisibleCell() {
        
        // set hight light to a new first or center cell
        //SharedManager.shared.clearProgressBar()
        var isVisible = false
        var indexPathVisible:  IndexPath?
        for indexPath in tableView.indexPathsForVisibleRows ?? [] {
            let cellRect = tableView.rectForRow(at: indexPath)
            isVisible = tableView.bounds.contains(cellRect)
            if isVisible {
                //print("indexPath is Visible")
                indexPathVisible = indexPath
                break
            }
        }
        
        if isVisible == false {
            //print("indexPath not Visible")
            let center = self.view.convert(tableView.center, to: tableView)
            indexPathVisible = tableView.indexPathForRow(at: center)
        }
        
//        if let visibleRows = tableView.indexPathsForVisibleRows, let focusIdx = forceSelectedIndexPath {
//
//            if visibleRows.contains(focusIdx) {
//                print("not same focussed cell...")
//                updateProgressbarStatus(isPause: false)
//                return
//            }
//        }
        
        var visibleCells = tableView.indexPathsForVisibleRows
        
        let contentOffsetY = tableView.contentOffset.y
        if contentOffsetY == 0 {
            if let visibleCells = visibleCells{
                indexPathVisible = visibleCells.first
            }
        }
        if contentOffsetY >= (tableView.contentSize.height - tableView.bounds.height) - 20 /* Needed offset */ {
            
            // last item
            if let visibleCells = visibleCells{
                indexPathVisible = visibleCells.last
            }
        }
        
        
        
        if let indexPath = indexPathVisible, indexPath != currentlyFocusedIndexPath {
            
            
            //Reset cell
            self.pauseAllCurrentlyFocusedMedia()
            
            
            //Set Selected index into focus variables
            currentlyFocusedIndexPath = indexPath

            //set selected cell
            playCurrentlyFocusedMedia()
        }
        else {
            
            if isVisible {
                
                playCurrentlyFocusedMedia()
            }
            else {
                
                pauseAllCurrentlyFocusedMedia()
            }

        }
    }
    
}

extension DiscoverVC: HomeReelCarouselCCDelegate {
    
    func didSelectItem(cell: HomeReelCarouselCC, secondaryIndex: IndexPath) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        openSelectedItem(indexPath: indexPath, secondaryIndexPath: secondaryIndex)

    }
    
    func didTapOnChannel(cell: HomeReelCarouselCC, secondaryIndex: IndexPath) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        pauseAllCurrentlyFocusedMedia()
        
        let reel = self.discoverArray[indexPath.row].data?.reels?[secondaryIndex.item]
        
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
    
    func setCurrentFocusedSelected(cell: HomeReelCarouselCC) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        if currentlyFocusedIndexPath != indexPath {
            pauseAllCurrentlyFocusedMedia()
            currentlyFocusedIndexPath = indexPath
        }
    }
    
}

extension DiscoverVC: sugClvReelsCCDelegate {
    func didTapOnReelsCell(cell: UITableViewCell, reelRow: Int) {
        
    }
}

extension DiscoverVC {
    
    func openSelectedItem(indexPath: IndexPath, secondaryIndexPath: IndexPath?) {
        
        if discoverArray[indexPath.row].type == Constant.DiscoverTypes.REELS.rawValue {
            
            guard let secondaryIndex = secondaryIndexPath  else { return }
            
            let reel = discoverArray[indexPath.row].data?.reels?[secondaryIndex.row]
            //openReels(title: "", context: reel?.context, isOpenForTags: false)
            
            pauseAllCurrentlyFocusedMedia()
                        
            let vc = ReelsVC.instantiate(fromAppStoryboard: .Reels)
            vc.isBackButtonNeeded = true
            vc.modalPresentationStyle = .overFullScreen
            if let reels = discoverArray[indexPath.row].data?.reels {
                vc.reelsArray = reels
            }

            //vc.isSugReels = true
            //vc.delegate = self
            vc.userSelectedIndexPath = IndexPath(item: secondaryIndex.row, section: 0)
            vc.authorID = reel?.authors?.first?.id ?? ""
            vc.scrollToItemFirstTime = true

            let navVC = AppNavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .overFullScreen
            self.present(navVC, animated: true, completion: nil)

        }
        else if discoverArray[indexPath.row].type == Constant.DiscoverTypes.ARTICLE_VIDEOS.rawValue {
            
            guard let secondaryIndex = secondaryIndexPath  else { return }
            
            let article = discoverArray[indexPath.row].data?.articles?[secondaryIndex.row]
            openBulletDetails(indexPath: indexPath, article: article)
        }
        else if discoverArray[indexPath.row].type == Constant.DiscoverTypes.ARTICLES.rawValue {
            
            guard let secondaryIndex = secondaryIndexPath  else { return }
            
            let article = discoverArray[indexPath.row].data?.articles?[secondaryIndex.row]
            openBulletDetails(indexPath: indexPath, article: article)
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
        
        SharedManager.shared.isOnDiscover = true
        self.present(navVC, animated: true, completion: nil)
        
    }
    
}

extension DiscoverVC {
    
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

extension DiscoverVC: ChannelDetailsVCDelegate {
    
    func backButtonPressedChannelDetailsVC(_ channel: ChannelInfo?) {
    }
    
    func backButtonPressedWhenFromReels(_ channel: ChannelInfo?) {
    }
    
}


extension DiscoverVC: HomeVideoCarouselCCDelegate {
    
    
    func didSelectItem(cell: HomeVideoCarouselCC, secondaryIndex: IndexPath) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        openSelectedItem(indexPath: indexPath, secondaryIndexPath: secondaryIndex)
    }
    
    func setCurrentFocusedSelected(cell: HomeVideoCarouselCC) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        if currentlyFocusedIndexPath != indexPath {
            pauseAllCurrentlyFocusedMedia()
            currentlyFocusedIndexPath = indexPath
        }
    }
    
    
    
    
}

extension DiscoverVC: BulletDetailsVCLikeDelegate, BulletDetailsVCDelegate {
    
    func dismissBulletDetailsVC(selectedArticle: articlesData?) {
        
    }
    
    func backButtonPressed(cell: HomeDetailCardCell?) {
        
        playCurrentlyFocusedMedia()
    }
    
    //Not in use in this class
    func likeUpdated(articleID: String, isLiked: Bool, count: Int) {
        
//        updateLikeComment(articleID: articleID)
        var rowIndex: Int?
        for (index,objects) in discoverArray.enumerated() {
            if objects.type == "ARTICLES" {
                rowIndex = index
            }
        }
        
        if rowIndex != nil {
            
            
            if let selectedIndex = discoverArray[rowIndex!].data?.articles?.firstIndex(where: { $0.id == articleID }) {
//                    self.articles[selectedIndex].info = info
                self.discoverArray[rowIndex!].data?.articles?[selectedIndex].info?.likeCount = count
                self.discoverArray[rowIndex!].data?.articles?[selectedIndex].info?.isLiked = isLiked
                
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
        for (index,objects) in discoverArray.enumerated() {
            if objects.type == "ARTICLES" {
                rowIndex = index
            }
        }
        
        if rowIndex != nil {
            
            
            if let selectedIndex = discoverArray[rowIndex!].data?.articles?.firstIndex(where: { $0.id == articleID }) {
//                    self.articles[selectedIndex].info = info
                self.discoverArray[rowIndex!].data?.articles?[selectedIndex].info?.commentCount = count
                
//                if let cell = self.tbDiscover.cellForRow(at: IndexPath(row: rowIndex!, section: 0)) {
//                    (cell as? GenericTableView)?.articlesArr = self.discoverListArr?[rowIndex!].data?.articles
//                    (cell as? GenericTableView)?.tbList.reloadData()
//                }
                
            }
            
        }
        print("comment updated")
        
    }
}

extension DiscoverVC: RelatedArticlesCCDelegate {
    
    
    func didSelectItem(cell: RelatedArticlesCC, secondaryIndex: IndexPath) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        openSelectedItem(indexPath: indexPath, secondaryIndexPath: secondaryIndex)
        
    }
    
}


extension DiscoverVC: RelatedSourcesCCDelegate {
    
    
    func openChannelDetails(channel: ChannelInfo) {
        // EWA
        let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
        detailsVC.isOpenFromReel = false
        detailsVC.delegate = self
        detailsVC.isOpenForTopics = false
        detailsVC.channelInfo = channel
//        detailsVC.context = channel.context ?? ""
//                    detailsVC.topicTitle = "#\(articles[indexPath.row].suggestedTopics?[row].name ?? "")"
        detailsVC.modalPresentationStyle = .fullScreen
        
        let nav = AppNavigationController(rootViewController: detailsVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func didTapSeeAll(cell: RelatedSourcesCC) {
        let vc = FollowingAuthorsVC.instantiate(fromAppStoryboard: .Channel)
        let nav = AppNavigationController(rootViewController: vc)
        vc.delegate = self
        self.present(nav, animated: true, completion: nil)
    }
    
    
    func didSelectItem(cell: RelatedSourcesCC, secondaryIndex: IndexPath) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
//        openSelectedItem(indexPath: indexPath, secondaryIndexPath: secondaryIndex)
        
        if let channel = self.discoverArray[indexPath.row].data?.sources?[secondaryIndex.item] {
            openChannelDetails(channel: channel)
        }
    }
    
    func didTapFollowing(cell: RelatedSourcesCC, secondaryIndex: IndexPath) {
       // EWA
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let fav = self.discoverArray[indexPath.row].data?.sources?[secondaryIndex.item].favorite ?? false
        let id = self.discoverArray[indexPath.row].data?.sources?[secondaryIndex.item].id ?? ""
        self.discoverArray[indexPath.row].data?.sources?[secondaryIndex.item].isShowingLoader = true
        cell.channelsArray[secondaryIndex.item].isShowingLoader = true
        
        cell.collectionView.reloadItems(at: [secondaryIndex])
        
        SharedManager.shared.performWSToUpdateUserFollow(vc: self, id: [id], isFav: !fav, type: .sources) {  success in
            
            self.discoverArray[indexPath.row].data?.sources?[secondaryIndex.item].isShowingLoader = false
            cell.channelsArray[secondaryIndex.item].isShowingLoader = false
            
            if success {
                self.discoverArray[indexPath.row].data?.sources?[secondaryIndex.item].favorite = !fav
                cell.channelsArray[secondaryIndex.item].favorite = !fav
            }
            
            cell.collectionView.reloadItems(at: [secondaryIndex])
            
        }
        
    }
}


extension DiscoverVC: AddTopicsVCDelegate, AddLocationVCDelegate, FollowingAuthorsVCDelegate {
    
    func followingListUpdated() {
    }
    
    func locationListUpdated() {
    }
    
    func topicsListUpdated() {
    }
}


extension DiscoverVC: NewTopicsCCDelegate {
    
    func openAddLocation() {
        
        let vc = AddLocationVC.instantiate(fromAppStoryboard: .Reels)
        vc.delegate = self
        self.present(vc, animated: true)
        
    }
    
    func openAddTopics() {
        
        let vc = AddTopicsVC.instantiate(fromAppStoryboard: .Reels)
        vc.delegate = self
        self.present(vc, animated: true)
        
    }
    
    
    func didTapSeeallTopics(cell: NewTopicsCC) {
        if cell.topicArray.count > 0 {
            // Open add topics
            openAddTopics()
        }
        else if cell.locationsArray.count > 0 {
            // Open add locations
            openAddLocation()
        }
    }
    
    
    func didSelectItem(cell: NewTopicsCC, secondaryIndex: Int) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        var context = ""
        var topicTitle = ""
        if cell.topicArray.count > 0 {
            context = discoverArray[indexPath.row].data?.topics?[secondaryIndex].context ?? ""
            topicTitle = discoverArray[indexPath.row].data?.topics?[secondaryIndex].name ?? ""
        }
        else if cell.locationsArray.count > 0 {
            context = discoverArray[indexPath.row].data?.locations?[secondaryIndex].context ?? ""
            topicTitle = discoverArray[indexPath.row].data?.locations?[secondaryIndex].name ?? ""
        }
        
        let detailsVC = ChannelDetailsVC.instantiate(fromAppStoryboard: .Schedule)
        detailsVC.isOpenFromReel = false
        detailsVC.delegate = self
        detailsVC.isOpenForTopics = true
        detailsVC.context = context
        detailsVC.topicTitle = topicTitle
        detailsVC.modalPresentationStyle = .fullScreen
        
        let nav = AppNavigationController(rootViewController: detailsVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
        
    }
    
    func openAddOther(cell: NewTopicsCC) {
        
        
        if cell.topicArray.count > 0 {
            // Open add topics
            openAddTopics()
        }
        else if cell.locationsArray.count > 0 {
            // Open add locations
            openAddLocation()
        }
    }
    
    func didCellReloaded(cell: NewTopicsCC) {
        
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        if cell.topicArray.count > 0 {
            discoverArray[indexPath.row].data?.topics = cell.topicArray
        }
        else if cell.locationsArray.count > 0 {
            discoverArray[indexPath.row].data?.locations = cell.locationsArray
        }
        
        self.tableView.reloadData()
        
    }
    
    func didTapFollow(cell: NewTopicsCC, secondaryIndex: Int) {
        
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        let cellIndex = IndexPath(item: secondaryIndex, section: 0)
        if cell.topicArray.count > 0 {
            //            self.topicsArray = cell.topicArray
            let fav = discoverArray[indexPath.row].data?.topics?[cellIndex.item].favorite ?? false
            discoverArray[indexPath.row].data?.topics?[cellIndex.item].isShowingLoader = true
            if let topic = discoverArray[indexPath.row].data?.topics {
                cell.topicArray = topic
            }
            
            cell.collectionView.reloadItems(at: [cellIndex])
            
            SharedManager.shared.performWSToUpdateUserFollow(id: [discoverArray[indexPath.row].data?.topics?[cellIndex.item].id ?? ""], isFav: !fav, type: .topics) { status in
                
                self.discoverArray[indexPath.row].data?.topics?[cellIndex.item].isShowingLoader = false
                self.discoverArray[indexPath.row].data?.topics?[cellIndex.item].favorite = !fav
                if let topic = self.discoverArray[indexPath.row].data?.topics {
                    cell.topicArray = topic
                }
                
                cell.collectionView.reloadItems(at: [cellIndex])
                
            }
        }
        else if cell.locationsArray.count > 0 {
            //            self.topicsArray = cell.topicArray
            let fav = discoverArray[indexPath.row].data?.locations?[cellIndex.item].favorite ?? false
            discoverArray[indexPath.row].data?.locations?[cellIndex.item].isShowingLoader = true
            if let topic = discoverArray[indexPath.row].data?.locations {
                cell.locationsArray = topic
            }
            
            cell.collectionView.reloadItems(at: [cellIndex])
            
            SharedManager.shared.performWSToUpdateUserFollow(id: [discoverArray[indexPath.row].data?.locations?[cellIndex.item].id ?? ""], isFav: !fav, type: .locations) { status in
                
                self.discoverArray[indexPath.row].data?.locations?[cellIndex.item].isShowingLoader = false
                self.discoverArray[indexPath.row].data?.locations?[cellIndex.item].favorite = !fav
                if let locations = self.discoverArray[indexPath.row].data?.locations {
                    cell.locationsArray = locations
                }
                
                cell.collectionView.reloadItems(at: [cellIndex])
                
            }
        }
        
    }
    
}
