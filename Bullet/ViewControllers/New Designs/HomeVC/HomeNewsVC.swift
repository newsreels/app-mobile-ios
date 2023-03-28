//
//  HomeNewsVC.swift
//  Bullet
//
//  Created by Mahesh on 13/04/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//


import UIKit
import VerticalCardSwiper
import SideMenu
import SDWebImage


class HomeNewsVC: UIViewController {
    
    //PROPERTIES
    @IBOutlet weak var lblNavTitle: UILabel!
    @IBOutlet weak var btnVideo: UIButton!
    
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewSearch: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    //Constraints
    @IBOutlet weak var constraintCollectionViewTopToViewTopBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintCollectionViewTopToViewSearchBottom: NSLayoutConstraint!

    //VARIABLES
    private var pageSize: Int = 100
    private var PageNo: Int = 1
    private var isContentLoad: Bool = false
    
    private var totalCategory: Int = 0
    private var startCatIndex: Int = 1

    private var visibleIndex: Int = 0
    private var newsCategories: [Category] = []
    private var searchContents: [Content] = []
    private let transition = CustomTransition()
    private var noOfSearchCount: Int = 0
//    var userDetails: [UserDetails] = []

    //sharing variables
    public var isSearchVC = false
    
    //deinit methods
    deinit {
      NotificationCenter.default.removeObserver(self, name: Notification.Name("reloadData"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        btnVideo.isHidden = true
        self.collectionView.register(UINib(nibName: CELL_IDENTIFIER_HOME_COLLECTION, bundle: nil), forCellWithReuseIdentifier: CELL_IDENTIFIER_HOME_COLLECTION)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(_:)), name: Notification.Name("reloadData"), object: nil)
        
        self .txtSearch.delegate = self
        self .txtSearch.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)

        //initially show header topView and hide searchView
        viewTop.isHidden = false
        viewSearch.isHidden = true
        
        if !(self.isSearchVC) {
            performWSToGetNews()
        }
        
        
        //imgTest.imageFromServerURL("https://cdn.ziroride.com/image/passenger/home/person1.webp")
        //(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL);
//        SDWebImageManager.shared.loadImage(with: URL(string: "https://cdn.ziroride.com/image/passenger/home/person1.webp"), options: .highPriority, progress: nil) { (image, data, error, cacheType, finished, imageURL) in
//
//            if error != nil {
//                print("ERROR LOADING IMAGES FROM URL: \(String(describing: error))")
//                return
//            }
//            self.imgTest.image = image ?? nil
//        }
     
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        //we will adjust the height of top view for search
        if self.isSearchVC {
            
            //Set design based on priority constraints of top view and search view hide/show
            constraintCollectionViewTopToViewSearchBottom.priority = .defaultHigh
            constraintCollectionViewTopToViewTopBottom.priority = .defaultLow
            viewTop.isHidden = true
            viewSearch.isHidden = false
            txtSearch.becomeFirstResponder()
            self.view.layoutIfNeeded()
            
            //reset all data
            self.activityIndicator.stopAnimating()
            self.newsCategories.removeAll()
            self.noOfSearchCount = 0
            self.searchContents.removeAll()
            self.collectionView.setEmptyMessage("News not available")
            self.collectionView.reloadData()
            
        }
        else {
            
            //Set design based on priority constraints of top view and search view hide/show
            constraintCollectionViewTopToViewSearchBottom.priority = .defaultLow
            constraintCollectionViewTopToViewTopBottom.priority = .defaultHigh
            viewTop.isHidden = false
            viewSearch.isHidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    //notification methods
    @objc func reloadData(_ notification: Notification) {
        // Take Action on Notification
        
        if let cell = collectionView.cellForItem(at: getCurrentVisibleIndexPath()) as? HomeCustomCell {
            let _ = cell.cardSwiper.scrollToCard(at: SharedManager.shared.focussedCardIndex, animated: false)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    //MARK:- BUTTON ACTION
    @IBAction func didTapMenu(_ sender: UIButton) {
        
        let vc = SideMenuVC.instantiate(fromAppStoryboard: .Main)
        vc.delegate = self
        let menu = SideMenuNavigationController(rootViewController: vc)
        menu.menuWidth = 240
        menu.presentationStyle = .menuSlideIn
        menu.statusBarEndAlpha = 0
        menu.setNavigationBarHidden(true, animated: false)
        SideMenuManager.default.rightMenuNavigationController = menu
        present(menu, animated: true, completion: nil)
    }
    
    @IBAction func didTapBackSearch(_ sender: UIButton) {
        
        print("click to dismiss.....")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapPlayVideo(_ sender: Any) {
        
//        let path = Bundle.main.path(forResource: "user-details", ofType: "json")
//        let data = NSData(contentsOfFile: path ?? "") as Data?
//        do {
//            let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
//            if let aUserDetails = json["userDetails"] as? [[String : Any]] {
//                for element in aUserDetails {
//                    userDetails += [UserDetails(userDetails: element)]
//                }
//            }
//        } catch let error as NSError {
//            print("Failed to load: \(error.localizedDescription)")
//        }
        performWSToGetPlayNews()

    }
    
    func getCurrentVisibleIndexPath() -> IndexPath {
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint)
        guard let indexPath = visibleIndexPath else { return IndexPath.init(row: 0, section: 1) }
        return indexPath
    }

    func getTransitionCell() -> UIView {
        if let cell = collectionView.cellForItem(at: getCurrentVisibleIndexPath()) {
            return cell.contentView
        } else if collectionView.visibleCells.count > 0 {
            let cells = collectionView.visibleCells
            return cells[cells.count / 2].contentView
        } else {
            let layouts = collectionView.collectionViewLayout.layoutAttributesForElements(in: collectionView.bounds)
            var frame = CGRect.zero
            for l in layouts ?? [] {
                if l.indexPath == getCurrentVisibleIndexPath() {
                    frame = l.frame
                }
            }
            if frame == CGRect.zero {
                frame = collectionView.subviews.first?.frame ?? CGRect.zero
            }
            frame = view.convert(frame, from: collectionView)
            let tempView = UIView(frame: frame)
            view.addSubview(tempView)
            DispatchQueue.main.async {
                tempView.removeFromSuperview()
            }
            return tempView
        }
    }
}

//MARK:- Webservices -  Private func
extension HomeNewsVC {
    
    func setNavTitle() {
        
        //self.btnVideo.isHidden = false
        self.lblNavTitle.text = self.newsCategories[self.visibleIndex].name
        
        //        UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState],
        //                       animations: {
        //                        self.constraintLblNavTitleLeading.constant = 240
        //        }, completion: { Void in
        //            self.constraintLblNavTitleLeading.constant = 20
        //            self.view.layoutIfNeeded()
        //        })
        
        //        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
        //            self.lblNavTitle.transform = CGAffineTransform(translationX: self.lblNavTitle.bounds.origin.x - (self.view.bounds.width - 180), y: self.lblNavTitle.bounds.origin.y)
        //            self.lblNavTitle.transform = .identity
        //        }, completion: nil)
        
        //                    self.constraintLblNavTitleLeading.constant = self.view.bounds.width - 60
        //                            UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState],
        //                                           animations: {
        //        //                                    self.constraintLblNavTitleLeading.constant = 20
        //                                            self.view.layoutIfNeeded()
        //                            }, completion: nil)
        
    }
    
    func performWSToGetNews() {
        
        activityIndicator.startAnimating()
        
        WebService.URLResponse("v1/contents?page_size=\(pageSize)&page=\(PageNo)&category=\(startCatIndex)", method: .get, parameters: nil, withSuccess: { (response) in
            self.activityIndicator.stopAnimating()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(NewsCategoryDC.self, from: response)
                
                if let nextPage = FULLResponse.next_page {
                    self.PageNo = nextPage
                }
                
                if let totCat = FULLResponse.total_categories {
                    self.totalCategory = totCat
                }
                
                if let categories = FULLResponse.category {
                    if !self.isContentLoad {
                        self.newsCategories.append(categories)
                        self.collectionView.reloadData()
                    }
                    else {
                        self.isContentLoad = false
                        if let contents = categories.contents {
                            self.newsCategories[self.visibleIndex].contents! += contents
                            
                            if let indexPath = self.collectionView?.indexPathsForVisibleItems {
                                self.collectionView?.reloadItems(at: indexPath)
                            }
                        }
                    }
                    self.setNavTitle()
                }
                else {
                    self.showOKAlert(title: "Bullet", message: "News not available")
                }
                
            } catch let jsonerror {
                self.activityIndicator.stopAnimating()
                print("error parsing json objects",jsonerror)
                self.showOKAlert(title: "Bullet", message: "News not available")
            }
            
        }){ (error) in
            self.activityIndicator.stopAnimating()
            print("error parsing json objects",error)
            self.showOKAlert(title: "Bullet", message: "News not available")
        }
    }
    
    func performWSToGetPlayNews() {
        
        activityIndicator.startAnimating()
        
        WebService.URLResponse("v1/contents/play", method: .get, parameters: nil, withSuccess: { (response) in
            self.activityIndicator.stopAnimating()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(contentsPlayDC.self, from: response)
                
             
                if let dur = FULLResponse.interval_seconds {
                    SharedManager.shared.duration = dur
                }
                
                if let contents = FULLResponse.contents {
//                    let content = self.newsCategories[SharedManager.shared.currentCategoryIndex].contents!

                    DispatchQueue.main.async {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContentView") as! ContentViewController
                        vc.modalPresentationStyle = .overFullScreen
                        vc.pages = contents
                        //vc.currentIndex = SharedManager.shared.focussedCardIndex
                        self.present(vc, animated: true, completion: nil)
                    }
                }
                else {
                    self.showOKAlert(title: "Bullet", message: "News Play not available")
                }
                
            } catch let jsonerror {
                self.activityIndicator.stopAnimating()
                print("error parsing json objects",jsonerror)
                self.showOKAlert(title: "Bullet", message: "News Play not available")
            }
            
        }){ (error) in
            self.activityIndicator.stopAnimating()
            print("error parsing json objects",error)
            self.showOKAlert(title: "Bullet", message: "News Play not available")
        }
    }
    
    func showOKAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


extension HomeNewsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.isSearchVC ? noOfSearchCount : self.newsCategories.count 
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER_HOME_COLLECTION, for: indexPath) as? HomeCustomCell else { return UICollectionViewCell() }
        
        cell.backgroundColor = UIColor.clear
        cell.delegate = self
        
        if self.isSearchVC {
            cell.loadData(index: indexPath.row, contents: self.searchContents)
        }
        else {
            if let contents = self.newsCategories[indexPath.row].contents {
                cell.loadData(index: indexPath.row, contents: contents)
            }
            //print("INDEX PATH....\(indexPath)")
                        
            if indexPath.row == self.newsCategories.count - 1{
                //print("Start Index: \(self.startCatIndex)")
                let sIndex: Int = self.newsCategories.count + 1
                if sIndex <= self.totalCategory {
                    self.startCatIndex = sIndex
                    performWSToGetNews()
                }
                //print("Load More Data")
            }
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { return 0 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { return 0 }
        
    //MARK:- SCROLLVIEW DELEGATE
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        visibleIndex = indexPath.row
        SharedManager.shared.currentCategoryIndex = visibleIndex
        
        self.setNavTitle()
        
    }
    
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        print("scrollViewWillBeginDragging")
//
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if ((collectionView.contentOffset.y + collectionView.frame.size.height) >= collectionView.contentSize.height)
//        {
//            print("scrollViewDidEndDragging")
//        }
//    }
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        targetContentOffset.pointee = scrollView.contentOffset
//        let pageWidth:Float = Float(self.view.bounds.width)
//        let minSpace:Float = 10.0
//        var cellToSwipe: Double = Double(Float((scrollView.contentOffset.x)) / Float((pageWidth+minSpace))) + Double(0.5)
//        if cellToSwipe < 0 {
//            cellToSwipe = 0
//        } else if cellToSwipe >= Double(self.newsCategories.count) {
//            cellToSwipe = Double(self.newsCategories.count) - Double(1)
//        }
//        let indexPath:IndexPath = IndexPath(row: Int(cellToSwipe), section:0)
//        self.collectionView.scrollToItem(at:indexPath, at: UICollectionView.ScrollPosition.left, animated: true)
//
//    }
    
  
}

//MARK:- HomeCustomCellDelegate methods
extension HomeNewsVC: HomeCustomCellDelegate {
    
    func didTapCard(index: Int, contents: [Content]) {
        
        let vc = NewsDetailsVC.instantiate(fromAppStoryboard: .Main)
        vc.arrContent = contents
        SharedManager.shared.focussedCardIndex = index
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }
    
    func loadMoreContents(_ pageNo: Int, isLoad: Bool) {
        self.PageNo = pageNo
        self.isContentLoad = isLoad
        print("PageNo.........\(PageNo)")
        self.performWSToGetNews()
    }
}

extension HomeNewsVC: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let selectedCell = collectionView.cellForItem(at: getCurrentVisibleIndexPath())
            as? HomeCustomCell, let selectedCellSuperview = selectedCell.superview else {
                return nil
        }

        transition.originFrame = selectedCellSuperview.convert(selectedCell.frame, to: nil)
        transition.originFrame = CGRect(
          x: transition.originFrame.origin.x + 20,
          y: transition.originFrame.origin.y + 20,
          width: transition.originFrame.size.width - 40,
          height: transition.originFrame.size.height - 40
        )

        transition.presenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        transition.presenting = false
        return transition
    }

}

//MARK:- SideMenu Delegate
extension HomeNewsVC: SideMenuDelegate {
    
    func didTapOnSelectedMenu(index: Int) {
        
        if index <= (self.newsCategories.count - 1) {
            visibleIndex = index
            setNavTitle()
            self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: [.centeredHorizontally], animated: false)
        }
    }
}

//MARK: - Search List
extension HomeNewsVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(textField: UITextField){
        
        if let searchText = textField.text, !(searchText.isEmpty) {
           
            self.performWSToGetSerarchList(searchText: searchText, pageSize: 10, pageNo: 1)
        }
        else {
            self.noOfSearchCount = 0
            self.searchContents.removeAll()
            self.collectionView.setEmptyMessage("News not available")
            self.collectionView.reloadData()
        }
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        let resultingStr = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
//        print(resultingStr)
//        if resultingStr == "" {
//
//            textField.text = resultingStr
//            self.noOfSearchCount = 0
//            self.searchContents.removeAll()
//            self.collectionView.setEmptyMessage("News not available")
//            self.collectionView.reloadData()
//            return false
//        }
//
//        self.performWSToGetSerarchList(searchText: resultingStr, pageSize: 10, pageNo: 1)
//
//        return true
//    }
    
    func performWSToGetSerarchList(searchText: String, pageSize: Int, pageNo: Int) {
        
        activityIndicator.startAnimating()
        WebService.URLResponse("\(Constant.API_BASE)v1/search?data=\(searchText)&page_size=\(pageSize)&page=\(pageNo)", method: .get, parameters: nil, withSuccess: { (response) in
            self.activityIndicator.stopAnimating()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(newsConentsDC.self, from: response)
                
                if let contents = FULLResponse.contents {
                    
                    self.searchContents = contents
                    self.noOfSearchCount = 1
                    self.collectionView.restore()
                    self.collectionView.reloadData()
                }
                else {
                }
                
            } catch let jsonerror {
                
                self.activityIndicator.stopAnimating()
                print("error parsing json objects",jsonerror)
                self.collectionView.setEmptyMessage("News not available")
            }
            
        }){ (error) in
            self.activityIndicator.stopAnimating()
            print("error parsing json objects",error)
            self.collectionView.setEmptyMessage("News not available")
        }
    }
}
