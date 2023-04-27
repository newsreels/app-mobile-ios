//
//  BottomSheetVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 24/11/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Foundation

protocol BottomSheetVCDelegate: AnyObject {
    
    func didTapBottomShareSheetAction(sender: UIButton, article: articlesData)
    func didTapDissmisReportContent()
    func didTapUpdateAudioAndProgressStatus()
}


class BottomSheetVC: UIViewController {
    
    @IBOutlet weak var viewTbContainer: UIView!
    var isGoToSourceHidden: Bool = false
    var isFollowSourceHidden: Bool = false
    var isBlockSourceHidden: Bool = false
    var isSavedArticleHidden: Bool = false
    var isShareArticleHidden: Bool = false
    var isReportHidden: Bool = false
    var isLikeHidden: Bool = false
    var isDislikeHidden: Bool = false
    var isCopyhidden: Bool = false
    
    //ShareSheet outlets
    var lblSaveArticle = ""
    var lblShare = ""
    var lblGoToGuardian = ""
    var lblFollowTheGuardian = ""
    var lblBlockGuardian = ""
    var lblReportContent = ""
    var lblMoreLike = ""
    var lblUnLike = ""
    var lblCaption = ""
    var lblCopy = ""
    
    var imgSaveArticle = UIImage()
    var imgShare = UIImage()
    var imgGoToGuardian = UIImage()
    var imgFollowTheGuardian = UIImage()
    var imgBlockGuardian = UIImage()
    var imgReportContent = UIImage()
    var imgMoreLike = UIImage()
    var imgUnLike = UIImage()
    var imgCaptions = UIImage()
    var imgCopy = UIImage()
    
    //REPORT VIEW
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnReportCon: UIButton!
    
    @IBOutlet var btnCollection: [UIButton]!
    @IBOutlet weak var lblReportTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tbHeightConstraint: NSLayoutConstraint!
    
    private var swipeGesture = UISwipeGestureRecognizer()
    weak var delegateBottomSheet: BottomSheetVCDelegate?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var article = articlesData()

    var articlesList: [String]?
    var isReportView = false
    var selectedContent = [String]()
    
    var sourceBlock = false
    var sourceFollow = false
    var article_archived = false
    var share_message = ""
    
    var showArticleType: ArticleType = .home
    var isMainScreen = false
    var isOtherAuthorArticleMenu = false
    var isSameAuthor = false
    var openReportList = false
    var isFromReels = false
    var isFromChannel = false
    var isCaptionOptionNeeded = false
    var isOpenForChannelDetails = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.view.isOpaque = false
//            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
//        }
        
        btnCollection.forEach { btn in
//            btn.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
            btn.setTitleColor(.black, for: .normal)
        }
        lblReportTitle.textColor = .black
        
        self.performWSToGetReportList()
        self.showActionSheet()
        
        
        
        
        
        
        //add UISwipeGestureRecognizer when selected cell is active
        let direction: [UISwipeGestureRecognizer.Direction] = [ .down]
        for dir in direction {
            self.swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeView(_:)))
            self.view.addGestureRecognizer(self.swipeGesture)
            self.swipeGesture.direction = dir
          //  self.swipeGesture.view?.tag = self
            self.view.isUserInteractionEnabled = true
            self.view.isMultipleTouchEnabled = false
        }
        
        
    }
    
    
    func showActionSheet() {
        
        //here we will show all contents bcz its from top stories screen
        
        if isOpenForChannelDetails {
            isGoToSourceHidden = true
            isFollowSourceHidden = true
            isBlockSourceHidden = false
            isSavedArticleHidden = true
            isShareArticleHidden = true
            isReportHidden = false
            isLikeHidden = true
            isDislikeHidden = true
            isCopyhidden = true
        }
        else if isFromReels {

            if openReportList {
                viewTbContainer.isHidden = false
                let button = UIButton()
                button.tag = 6
                self.didTapShareSheetActions(button)
            }
            else {
                viewTbContainer.isHidden = true
                tbHeightConstraint.constant = 0
                
                if isSameAuthor {

                    isGoToSourceHidden = true
                    isBlockSourceHidden = true
                    isFollowSourceHidden = true

                    if share_message == "" {

                        isShareArticleHidden = true
                    }
                    else {

                        isShareArticleHidden = false
                    }
                }
                else {
                    
                    isReportHidden = false
                    isGoToSourceHidden = false
                    isBlockSourceHidden = true
                    isFollowSourceHidden = true

                    if share_message == "" {

                        isShareArticleHidden = true
                    }
                    else {

                        isShareArticleHidden = false
                    }
                }
                
                isCopyhidden = false
            }
        }
        else {
            // Article
            viewTbContainer.isHidden = true
            self.tbHeightConstraint.constant = 0

            if isMainScreen {
                
                self.isGoToSourceHidden = false
                self.isBlockSourceHidden = false
                self.isFollowSourceHidden = false
                if self.share_message == "" {
                    
                    self.isShareArticleHidden = true
                }
                else {
                    
                    self.isShareArticleHidden = false
                }
            }
            //when come from notifications or widgets
            else if showArticleType == .source {
                
                self.isGoToSourceHidden = true
                self.isBlockSourceHidden = true
                self.isFollowSourceHidden = true
                if self.share_message == "" {
                    
                    self.isShareArticleHidden = true
                }
                else {
                    
                    self.isShareArticleHidden = false
                }
            }
            //Author created article open to share that
            else if isOtherAuthorArticleMenu {
                                                
                self.hasCheckSameAuthorOption()
            }

            //if user come from detail HomeTopicSources Screen
            else {
                
                self.isGoToSourceHidden = true
                self.isBlockSourceHidden = true
                self.isFollowSourceHidden = true
                if self.share_message == "" {
                    
                    self.isShareArticleHidden = true
                }
                else {
                    
                    self.isShareArticleHidden = false
                }
            }
            
            isCopyhidden = false
        }
        
        if article.type == Constant.newsArticle.ARTICLE_TYPE_REEL {
            self.isBlockSourceHidden = false
        }
        
        
        lblShare = NSLocalizedString("Share", comment: "")
        if let source = article.source {
            
            self.lblGoToGuardian = "\((NSLocalizedString("Go to", comment: ""))) \(source.name ?? "")"
            self.lblFollowTheGuardian = self.sourceFollow ? "\(NSLocalizedString("Following", comment: "")) \(source.name ?? "")" : "\(NSLocalizedString("Follow", comment: "")) \(article.source?.name ?? "")"
            self.lblBlockGuardian = self.sourceBlock ? "\(NSLocalizedString("Unblock articles from", comment: "")) \(source.name ?? "")" : "\(NSLocalizedString("Block articles from", comment: "")) \(source.name ?? "")"
        }
        else {
            
            let name = article.authors?.first?.name ?? ""
            self.lblGoToGuardian = "\((NSLocalizedString("Go to", comment: ""))) \(name)"
            self.lblFollowTheGuardian = self.sourceFollow ? "\(NSLocalizedString("Following", comment: "")) \(name)" : "\(NSLocalizedString("Follow", comment: "")) \(name)"
            self.lblBlockGuardian = self.sourceBlock ? "\(NSLocalizedString("Unblock articles from", comment: "")) \(name)" : "\(NSLocalizedString("Block articles from", comment: "")) \(name)"
        }

        
        lblReportTitle.text = NSLocalizedString("Report", comment: "")
        btnSubmit.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        btnCancel.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)

        self.lblReportContent = NSLocalizedString("Report content", comment: "")
        self.lblMoreLike = NSLocalizedString("More like this", comment: "")
        self.lblUnLike = NSLocalizedString("Not interested", comment: "")
        self.lblCaption = SharedManager.shared.isCaptionsEnableReels ? NSLocalizedString("Turn off captions", comment: "") : NSLocalizedString("Turn on captions", comment: "")
        self.lblCopy = NSLocalizedString("Copy", comment: "")
        
        self.setSubmitUI()
        
        if article_archived {
            
            self.lblSaveArticle  = NSLocalizedString("Remove from Saved", comment: "")
//            self.imgSaveArticle = UIImage(named: "PopupVideo")?.tinted(with: Constant.appColor.lightGray) ?? UIImage()
            //self.imgSaveArticle.image = UIImage(named: "bookmarkSelected")
        }
        else {
            
            self.lblSaveArticle  = NSLocalizedString("Save", comment: "")
            //self.imgSaveArticle.image = UIImage(named: "bookmark")
//            self.imgSaveArticle = UIImage(named: "PopupVideo") ?? UIImage()
        }
        
        self.imgSaveArticle = UIImage(named: "PopupVideo") ?? UIImage()
        self.imgShare = UIImage(named: "PopupSend") ?? UIImage()
        self.imgGoToGuardian = UIImage(named: "PopupUser") ?? UIImage()
        self.imgFollowTheGuardian = UIImage(named: "PopupFollow") ?? UIImage()
        self.imgBlockGuardian = UIImage(named: "PopupBlock") ?? UIImage()
        self.imgReportContent = UIImage(named: "PopupReport") ?? UIImage()
        self.imgMoreLike = UIImage(named: "PopupHappy") ?? UIImage()
        self.imgUnLike = UIImage(named: "PopupSad") ?? UIImage()
        self.imgCaptions = UIImage(named: "captionsUnselected")?.tinted(with: Constant.appColor.lightRed) ?? UIImage()
        self.imgCopy = UIImage(named: "PopupCopy") ?? UIImage()
        
        
        let alertController = UIAlertController()
        
        let actionSaveArticle = UIAlertAction(title: lblSaveArticle, style: .default) { (action: UIAlertAction!) in
            
            let btn = UIButton()
            btn.tag = 1
            self.didTapShareSheetActions(btn)
        }
        actionSaveArticle.setValue(UIColor(displayP3Red: 0.138, green: 0.125, blue: 0.292, alpha: 1), forKey: "titleTextColor")
        actionSaveArticle.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        let icon = imgSaveArticle.imageWithSize(scaledToSize: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal)
        actionSaveArticle.setValue(icon, forKey: "image")
  
        
        
        // Share
        let actionShare = UIAlertAction(title: lblShare, style: .default) { (action: UIAlertAction!) in
            
            let btn = UIButton()
            btn.tag = 2
            self.didTapShareSheetActions(btn)
        }
        actionShare.setValue(UIColor(displayP3Red: 0.138, green: 0.125, blue: 0.292, alpha: 1), forKey: "titleTextColor")
        actionShare.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        let icon2 = imgShare.imageWithSize(scaledToSize: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal)
        actionShare.setValue(icon2, forKey: "image")
        
        // Go to
        let actionGotoSource = UIAlertAction(title: lblGoToGuardian, style: .default) { (action: UIAlertAction!) in
            
            let btn = UIButton()
            btn.tag = 3
            self.didTapShareSheetActions(btn)
        }
        actionGotoSource.setValue(UIColor(displayP3Red: 0.138, green: 0.125, blue: 0.292, alpha: 1), forKey: "titleTextColor")
        actionGotoSource.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        let icon3 = imgGoToGuardian.imageWithSize(scaledToSize: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal)
        actionGotoSource.setValue(icon3, forKey: "image")
        
        
        // Follow
        let actionFollow = UIAlertAction(title: lblFollowTheGuardian, style: .default) { (action: UIAlertAction!) in
            let btn = UIButton()
            btn.tag = 4
            self.didTapShareSheetActions(btn)
        }
        actionFollow.setValue(UIColor(displayP3Red: 0.138, green: 0.125, blue: 0.292, alpha: 1), forKey: "titleTextColor")
        actionFollow.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        let icon4 = imgFollowTheGuardian.imageWithSize(scaledToSize: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal)
        actionFollow.setValue(icon4, forKey: "image")
        
        
        
        // unFollow
        let actionBlock = UIAlertAction(title: lblBlockGuardian, style: .default) { (action: UIAlertAction!) in
            let btn = UIButton()
            btn.tag = 5
            self.didTapShareSheetActions(btn)
        }
        actionBlock.setValue(UIColor(displayP3Red: 0.138, green: 0.125, blue: 0.292, alpha: 1), forKey: "titleTextColor")
        actionBlock.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        let icon5 = imgBlockGuardian.imageWithSize(scaledToSize: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal)
        actionBlock.setValue(icon5, forKey: "image")
        
        
        // Report
        let actionReport = UIAlertAction(title: lblReportContent, style: .default) { (action: UIAlertAction!) in
            let btn = UIButton()
            btn.tag = 6
            self.didTapShareSheetActions(btn)
        }
        actionReport.setValue(UIColor(displayP3Red: 0.138, green: 0.125, blue: 0.292, alpha: 1), forKey: "titleTextColor")
        actionReport.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        let icon6 = imgReportContent.imageWithSize(scaledToSize: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal)
        actionReport.setValue(icon6, forKey: "image")
        
        
        let actionMoreLike = UIAlertAction(title: lblMoreLike, style: .default) { (action: UIAlertAction!) in
            let btn = UIButton()
            btn.tag = 7
            self.didTapShareSheetActions(btn)
        }
        actionMoreLike.setValue(UIColor(displayP3Red: 0.138, green: 0.125, blue: 0.292, alpha: 1), forKey: "titleTextColor")
        actionMoreLike.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        let icon7 = imgMoreLike.imageWithSize(scaledToSize: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal)
        actionMoreLike.setValue(icon7, forKey: "image")
        
        
        let actionDontLike = UIAlertAction(title: lblUnLike, style: .default) { (action: UIAlertAction!) in
            let btn = UIButton()
            btn.tag = 8
            self.didTapShareSheetActions(btn)
        }
        actionDontLike.setValue(UIColor(displayP3Red: 0.138, green: 0.125, blue: 0.292, alpha: 1), forKey: "titleTextColor")
        actionDontLike.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        let icon8 = imgUnLike.imageWithSize(scaledToSize: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal)
        actionDontLike.setValue(icon8, forKey: "image")
        
        let actionCopy = UIAlertAction(title: lblCopy, style: .default) { (action: UIAlertAction!) in
            let btn = UIButton()
            btn.tag = 10
            self.didTapShareSheetActions(btn)
        }
        actionCopy.setValue(UIColor(displayP3Red: 0.138, green: 0.125, blue: 0.292, alpha: 1), forKey: "titleTextColor")
        actionCopy.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        let icon10 = imgCopy.imageWithSize(scaledToSize: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysOriginal)
        actionCopy.setValue(icon10, forKey: "image")
        
        
        let actionCaption = UIAlertAction(title: lblCaption, style: .default) { (action: UIAlertAction!) in
            let btn = UIButton()
            btn.tag = 9
            self.didTapShareSheetActions(btn)
        }
        actionCaption.setValue(UIColor(displayP3Red: 0.138, green: 0.125, blue: 0.292, alpha: 1), forKey: "titleTextColor")
        actionCaption.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        let icon9 = imgCaptions.imageWithSize(scaledToSize: CGSize(width: 30, height: 24)).withRenderingMode(.alwaysOriginal)
        actionCaption.setValue(icon9, forKey: "image")
        
        
        if !isReportHidden {
            alertController.addAction(actionReport)
        }
        if !isDislikeHidden {
            alertController.addAction(actionDontLike)
        }
        if !isGoToSourceHidden && isFromReels {
            alertController.addAction(actionGotoSource)
        }
        if !isSavedArticleHidden {
            alertController.addAction(actionSaveArticle)
        }
        if !isShareArticleHidden {
            alertController.addAction(actionShare)
        }
        
//
//        if !viewSavedArticleHidden {
//            alertController.addAction(actionFollow)
//        }
        if !isBlockSourceHidden && (isFromReels || isFromChannel) {
            alertController.addAction(actionBlock)
        }
//
//        if !viewSavedArticleHidden {
//            alertController.addAction(actionMoreLike)
//        }
//
        if !isCopyhidden {
            alertController.addAction(actionCopy)
        }
        
        if isCaptionOptionNeeded {
//            alertController.addAction(actionCaption)
        }
        
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action: UIAlertAction!) in
            
            self.delegateBottomSheet?.didTapUpdateAudioAndProgressStatus()
            self.view.backgroundColor = .clear
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(actionCancel)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
         }
        
    }
    //MARK:- UISwipeGesture Recognizer for down
    @objc func swipeView(_ sender:UISwipeGestureRecognizer) {
        
        if sender.direction == .down {
            
            self.didTapBack(self)
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.viewTbContainer.roundCorners(corners: [.topLeft, .topRight], radius: 20.0)
    }
    
    override func viewWillLayoutSubviews() {
        /*
        if SharedManager.shared.isSelectedLanguageRTL() {
            DispatchQueue.main.async {
            }
            
        } else {
            DispatchQueue.main.async {
            }
        }*/
    }
    
    //MARK:- custom function
    func hasCheckSameAuthorOption() {
        
        if isSameAuthor {
            
            self.isGoToSourceHidden = true
            self.isBlockSourceHidden = false
            self.isFollowSourceHidden = true
            
            if self.share_message == "" {
                
                self.isShareArticleHidden = true
            }
            else {
                
                self.isShareArticleHidden = false
            }

        }
        else {
            
            self.isGoToSourceHidden = false
            self.isBlockSourceHidden = false
            self.isFollowSourceHidden = true
            
            if self.share_message == "" {
                
                self.isShareArticleHidden = true
            }
            else {
                
                self.isShareArticleHidden = false
            }
        }
    }
    
    func setSubmitUI() {
        
        if selectedContent.count == 0 {
            btnSubmit.setTitleColor(Constant.appColor.lightGray, for: .normal)
        }
        else {
            btnSubmit.setTitleColor(Constant.appColor.lightRed, for: .normal)
        }
        
        
    }
    

    @IBAction func didTapBack(_ sender: Any) {
    
        if isFromReels {
            
            self.delegateBottomSheet?.didTapUpdateAudioAndProgressStatus()
            self.view.backgroundColor = .clear
            self.dismiss(animated: true, completion: nil)
        }
        else if self.isReportView {
            
//            self.isReportView = false
//            self.viewTbContainer.isHidden = true
//            UIView.animate(withDuration: 2.0, delay: 0, options: .curveEaseIn, animations: {
//
//                self.tbHeightConstraint.constant = 0
//
//            }) { _ in
//
//            }
            self.delegateBottomSheet?.didTapUpdateAudioAndProgressStatus()
            self.view.backgroundColor = .clear
            self.dismiss(animated: true, completion: nil)
        }
        else {
            
            self.delegateBottomSheet?.didTapUpdateAudioAndProgressStatus()
            self.view.backgroundColor = .clear
//            
//            let transition: CATransition = CATransition()
//            transition.duration = 1.0
//            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//            transition.type = CATransitionType.reveal
//            transition.subtype = CATransitionSubtype.fromBottom
//            self.layer.add(transition, forKey: nil)
//            self.dismiss(animated: false, completion: nil)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapSubmit(_ sender: Any) {
        
        self.performWSToReport()
        
    }
    
    @IBAction func didTapShareSheetActions(_ sender: UIButton) {
        
        if sender.tag == 6 {
            
            //Report content
            if let tbCount = self.articlesList?.count {
                self.isReportView = true
                self.viewTbContainer.isHidden = false
                
                let height = 170 + (56 * tbCount)
                UIView.animate(withDuration: 3.0, delay: 0, options: .curveEaseIn, animations: {
                    
                    self.tbHeightConstraint.constant = CGFloat(height)
                    
                }) { _ in
                    
                }
            }
        }
        else {
            
            self.dismiss(animated: true) {
                self.delegateBottomSheet?.didTapBottomShareSheetAction(sender: sender, article: self.article)
            }
        }
        
    }
}

extension BottomSheetVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 56
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return articlesList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "BottomSheetCC") as! BottomSheetCC

        let article = self.articlesList?[indexPath.row]
        cell.lblTitle.text = article
        
//        if isFromReels {
//            cell.lblTitle.textColor = .white
//        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let article = articlesList?[indexPath.row]
        
        if let cell = tableView.cellForRow(at: indexPath) as? BottomSheetCC {
            
            if self.selectedContent.isEmpty {
                
                self.selectedContent.append(article ?? "")
                cell.imgCheck.image = UIImage(named: MyThemes.current == .dark ? "check" : "checkLight")
            }
            else {
                
                if self.selectedContent.contains(article ?? "") {
                    
                    self.selectedContent.remove(object: article ?? "")
                    cell.imgCheck.image = UIImage(named: "checkmark")
                }
                else {
                    
                    self.selectedContent.append(article ?? "")
                    cell.imgCheck.image = UIImage(named: MyThemes.current == .dark ? "check" : "checkLight")
                }
            }
            setSubmitUI()
        }
    }
}


//MARK: - Webservices
extension BottomSheetVC {
    
    func performWSToGetReportList() {
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("news/articles/\(article.id ?? "")/report/concern", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(articleReportListDC.self, from: response)
            
                if let articles = FULLResponse.concerns {
                
                    self.articlesList = articles
                    self.tableView.reloadData()
                }
                ANLoader.hide()

            } catch let jsonerror {

                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/articles/\(self.article.id ?? "")/report/concern", error: jsonerror.localizedDescription, code: "")

            }
            ANLoader.hide()

        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToReport() {
        
        SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.cfReportclick, eventDescription: "", entity_id: article.id ?? "")
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        if selectedContent.count == 0 {
            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Please select report content", comment: ""))
            return
        }
        
        let params = ["message": self.selectedContent]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        
        var url = ""
        if isOpenForChannelDetails {
            url = "news/sources/\(article.id ?? "")/report/concern"
        }
        else {
            url = "news/articles/\(article.id ?? "")/report/concern"
        }
        
        WebService.URLResponseJSONRequest(url, method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)
                
                if let status = FULLResponse.message?.uppercased() {
                    
                    if status == Constant.STATUS_SUCCESS {
                    
                        self.isReportView = false
                        self.dismiss(animated: true) {
                            
                            self.delegateBottomSheet?.didTapDissmisReportContent()
                        }
                    }
                    else {
                        SharedManager.shared.showAlertView(source: self, title: ApplicationAlertMessages.kAppName, message: status)
                    }
                }
                
            } catch let jsonerror {
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "news/articles/\(self.article.id ?? "")/report/concern", error: jsonerror.localizedDescription, code: "")

            }
        }) { (error) in
            print("error parsing json objects",error)
        }

    }
}
