//
//  SchedulePostListVC.swift
//  Bullet
//
//  Created by Mahesh on 15/06/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AVFoundation

class SchedulePostListVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewSchedule: UIView!
    @IBOutlet weak var lblSchedule: UILabel!

    @IBOutlet weak var tblExtendedView: UITableView!
    //@IBOutlet weak var viewBGColor: UIView!
    
    @IBOutlet weak var viewNoPost: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblContinue: UILabel!
    @IBOutlet weak var viewNextButton: UIView!

    @IBOutlet weak var viewNoDraft: UIView!
    @IBOutlet weak var lblMsgDraft: UILabel!

    //VARAIBLES
    var selectedItems = [YPMediaItem]()
    var articlesArray: [articlesData] = []
    var nextPageData = ""
    var scheduleDate = ""
    var dateTimeString = ""
    var isFromModerator = false
    var selectedChannel: ChannelInfo?
    var isDraftList = false

    var focussedIndexPath = IndexPath(row: 0, section: 0)
    var curVideoVisibleCell: ScheduleVideoCC?
    var curYoutubeVisibleCell: ScheduleYoutubeCC?
    var curReelVisibleCell: ScheduleReelCC?
    var isFirtTimeLoaded = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.setLocalizableString()
        self.setDesignView()
        
        //register cardcell for storyboard use
        tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_SCHEDULE_CARD, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_SCHEDULE_CARD)
        tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_SCHEDULE_YOUTUBE, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_SCHEDULE_YOUTUBE)
        tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_SCHEDULE_REEL, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_SCHEDULE_REEL)
        tblExtendedView.register(UINib(nibName: CELL_IDENTIFIER_SCHEDULE_VIDEO, bundle: nil), forCellReuseIdentifier: CELL_IDENTIFIER_SCHEDULE_VIDEO)

        tblExtendedView.rowHeight = UITableView.automaticDimension
        tblExtendedView.estimatedRowHeight = 600
        tblExtendedView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tblExtendedView.bounds.height - (HEIGHT_HOME_LISTVIEW + 30), right: 0)

        if isDraftList {
            performWSToGetDraftPost(page: "")
        }
        else {
            performWSToGetSchedulePost(page: "")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(appMovedFromBackgroundToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
//        if isFirtTimeLoaded {
//            if isDraftList {
//                performWSToGetDraftPost(page: "")
//            }
//            else {
//                performWSToGetSchedulePost(page: "")
//            }
//        }
        
        isFirtTimeLoaded = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateProgressbarStatus(isPause: true)
        NotificationCenter.default.removeObserver(self)
    }

    
    func setDesignView() {
                
        viewNoDraft.isHidden = true
        viewNoPost.isHidden = true

        view.theme_backgroundColor = GlobalPicker.backgroundColor
        viewSchedule.theme_backgroundColor = GlobalPicker.themeCommonColor
        viewSchedule.isHidden = isDraftList ? true : false

        lblTitle.theme_textColor = GlobalPicker.textColor
        viewNextButton.theme_backgroundColor = GlobalPicker.themeCommonColor
        viewNextButton.cornerRadius = viewNextButton.frame.size.height / 2
        lblContinue.addTextSpacing(spacing: 2)
    }
    
    func setLocalizableString() {
                
        if isDraftList {
            lblTitle.text = NSLocalizedString("DRAFTS", comment: "").capitalized
            lblMsgDraft.text = NSLocalizedString("You don't have any drafts yet.", comment: "")
        }
        else {
            lblTitle.text = NSLocalizedString("Scheduled Posts", comment: "")
        }
        
        lblSchedule.text = NSLocalizedString("Schedule", comment: "")
        
        lblMessage.text = NSLocalizedString("There aren't any scheduled posts yet.", comment: "")
        lblContinue.text = NSLocalizedString("Schedule a Post", comment: "").uppercased()
    }
    
    //MARK:- BUTTON ACTION
    @IBAction func didTapBackButton(_ sender: Any) {
        
        if isFromModerator {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func didTapSchedule(_ sender: Any) {
        
        updateProgressbarStatus(isPause: true)
        
        if SharedManager.shared.isGuestUser && SharedManager.shared.isLinkedUser == false {
                        
            let vc = RegistrationNewVC.instantiate(fromAppStoryboard: .RegistrationSB)
            let navVC = UINavigationController(rootViewController: vc)
            self.navigationController?.present(navVC, animated: true, completion: nil)
        }
        else {
            
            if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails), (user.setup ?? false) {
                
                if SharedManager.shared.community == false {

                    let vc = CommunityGuideVC.instantiate(fromAppStoryboard: .Schedule)
                    vc.delegate = self
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                else {
                    
                    let vc = ScheduleDatePopupVC.instantiate(fromAppStoryboard: .Schedule)
                    vc.delegate = self
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: true)
                }
            }
            else {
                
                let vc = PopupVC.instantiate(fromAppStoryboard: .Home)
                vc.isFromProfileView = true
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}

//MARK:- Web Service
extension SchedulePostListVC {
    
    func performWSToGetDraftPost(page: String) {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        if page == "" {
            ANLoader.showLoading(disableUI: false)
        }
        
        let param = [
            "page": page,
            "status": "draft",
            "source": self.selectedChannel?.id ?? ""
        ]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        WebService.URLResponse("studio/draft", method: .get, parameters: param, headers: token, withSuccess: { [weak self] (response) in
            ANLoader.hide()
            guard let self = self else {
                return
            }
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(articlesDC.self, from: response)
                
                
                if page == "" {
                    self.articlesArray.removeAll()
                }
                if let articlesData = FULLResponse.articles, articlesData.count > 0 {
                    
                    self.viewNoDraft.isHidden = true
                    if self.articlesArray.count == 0 {
                        self.articlesArray = articlesData
                        UIView.performWithoutAnimation {
                            self.tblExtendedView.reloadData()
                            self.tblExtendedView.setContentOffset(.zero, animated: true)
                        }
                        
                    } else {
                        self.articlesArray = self.articlesArray + articlesData
                        UIView.performWithoutAnimation {
                            self.tblExtendedView.reloadData()
                        }
                    }
                    
                } else {
                    if page == "" {
                        self.articlesArray.removeAll()
                        self.viewNoDraft.isHidden = false
                    }
                    print("Empty Result")
                    UIView.performWithoutAnimation {
                        self.tblExtendedView.reloadData()
                    }
                }
                
                // Meta data
                if let next = FULLResponse.meta?.next, next.isEmpty == false {
                    self.nextPageData = next
                } else {
                    self.nextPageData = ""
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "studio/scheduled", error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetSchedulePost(page: String) {

        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        if page == "" {
            ANLoader.showLoading(disableUI: false)
        }
        
        let param = ["page": page,
                     "source": self.selectedChannel?.id ?? ""]
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        WebService.URLResponse("studio/scheduled", method: .get, parameters: param, headers: token, withSuccess: { [weak self] (response) in
            ANLoader.hide()
            guard let self = self else {
                return
            }
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(articlesDC.self, from: response)
                
                if page == "" {
                    self.articlesArray.removeAll()
                }
                
                if let articlesData = FULLResponse.articles, articlesData.count > 0 {
                    
                    self.viewNoPost.isHidden = true
                    if self.articlesArray.count == 0 {
                        self.articlesArray = articlesData
                        UIView.performWithoutAnimation {
                            self.tblExtendedView.reloadData()
                            self.tblExtendedView.setContentOffset(.zero, animated: true)
                        }
                        
                    } else {
                        self.articlesArray = self.articlesArray + articlesData
                        UIView.performWithoutAnimation {
                            self.tblExtendedView.reloadData()
                        }
                    }
                    
                } else {
                    if page == "" {
                        self.articlesArray.removeAll()
                        self.viewNoPost.isHidden = false
                    }
                    print("Empty Result")
                    UIView.performWithoutAnimation {
                        self.tblExtendedView.reloadData()
                    }
                }
                
                // Meta data
                if let next = FULLResponse.meta?.next, next.isEmpty == false {
                    self.nextPageData = next
                } else {
                    self.nextPageData = ""
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "studio/scheduled", error: jsonerror.localizedDescription, code: "")
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToArticlePublished(_ article: articlesData, isDelete: Bool) {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading()
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        let id = article.id ?? ""
        let params = ["status": isDelete ? "UNPUBLISHED" : "PUBLISHED"]
        
        WebService.URLResponse("studio/articles/\(id)/status", method: .patch, parameters: params, headers: token, withSuccess: { (response) in
            
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                SharedManager.shared.showAlertLoader(message: NSLocalizedString(isDelete ? "Article removed successfully" : "Article published successfully", comment: ""), type: .alert)

                if let index = self.articlesArray.firstIndex(where: { $0.id == id }) {
                    self.articlesArray.remove(at: index)
                    
                    if self.articlesArray.count == 0 {
                        
                        if self.isDraftList {
                            self.performWSToGetDraftPost(page: "")
                        }
                        else {
                            self.performWSToGetSchedulePost(page: "")
                        }
                    }
                    else {
                        self.tblExtendedView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        self.tblExtendedView.reloadData()
                    }
                }

            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "studio/articles/id/status", error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
}

//MARK:- TABLE VIEW DELEGATE
extension SchedulePostListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articlesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let content = self.articlesArray[indexPath.row]
        
        if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_VIDEO {

            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            
            let videoPlayer = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_SCHEDULE_VIDEO, for: indexPath) as! ScheduleVideoCC
         //   videoPlayer.delegateVideoView = self
            
            // Set like comment
            videoPlayer.setLikeComment(model: content.info)
            videoPlayer.delegate = self
//            videoPlayer.delegateLikeComment = self
            
            videoPlayer.selectionStyle = .none
            
//            // videoPlayer.btnShare.tag = indexPath.row
//            videoPlayer.btnSource.tag = indexPath.row
            videoPlayer.playButton.tag = indexPath.row
            
//            videoPlayer.btnShare.addTarget(self, action: #selector((button:)), for: .touchUpInside)
//            videoPlayer.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
            
            //LEFT - RIGHT ACTION

            videoPlayer.lblAuthor.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            if let source = content.source?.name?.capitalized {
                videoPlayer.lblSource.text = source
            }
            else {
                videoPlayer.lblSource.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            }

            if let source = content.source {
                videoPlayer.imgWifi?.sd_setImage(with: URL(string: content.source?.icon ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            }
            else {
                videoPlayer.imgWifi?.sd_setImage(with: URL(string: content.authors?.first?.image ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            }

            if let pubDate = content.publish_time {
                videoPlayer.pubDate = pubDate
            }
                        
            videoPlayer.btnPost.tag = indexPath.row
            videoPlayer.btnEdit.tag = indexPath.row
            videoPlayer.btnDelete.tag = indexPath.row
            
            videoPlayer.btnPost.addTarget(self, action: #selector(didTapPost(_:)), for: .touchUpInside)
            videoPlayer.btnEdit.addTarget(self, action: #selector(didTapEdit(_:)), for: .touchUpInside)
            videoPlayer.btnDelete.addTarget(self, action: #selector(didTapDelete(_:)), for: .touchUpInside)
            
            let author = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            let source = content.source?.name ?? ""
            
            if author == source || author == "" {
                videoPlayer.lblAuthor.isHidden = true
                videoPlayer.lblSource.text = source
            }
            else {
                
                videoPlayer.lblSource.text = source
                videoPlayer.lblAuthor.text = author
                
                if source == "" {
                    videoPlayer.lblAuthor.isHidden = true
                    videoPlayer.lblSource.text = author
                }
            }

            videoPlayer.viewLikeCommentBG.isHidden = true
            
            if isDraftList {
                videoPlayer.viewHeaderTimer.isHidden = true
                videoPlayer.ctViewHeaderTimerHeight.constant = 0
                videoPlayer.viewPostArticle.isHidden = true
            }
            else {
                
                if let pubDate = content.publish_time {
                    videoPlayer.pubDate = pubDate
                }
                videoPlayer.viewPostArticle.isHidden = false
                videoPlayer.viewHeaderTimer.isHidden = false
                videoPlayer.ctViewHeaderTimerHeight.constant = 30
            }
            
            videoPlayer.viewOptionPost.isHidden = false
            videoPlayer.ctViewOptionPostHeight.constant = 45

            if self.focussedIndexPath == indexPath {
                self.curVideoVisibleCell = videoPlayer
            }
            
            if let bullets = content.bullets {
                
                videoPlayer.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: self.focussedIndexPath == indexPath ? true : false)
            }
            
            videoPlayer.setNeedsUpdateConstraints()
            videoPlayer.updateConstraintsIfNeeded()
            videoPlayer.setNeedsLayout()
            videoPlayer.layoutIfNeeded()
            
            return videoPlayer
        }
        else if content.type ?? "" == Constant.newsArticle.ARTICLE_TYPE_REEL {

            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            
            let reelCC = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_SCHEDULE_REEL, for: indexPath) as! ScheduleReelCC
            reelCC.delegate = self
            reelCC.selectionStyle = .none
            
//            reelCC.btnShare.tag = indexPath.row
//            reelCC.btnSource.tag = indexPath.row
            reelCC.playButton.tag = indexPath.row
            
//            reelCC.btnShare.addTarget(self, action: #selector((button:)), for: .touchUpInside)
//            reelCC.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
            
            //LEFT - RIGHT ACTION

            reelCC.lblAuthor.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            if let source = content.source?.name?.capitalized {
                reelCC.lblSource.text = source
            }
            else {
                reelCC.lblSource.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            }

            if let source = content.source {
                reelCC.imgWifi?.sd_setImage(with: URL(string: content.source?.icon ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            }
            else {
                reelCC.imgWifi?.sd_setImage(with: URL(string: content.authors?.first?.image ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            }
            
            reelCC.btnPost.tag = indexPath.row
            reelCC.btnEdit.tag = indexPath.row
            reelCC.btnDelete.tag = indexPath.row
            
            reelCC.btnPost.addTarget(self, action: #selector(didTapPost(_:)), for: .touchUpInside)
            reelCC.btnEdit.addTarget(self, action: #selector(didTapEdit(_:)), for: .touchUpInside)
            reelCC.btnDelete.addTarget(self, action: #selector(didTapDelete(_:)), for: .touchUpInside)
            
            let author = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            let source = content.source?.name ?? ""
            
            if author == source || author == "" {
                reelCC.lblAuthor.isHidden = true
                reelCC.lblSource.text = source
            }
            else {
                
                reelCC.lblSource.text = source
                reelCC.lblAuthor.text = author
                
                if source == "" {
                    reelCC.lblAuthor.isHidden = true
                    reelCC.lblSource.text = author
                }
            }

            if isDraftList {
                reelCC.viewHeaderTimer.isHidden = true
                reelCC.ctViewHeaderTimerHeight.constant = 0
                reelCC.viewPostArticle.isHidden = true
            }
            else {
                if let pubDate = content.publish_time {
                    reelCC.pubDate = pubDate
                }
                reelCC.viewPostArticle.isHidden = false
                reelCC.viewHeaderTimer.isHidden = false
                reelCC.ctViewHeaderTimerHeight.constant = 30
            }
            
            reelCC.viewOptionPost.isHidden = false
            reelCC.ctViewOptionPostHeight.constant = 45
            
            if self.focussedIndexPath == indexPath {
                self.curReelVisibleCell = reelCC
            }
            
            if let bullets = content.bullets {
                
                reelCC.setupSlideScrollView(bullets: bullets, article: content, row: indexPath.row, isAutoPlay: self.focussedIndexPath == indexPath ? true : false)
            }
            
            reelCC.setNeedsUpdateConstraints()
            reelCC.updateConstraintsIfNeeded()
            reelCC.setNeedsLayout()
            reelCC.layoutIfNeeded()
            
            return reelCC
        }
        else if content.type?.uppercased() == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
            
            SharedManager.shared.isVolumnOffCard = true
            SharedManager.shared.bulletPlayer?.stop()
            SharedManager.shared.bulletPlayer?.currentTime = 0
            //print("Volume 37")
            
            let youtubeCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_SCHEDULE_YOUTUBE, for: indexPath) as! ScheduleYoutubeCC
            
            //BUTTON ACTIONs
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOpenSourceURL(sender:)))
//            tapGesture.view?.tag = indexPath.row
//            youtubeCell.tag = indexPath.row
//            print("cardCell.viewGestures: ", indexPath.row)
//            youtubeCell.addGestureRecognizer(tapGesture)
            
            // Set like comment
            youtubeCell.setLikeComment(model: content.info)
            
            youtubeCell.langCode = content.language ?? ""
            youtubeCell.delegateYoutubeCardCell = self
//            youtubeCell.delegateLikeComment = self
            youtubeCell.selectionStyle = .none
            
            youtubeCell.url = content.link ?? ""
            youtubeCell.urlThumbnail = content.image ?? ""
            
            
//            youtubeCell.btnShare.tag = indexPath.row
//            youtubeCell.btnSource.tag = indexPath.row
            youtubeCell.btnPlayYoutube.tag = indexPath.row

//            youtubeCell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
//            youtubeCell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
            youtubeCell.btnPlayYoutube.addTarget(self, action: #selector(didTapPlayYoutube(_:)), for: .touchUpInside)

            //LEFT - RIGHT ACTION

            youtubeCell.lblAuthor.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            if let source = content.source?.name?.capitalized {
                youtubeCell.lblSource.text = source
            }
            else {
                youtubeCell.lblSource.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            }

            if let source = content.source {
                youtubeCell.imgWifi?.sd_setImage(with: URL(string: content.source?.icon ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            }
            else {
                youtubeCell.imgWifi?.sd_setImage(with: URL(string: content.authors?.first?.image ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            }
            
            youtubeCell.btnPost.tag = indexPath.row
            youtubeCell.btnEdit.tag = indexPath.row
            youtubeCell.btnDelete.tag = indexPath.row
            
            youtubeCell.btnPost.addTarget(self, action: #selector(didTapPost(_:)), for: .touchUpInside)
            youtubeCell.btnEdit.addTarget(self, action: #selector(didTapEdit(_:)), for: .touchUpInside)
            youtubeCell.btnDelete.addTarget(self, action: #selector(didTapDelete(_:)), for: .touchUpInside)
            
            let author = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            let source = content.source?.name ?? ""
            
            if author == source || author == "" {
                youtubeCell.lblAuthor.isHidden = true
                youtubeCell.lblSource.text = source
            }
            else {
                
                youtubeCell.lblSource.text = source
                youtubeCell.lblAuthor.text = author
                
                if source == "" {
                    youtubeCell.lblAuthor.isHidden = true
                    youtubeCell.lblSource.text = author
                }
            }

            youtubeCell.viewLikeCommentBG.isHidden = true
            if isDraftList {
                youtubeCell.viewHeaderTimer.isHidden = true
                youtubeCell.ctViewHeaderTimerHeight.constant = 0
                youtubeCell.viewPostArticle.isHidden = true
            }
            else {
                
                if let pubDate = content.publish_time {
                    youtubeCell.pubDate = pubDate
                }
                youtubeCell.viewPostArticle.isHidden = false
                youtubeCell.viewHeaderTimer.isHidden = false
                youtubeCell.ctViewHeaderTimerHeight.constant = 30
            }

            youtubeCell.viewOptionPost.isHidden = false
            youtubeCell.ctViewOptionPostHeight.constant = 45
            
            //Selected cell
            if self.focussedIndexPath == indexPath {
                self.curYoutubeVisibleCell = youtubeCell
            }
            
            //setup cell
            if let bullets = content.bullets {
                
                youtubeCell.setupSlideScrollView(bullets: bullets, row: indexPath.row, isAutoPlay: self.focussedIndexPath == indexPath ? true : false)
            }
            
            youtubeCell.setNeedsUpdateConstraints()
            youtubeCell.updateConstraintsIfNeeded()
            youtubeCell.setNeedsLayout()
            youtubeCell.layoutIfNeeded()
            
            return youtubeCell
        }
        else {
            
            //CARD VIEW DESIGN CELL- LARGE CELL
            guard let cardCell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER_SCHEDULE_CARD, for: indexPath) as? ScheduleCardCC else { return UITableViewCell() }
            
            // Set like comment
            cardCell.setLikeComment(model: content.info)
            
            cardCell.backgroundColor = UIColor.clear
            cardCell.setNeedsLayout()
            cardCell.layoutIfNeeded()
            cardCell.selectionStyle = .none
            cardCell.delegateScheduleCard = self
//            cardCell.delegateLikeComment = self
            cardCell.langCode = content.language ?? ""
            
            //LEFT - RIGHT ACTION
            cardCell.btnLeft.theme_tintColor = GlobalPicker.btnCellTintColor
            cardCell.btnRight.theme_tintColor = GlobalPicker.btnCellTintColor
            cardCell.constraintArcHeight.constant = cardCell.viewGestures.frame.size.height - 20
            
            cardCell.btnLeft.accessibilityIdentifier = String(indexPath.row)
            cardCell.btnRight.accessibilityIdentifier = String(indexPath.row)
            cardCell.btnLeft.addTarget(self, action: #selector(didTapScrollLeftRightCard(_:)), for: .touchUpInside)
            cardCell.btnRight.addTarget(self, action: #selector(didTapScrollLeftRightCard(_:)), for: .touchUpInside)
            
            //Image Pre-loading logic
            if articlesArray.count > indexPath.row + 1 {
                
                let preContent = articlesArray[indexPath.row + 1]
                cardCell.imgPreLoaded?.sd_setImage(with: URL(string: preContent.image ?? ""))
            }
            if articlesArray.count > indexPath.row + 2 {
                
                let preContent = articlesArray[indexPath.row + 2]
                cardCell.imgPreLoaded?.sd_setImage(with: URL(string: preContent.image ?? ""))
            }
            
            let url = content.image ?? ""
            cardCell.imgBlurBG?.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            
            cardCell.imgBG.contentMode = .scaleAspectFill
            cardCell.imgBG.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"), completed: { (image, error, cacheType, imageURL) in
                
                if image == nil {
                    
                    cardCell.imgBG.accessibilityIdentifier = "image_placeholder"
                }
                else {
                    
                    cardCell.imgBG.accessibilityIdentifier = ""
                    cardCell.imgBG.contentMode = .scaleAspectFill
                    cardCell.imgBG.image = image
                }
            })
            
            //BUTTON ACTIONs
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOpenSourceURL(sender:)))
//            tapGesture.view?.tag = indexPath.row
//            cardCell.tag = indexPath.row
//            cardCell.viewGestures.addGestureRecognizer(tapGesture)
            
//            cardCell.btnShare.tag = indexPath.row
//            cardCell.btnSource.tag = indexPath.row
//            cardCell.btnShare.addTarget(self, action: #selector(didTapShare(button:)), for: .touchUpInside)
//            cardCell.btnSource.addTarget(self, action: #selector(didTapSource(button:)), for: .touchUpInside)
            

            cardCell.lblAuthor.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            if let source = content.source?.name?.capitalized {
                cardCell.lblSource.text = source
            }
            else {
                cardCell.lblSource.text = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            }

            if let source = content.source {
                cardCell.imgWifi?.sd_setImage(with: URL(string: content.source?.icon ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            }
            else {
                cardCell.imgWifi?.sd_setImage(with: URL(string: content.authors?.first?.image ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            }

            //<---Pan Gestures
            let panLeft = PanDirectionGestureRecognizer(direction: .horizontal(.left), target: self, action: #selector(handlePanGesture(_:)))
            panLeft.view?.tag = indexPath.row
            panLeft.cancelsTouchesInView = false
            cardCell.viewGestures.addGestureRecognizer(panLeft)
            
            let panRight = PanDirectionGestureRecognizer(direction: .horizontal(.right), target: self, action: #selector(handlePanGesture(_:)))
            panRight.view?.tag = indexPath.row
            panRight.cancelsTouchesInView = false
            cardCell.viewGestures.addGestureRecognizer(panRight)
            
            //add UISwipeGestureRecognizer when selected cell is active
            let direction: [UISwipeGestureRecognizer.Direction] = [ .left, .right]
            for dir in direction {
                let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeViewCard(_:)))
                cardCell.viewGestures.addGestureRecognizer(swipeGesture)
                swipeGesture.direction = dir
                swipeGesture.view?.tag = indexPath.row
                cardCell.viewGestures.isUserInteractionEnabled = true
                cardCell.viewGestures.isMultipleTouchEnabled = false
                
                panLeft.require(toFail: swipeGesture)
                panRight.require(toFail: swipeGesture)
            }
            
            cardCell.btnPost.tag = indexPath.row
            cardCell.btnEdit.tag = indexPath.row
            cardCell.btnDelete.tag = indexPath.row
            
            cardCell.btnPost.addTarget(self, action: #selector(didTapPost(_:)), for: .touchUpInside)
            cardCell.btnEdit.addTarget(self, action: #selector(didTapEdit(_:)), for: .touchUpInside)
            cardCell.btnDelete.addTarget(self, action: #selector(didTapDelete(_:)), for: .touchUpInside)
            
            let author = content.authors?.first?.username ?? content.authors?.first?.name ?? ""
            let source = content.source?.name ?? ""
            
            if author == source || author == "" {
                cardCell.lblAuthor.isHidden = true
                cardCell.lblSource.text = source
            }
            else {
                
                cardCell.lblSource.text = source
                cardCell.lblAuthor.text = author
                
                if source == "" {
                    cardCell.lblAuthor.isHidden = true
                    cardCell.lblSource.text = author
                }
            }

            //--->
            cardCell.viewLikeCommentBG.isHidden = true
            if isDraftList {
                
                cardCell.viewHeaderTimer.isHidden = true
                cardCell.ctViewHeaderTimerHeight.constant = 0
                cardCell.viewPostArticle.isHidden = true
            }
            else {
                
                if let pubDate = content.publish_time {
                    cardCell.pubDate = pubDate
                }
                cardCell.viewPostArticle.isHidden = false
                cardCell.viewHeaderTimer.isHidden = false
                cardCell.ctViewHeaderTimerHeight.constant = 30
            }

            cardCell.viewOptionPost.isHidden = false
            cardCell.ctViewOptionPostHeight.constant = 45
            
            cardCell.setupSlideScrollView(article: content, isAudioPlay: self.focussedIndexPath == indexPath ? true : false, row: indexPath.row, isMute: content.mute ?? false)
            
            cardCell.setNeedsUpdateConstraints()
            cardCell.updateConstraintsIfNeeded()
            cardCell.setNeedsLayout()
            cardCell.layoutIfNeeded()
            
            return cardCell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if articlesArray.count > 0 && indexPath.row == articlesArray.count - 1 {  //numberofitem count
            if nextPageData.isEmpty == false {
                
                if isDraftList {
                    performWSToGetDraftPost(page: nextPageData)
                }
                else {
                    performWSToGetSchedulePost(page: nextPageData)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //print("indexPath:...", indexPath.row)
        if let cell = cell as? ScheduleVideoCC {
            cell.resetVisibleVideoPlayer()
        }
        else if let cell = cell as? ScheduleReelCC {
            cell.resetVisibleVideoPlayer()
        }
        else if let cell = cell as? ScheduleYoutubeCC {
            cell.resetYoutubeCard()
        }
    }

    
    @objc func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        
        if let gesture = pan as? PanDirectionGestureRecognizer {
            
            switch gesture.state {
            case .began:
                break
            case .changed:
                break
            case .ended,
                 .cancelled:
                break
            default:
                break
            }
        }
    }
    
    //MARK:- Cell Button Action
    @objc func didTapPost(_ button: UIButton) {
        
        //Post
        let index = button.tag
        let article = self.articlesArray[index]
        self.performWSToArticlePublished(article, isDelete: false)
    }
    
    @objc func didTapEdit(_ button: UIButton) {
                
        //edit
        let index = button.tag
        let content = self.articlesArray[index]

        let vc = PostArticleVC.instantiate(fromAppStoryboard: .Schedule)
        if content.type == Constant.newsArticle.ARTICLE_TYPE_VIDEO {
            vc.postArticleType = .media
            vc.selectedMediaType = .video
        }
        else if content.type == Constant.newsArticle.ARTICLE_TYPE_IMAGE {
            vc.postArticleType = .media
            vc.selectedMediaType = .photo
        }
        else if content.type == Constant.newsArticle.ARTICLE_TYPE_YOUTUBE {
            vc.postArticleType = .youtube
        }
        else if content.type == Constant.newsArticle.ARTICLE_TYPE_REEL {
            vc.postArticleType = .reel
        }
        
        vc.scheduleDate = self.scheduleDate
        vc.dateTimeString = self.dateTimeString
        vc.selectedChannel = self.selectedChannel
        vc.isEditable = true
        vc.yArticle = content
        vc.modalPresentationStyle = .fullScreen
        vc.isOpenFromDrafts = self.isDraftList
        
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapDelete(_ button: UIButton) {
        
        //Delete
        let index = button.tag
        let article = self.articlesArray[index]
        self.performWSToArticlePublished(article, isDelete: true)
    }
    
    @objc func didTapPlayYoutube(_ button: UIButton) {
        
        let index = button.tag
        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? ScheduleYoutubeCC {
            
//            self.curVisibleYoutubeCardCell = cell
            if cell.videoPlayer.ready {
                
                cell.videoPlayer.play()
                //cell.imgPlay.isHidden = true
                cell.activityLoader.startAnimating()
            }
        }
    }
    
    @objc func swipeViewCard(_ sender: UISwipeGestureRecognizer) {
        
//        if UserDefaults.standard.bool(forKey: Constant.UD_isHapticOn) {
//
//            if #available(iOS 13.0, *) {
//                generator = UIImpactFeedbackGenerator(style: .soft)
//            } else {
//
//                generator = UIImpactFeedbackGenerator(style: .heavy)
//            }
//            generator.impactOccurred()
//        }
        
        let row = sender.view?.tag ?? 0
        
        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: row, section: 0)) as? ScheduleCardCC {
            
            let content = self.articlesArray[row]
            if let bullets = content.bullets {
                
                SharedManager.shared.isUserinteractWithHeadlinesOnly = true
                cell.isAutoScrolling = false
                print("print 4...")
                SharedManager.shared.bulletPlayer?.pause()
                SharedManager.shared.bulletPlayer?.stop()
                
                if SharedManager.shared.isSelectedLanguageRTL() {
                    // Arabic
                    if sender.direction == .right {
                        cell.swipeLeftFocusedCell(bullets: bullets)
                    }
                    else if sender.direction == .left {
                        cell.swipeRightFocusedCell(bullets: bullets, tag: 0)
                    }
                } else {
                    if sender.direction == .right {
                        cell.swipeRightFocusedCell(bullets: bullets, tag: 0)
                    }
                    else if sender.direction == .left {
                        cell.swipeLeftFocusedCell(bullets: bullets)
                    }
                }
            }
        }
    }
    
    //MARK:- UISwipeGesture Recognizer for left/right
    @objc func didTapScrollLeftRightCard(_ sender: UIButton) {
        
//        if UserDefaults.standard.bool(forKey: Constant.UD_isHapticOn) {
//
//            if #available(iOS 13.0, *) {
//                generator = UIImpactFeedbackGenerator(style: .soft)
//            } else {
//
//                generator = UIImpactFeedbackGenerator(style: .heavy)
//            }
//            generator.impactOccurred()
//        }
        
        let index = Int(sender.accessibilityIdentifier ?? "0") ?? 0

        if let cell = self.tblExtendedView.cellForRow(at: IndexPath(row: index, section: 0)) as? ScheduleCardCC {
            
            cell.constraintArcHeight.constant = cell.viewGestures.frame.size.height - 20

            //let content = self.articles[index]
            if cell.bullets?.count ?? 0 <= 0 { return }
            
            SharedManager.shared.isManualScrolling = true
                        
            //focus cell
            SharedManager.shared.isUserinteractWithHeadlinesOnly = true
            cell.isAutoScrolling = false
            print("print 6...")
            SharedManager.shared.bulletPlayer?.pause()
            SharedManager.shared.bulletPlayer?.stop()
         
            if sender.tag == 0 {
                
                //LEFT
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: self.articlesArray[index].id ?? "")
                cell.btnLeft.pulsate()
                cell.btnLeft.setImage(UIImage(named: "leftArc"), for: .normal)
                cell.imgPrevious.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    
                    cell.btnLeft.setImage(UIImage(named: ""), for: .normal)
                    cell.imgPrevious.isHidden = true
                }
                
                if cell.currPage > 0 {
                    
                    if cell.currPage < cell.bullets?.count ?? 0 {
                        
                        cell.currPage -= 1
                        SharedManager.shared.segementIndex = cell.currPage
                        cell.scrollToItemBullet(at: cell.currPage, animated: true)
                        cell.playAudio()
                        //SharedManager.shared.spbCardView?.rewind()
                    }
                    else {
                        
                        cell.restartProgressbar()
                    }
                }
                else {
                    
                    cell.restartProgressbar()
                }
            }
            else {
                
                SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.articleSwipeEvent, eventDescription: "", article_id: self.articlesArray[index].id ?? "")
                cell.btnRight.setImage(UIImage(named: "rightArc"), for: .normal)
                cell.btnRight.pulsate()
                cell.imgNext.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    
                    cell.btnRight.setImage(UIImage(named: ""), for: .normal)
                    cell.imgNext.isHidden = true
                }
                
                if cell.currPage < (cell.bullets?.count ?? 0) - 1 {
                    
                    cell.currPage += 1
                    SharedManager.shared.segementIndex = cell.currPage
                    cell.scrollToItemBullet(at: cell.currPage, animated: true)
                    cell.playAudio()
                    //SharedManager.shared.spbCardView?.skip()
                }
                else {
                    
                    //self.restartProgressbar()
//                    
//                    cell.delegateScheduleCard?.autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: true)
                }
            }
        }
    }
}

//MARK:- SCROLL VIEW DELEGATE
extension SchedulePostListVC: UIScrollViewDelegate {
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        updateProgressbarStatus(isPause: true)
        
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        updateProgressbarStatus(isPause: true)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        //ScrollView for ListView Mode
        if decelerate { return }
        updateProgressbarStatus(isPause: false)
        scrollToTopVisibleExtended()
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        //ScrollView for ListView Mode
        updateProgressbarStatus(isPause: false)
        scrollToTopVisibleExtended()
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        scrollView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.994000); //0.998000
    }
    
    func scrollToTopVisibleExtended() {
        
        // set hight light to a new first or center cell
        //SharedManager.shared.clearProgressBar()
        var isVisible = false
        var indexPathVisible:  IndexPath?
        for indexPath in tblExtendedView.indexPathsForVisibleRows ?? [] {
            let cellRect = tblExtendedView.rectForRow(at: indexPath)
            isVisible = tblExtendedView.bounds.contains(cellRect)
            if isVisible {
                //print("indexPath is Visible")
                indexPathVisible = indexPath
                break
            }
        }
        
        if isVisible == false {
            //print("indexPath not Visible")
            let center = self.view.convert(tblExtendedView.center, to: tblExtendedView)
            indexPathVisible = tblExtendedView.indexPathForRow(at: center)
        }
        
//        if indexPathVisible == 0 {
//            // Skip
//            return
//        }
        if let indexPath = indexPathVisible, indexPath != getIndexPathForSelectedArticleCardAndListView() {
            
            //this func tells to set index for visible article focus
            //RESET CURRENT PLAYING CARD CELL WHEN SHOW YOUTUBE
            if let cell = self.getCurrentFocussedCell() as? ScheduleCardCC {
                cell.pauseAudioAndProgress(isPause: true)
                cell.resetVisibleCard()
            }
                        
            //RESET CURRENT PLAYING YOUTUBE CELL
            //Reset Home Youtube View
            if let yCell = self.getCurrentFocussedCell() as? ScheduleYoutubeCC {
                yCell.resetYoutubeCard()
            }
            
            //Reset Home Card View
            if let vCell = self.getCurrentFocussedCell() as? ScheduleVideoCC {
                vCell.resetVisibleVideoPlayer()
            }
            
            //Reset Reel View
            if let vCell = self.getCurrentFocussedCell() as? ScheduleReelCC {
                vCell.resetVisibleVideoPlayer()
            }
            
            self.setupIndexPathForSelectedArticleCardAndListView(indexPath.row, section: indexPath.section)

            //ASSIGN CELL FOR CARD VIEW
            if let cell = tblExtendedView.cellForRow(at: indexPath) as? ScheduleCardCC {
                
                // Play audio only when vc is visible
                if articlesArray.count > 0 {

                    let content = self.articlesArray[indexPath.row]
                    cell.setupSlideScrollView(article: content, isAudioPlay: true, row: indexPath.row, isMute: content.mute ?? true)
                    //print("audio playing")
                } else {
                    //print("audio playing skipped")
                }
            }
            else if let yCell = tblExtendedView.cellForRow(at: indexPath) as? ScheduleYoutubeCC {
                
                self.curYoutubeVisibleCell = yCell
                yCell.setFocussedYoutubeView()
            }
            else if let vCell = tblExtendedView.cellForRow(at: indexPath) as? ScheduleVideoCC {
                
                self.curVideoVisibleCell = vCell
                
                vCell.playVideo(isPause: false)
            }
            else if let rCell = tblExtendedView.cellForRow(at: indexPath) as? ScheduleReelCC {
                
                self.curReelVisibleCell = rCell
                
                rCell.playVideo(isPause: false)
            }
        }
        else {
            
            if let yCell = self.getCurrentFocussedCell() as? ScheduleYoutubeCC {
     
                
                yCell.resetYoutubeCard()
            }
            else {
                if let yCell = self.curYoutubeVisibleCell {
                    
                    
                    yCell.resetYoutubeCard()
                }
            }
        }
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

        return returnCells.sorted()

    }
}

//MARK:- Customs methods
extension SchedulePostListVC {
    
    func resetCurrentProgressBarStatus() {
        
        self.tblExtendedView.contentOffset = .zero

        //RESET EXTENDED VIEW CELL WHEN EXTENDED VIEW VISIBLE
        if let cell = self.getCurrentFocussedCell() as? ScheduleCardCC {
            cell.resetVisibleCard()
        }
        
        //RESET CURRENT PLAYING YOUTUBE CELL
        if let yCell = self.getCurrentFocussedCell() as? ScheduleYoutubeCC {
            yCell.resetYoutubeCard()
        }
        
        //RESET VIDEO VIEW CC
        if let vCell = self.getCurrentFocussedCell() as? ScheduleVideoCC {
            vCell.resetVisibleVideoPlayer()
        }
        
        //RESET VIDEO VIEW CC
        if let rCell = self.getCurrentFocussedCell() as? ScheduleReelCC {
            rCell.resetVisibleVideoPlayer()
        }

    }
    
    func updateProgressbarStatus(isPause: Bool) {
        
        print("print 3...")
        SharedManager.shared.bulletPlayer?.pause()
        
        if isPause {
            
            if let cell = self.tblExtendedView.cellForRow(at: focussedIndexPath) as? ScheduleCardCC {
                
                cell.pauseAudioAndProgress(isPause:true)
                
            }
            else if let cell = self.tblExtendedView.cellForRow(at: focussedIndexPath) as? ScheduleVideoCC {
                
                cell.playVideo(isPause: true)
            }
            else if let cell = self.tblExtendedView.cellForRow(at: focussedIndexPath) as? ScheduleYoutubeCC {
                
                cell.resetYoutubeCard()
            }
            else if let cell = self.tblExtendedView.cellForRow(at: focussedIndexPath) as? ScheduleReelCC {
                
                cell.playVideo(isPause: true)
            }
            
        }
        else {
            
            if let cell = self.tblExtendedView.cellForRow(at: focussedIndexPath) as? ScheduleCardCC {
                
                if let visibleIndex = self.getVisibleIndexPath() {
                    
                    if visibleIndex.row == self.focussedIndexPath.row {
                        if SharedManager.shared.viewSubCategoryIshidden {
                            print("audio playing 1")
                            cell.pauseAudioAndProgress(isPause:false)
                        } else {
                            cell.pauseAudioAndProgress(isPause:true)
                        }
                    }
                }
            }
            else if let cell = self.tblExtendedView.cellForRow(at: focussedIndexPath) as? ScheduleVideoCC {
                
                if SharedManager.shared.viewSubCategoryIshidden {
                    print("audio playing 3")
                    cell.playVideo(isPause: false)
                } else {
                    cell.playVideo(isPause: true)
                }
                
            }
            else if let cell = self.tblExtendedView.cellForRow(at: focussedIndexPath) as? ScheduleYoutubeCC {
                
                if SharedManager.shared.viewSubCategoryIshidden {
                    cell.setFocussedYoutubeView()
                } else {
                    cell.resetYoutubeCard()
                }
                
            }
            else if let cell = self.tblExtendedView.cellForRow(at: focussedIndexPath) as? ScheduleReelCC {
                
                if SharedManager.shared.viewSubCategoryIshidden {
                    print("audio playing 3")
                    cell.playVideo(isPause: false)
                } else {
                    cell.playVideo(isPause: true)
                }
                
            }
        }
    }
    
    func setupIndexPathForSelectedArticleCardAndListView(_ index: Int, section: Int) {
        
        self.focussedIndexPath = IndexPath(row: index, section: section)
    }
    
    func getIndexPathForSelectedArticleCardAndListView() -> IndexPath {
        
        var index = self.focussedIndexPath
        return index
    }
    
    func getCurrentFocussedCell() -> UITableViewCell {
        
        let index = self.getIndexPathForSelectedArticleCardAndListView()
        if let cell = self.tblExtendedView.cellForRow(at: index) {
            return cell
        }

        return UITableViewCell()
    }
    
    func getVisibleIndexPath() -> IndexPath? {
        
        var isVisible = false
        var indexPathVisible: IndexPath?
        for indexPath in tblExtendedView.indexPathsForVisibleRows ?? [] {
            let cellRect = tblExtendedView.rectForRow(at: indexPath)
            isVisible = tblExtendedView.bounds.contains(cellRect)
            if isVisible {
                //print("indexPath is Visible")
                indexPathVisible = indexPath
                break
            }
        }
        if isVisible == false {
            //print("indexPath not Visible")
            let center = self.view.convert(tblExtendedView.center, to: tblExtendedView)
            indexPathVisible = tblExtendedView.indexPathForRow(at: center)
        }
        
        return indexPathVisible
    }

}

//MARK:- Cells Delegate methods
extension SchedulePostListVC: ScheduleCardCCDelegate, ScheduleVideoCCDelegates, ScheduleYoutubeCCDelegate, ScheduleReelCCDelegates {
        
    func didSelectCell(cell: ScheduleVideoCC) {
        
    }
    
    func seteMaxHeightForIndexPathHomeList(cell: UITableViewCell, maxHeight: CGFloat) {
        
        guard let indexPath = tblExtendedView.indexPath(for: cell) else {
            return
        }
//        SharedManager.shared.maxHeightForIndexPath[indexPath] = maxHeight
    }
    
    func focusedIndex(index: Int) {
        
        updateProgressbarStatus(isPause: true)
        
        self.setupIndexPathForSelectedArticleCardAndListView(index, section: 0)

        if let vCell = tblExtendedView.cellForRow(at: self.focussedIndexPath) as? ScheduleVideoCC {
            vCell.playVideo(isPause: true)
        }
        
        if let rCell = tblExtendedView.cellForRow(at: self.focussedIndexPath) as? ScheduleReelCC {
            rCell.playVideo(isPause: true)
        }
    }
 
    func resetSelectedArticle() {
        
        //RESET EXTENDED VIEW CELL WHEN EXTENDED VIEW VISIBLE
        if let cell = self.getCurrentFocussedCell() as? ScheduleCardCC {
            cell.btnVolume.isHidden = true
        }
        
        if let vCell = self.getCurrentFocussedCell() as? ScheduleVideoCC {
            
            vCell.btnVolume.isHidden = true
            vCell.resetVisibleVideoPlayer()
        }
        
        
        if let rCell = self.getCurrentFocussedCell() as? ScheduleReelCC {
            
            rCell.btnVolume.isHidden = true
            rCell.resetVisibleVideoPlayer()
        }
    }

    //ARTICLES SWIPE
    func layoutUpdate() {
        
        self.tblExtendedView.beginUpdates()
        self.tblExtendedView.endUpdates()
    }
    
    //<---
    // Public delegate methods for all cells are here
    func handleLongPressHold(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        let index: IndexPath = self.focussedIndexPath
                
        if let cell = tblExtendedView.cellForRow(at: index) as? ScheduleCardCC {
            
            if gestureRecognizer.state == .began {
                
                cell.pauseAudioAndProgress(isPause: true)
            }
            if gestureRecognizer.state == .ended {
                
                cell.pauseAudioAndProgress(isPause: false)
            }
        }
//        else if let cell = tblExtendedView.cellForRow(at: index) as? HomeListViewCC {
//
//            if gestureRecognizer.state == .began {
//
//                cell.pauseAudioAndProgress(isPause: true)
//            }
//            if gestureRecognizer.state == .ended {
//
//                cell.pauseAudioAndProgress(isPause: false)
//            }
//        }
    }
    
    func autoExtendedCardSwipeWhenHeadlineOnly(isMoveNext: Bool) {
        
        //Check for auto scroll is running when the user changed View Type(Extended to List)
        
        
        //Data always load from first position
        let index = self.focussedIndexPath
        
        //Reset previous view cell audio -- CARD VIEW
        if let cell = self.getCurrentFocussedCell() as? ScheduleCardCC {
            cell.resetVisibleCard()
        }
        else {
            
            if let cell = tblExtendedView.cellForRow(at: index) as? ScheduleCardCC {
                cell.resetVisibleCard()
            }
        }
                
        //RESET CURRENT PLAYING YOUTUBE CELL
        //Reset Home Youtube View
        if let yCell = self.getCurrentFocussedCell() as? ScheduleYoutubeCC {
            yCell.resetYoutubeCard()
        }
        
        //Reset Home Card View
        if let vCell = self.getCurrentFocussedCell() as? ScheduleVideoCC {
            vCell.resetVisibleVideoPlayer()
        }
        
        if let rCell = self.getCurrentFocussedCell() as? ScheduleReelCC {
            rCell.resetVisibleVideoPlayer()
        }
        
        if index.row < self.articlesArray.count && self.articlesArray.count > 1 {
            
            var newIndex = 0
            newIndex = isMoveNext ? index.row + 1 : index.row - 1
            newIndex = newIndex >= self.articlesArray.count ? 0 : newIndex
            let newIndexPath: IndexPath = IndexPath(item: newIndex, section: 0)
            
            UIView.animate(withDuration: 0.3) {
                
                self.tblExtendedView.selectRow(at: newIndexPath, animated: false, scrollPosition: .top)
                //self.tableView.scrollToRow(at: newIndexPath, at: .top, animated: false)
                self.tblExtendedView.layoutIfNeeded()
                
            } completion: { (finished) in
                
                if let cell = self.tblExtendedView.cellForRow(at: newIndexPath) as? ScheduleCardCC {

                    let content = self.articlesArray[newIndexPath.row]
                    cell.setupSlideScrollView(article: content, isAudioPlay: true, row: newIndexPath.row, isMute: content.mute ?? true)

                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.setupIndexPathForSelectedArticleCardAndListView(newIndex, section: 0)
                }
                else if let vCell = self.tblExtendedView.cellForRow(at: newIndexPath) as? ScheduleVideoCC {
                    
                    self.curVideoVisibleCell = vCell
                    vCell.videoControllerStatus(isHidden: true)
                    vCell.playVideo(isPause: false)
                    
                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.setupIndexPathForSelectedArticleCardAndListView(newIndex, section: 0)
                }
                else if let rCell = self.tblExtendedView.cellForRow(at: newIndexPath) as? ScheduleReelCC {
                    
                    self.curReelVisibleCell = rCell
                    rCell.videoControllerStatus(isHidden: true)
                    rCell.playVideo(isPause: false)
                    
                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.setupIndexPathForSelectedArticleCardAndListView(newIndex, section: 0)
                }
                else if let yCell = self.tblExtendedView.cellForRow(at: newIndexPath) as? ScheduleYoutubeCC {
                    
                    self.curYoutubeVisibleCell = yCell
                    yCell.setFocussedYoutubeView()
                    
                    //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
                    self.setupIndexPathForSelectedArticleCardAndListView(newIndex, section: 0)
                }
            }
        }
        else if self.articlesArray.count == 1 {
            
            //ASSIGN NEW INDEX AND RELOAD SELECTED CELL
            self.setupIndexPathForSelectedArticleCardAndListView(0, section: 0)
            self.tblExtendedView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    //--->
}


//MARK:- UploadArticle BottomSheet Delegate
extension SchedulePostListVC: UploadArticleBottomSheetVCDelegate {
    
    func UploadArticleSelectedTypeDelegate(type: Int) {
        
        if type == 0 {
            //Media
            print("Media")
            openMediaPicker(isForReels: false)
            
        }
        else if type == 1 {
            
            //Newsreels
            print("Newsreels")
            openMediaPicker(isForReels: true)
        }
        else {
            
            //Youtube
            print("Youtube")
            let vc = YoutubeArticleVC.instantiate(fromAppStoryboard: .Schedule)
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
}

// MARK : - Youtube Article Delegate
extension SchedulePostListVC: YoutubeArticleVCDelegate {
    
    func submitYoutubeArticlePost(_ article: articlesData) {
        
        if let ptcTBC = tabBarController as? PTCardTabBarController {
            ptcTBC.showTabBar(false, animated: true)
        }
        
        let vc = PostArticleVC.instantiate(fromAppStoryboard: .Schedule)
        vc.selectedChannel = self.selectedChannel
        vc.yArticle = article
        vc.scheduleDate = self.scheduleDate
        vc.dateTimeString = self.dateTimeString
        vc.postArticleType = .youtube
        vc.modalPresentationStyle = .fullScreen
        vc.isOpenFromDrafts = self.isDraftList
        
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK : - Media Picker
extension SchedulePostListVC: YPImagePickerDelegate {
    
    func noPhotos() {}

    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true// indexPath.row != 2
    }
        
    func openMediaPicker(isForReels: Bool) {
        
        var config = YPImagePickerConfiguration()

        /* Uncomment and play around with the configuration 👨‍🔬 🚀 */

        /* Set this to true if you want to force the  library output to be a squared image. Defaults to false */
         config.library.onlySquare = true

        /* Set this to true if you want to force the camera output to be a squared image. Defaults to true */
        // config.onlySquareImagesFromCamera = false

        /* Ex: cappedTo:1024 will make sure images from the library or the camera will be
           resized to fit in a 1024x1024 box. Defaults to original image size. */
        // config.targetImageSize = .cappedTo(size: 1024)

        /* Choose what media types are available in the library. Defaults to `.photo` */
        config.library.mediaType = .photoAndVideo
        config.library.itemOverlayType = .grid
        
        config.libraryPhotoOnly.mediaType = .photo
        config.libraryPhotoOnly.itemOverlayType = .grid
        
        config.libraryVideoOnly.mediaType = .video
        config.libraryVideoOnly.itemOverlayType = .grid
        
        /* Enables selecting the front camera by default, useful for avatars. Defaults to false */
        // config.usesFrontCamera = true

        /* Adds a Filter step in the photo taking process. Defaults to true */
         config.showsPhotoFilters = false

        /* Manage filters by yourself */
        // config.filters = [YPFilter(name: "Mono", coreImageFilterName: "CIPhotoEffectMono"),
        //                   YPFilter(name: "Normal", coreImageFilterName: "")]
        // config.filters.remove(at: 1)
        // config.filters.insert(YPFilter(name: "Blur", coreImageFilterName: "CIBoxBlur"), at: 1)

        /* Enables you to opt out from saving new (or old but filtered) images to the
           user's photo library. Defaults to true. */
        config.shouldSaveNewPicturesToAlbum = false

        /* Choose the videoCompression. Defaults to AVAssetExportPresetHighestQuality */
        config.video.compression = AVAssetExportPresetPassthrough

        /* Choose the recordingSizeLimit. If not setted, then limit is by time. */
        // config.video.recordingSizeLimit = 10000000

        /* Defines the name of the album when saving pictures in the user's photo library.
           In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName" */
         config.albumName = ApplicationAlertMessages.kAppName

        /* Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
           Default value is `.photo` */
        config.startOnScreen = .library

        /* Defines which screens are shown at launch, and their order.
           Default value is `[.library, .photo]` */
        if isForReels {
            config.screens = [.libraryVideoOnly]
        } else {
            config.screens = [.library, .libraryPhotoOnly, .libraryVideoOnly]
        }
        

        /* Can forbid the items with very big height with this property */
        // config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8

        /* Defines the time limit for recording videos.
           Default is 30 seconds. */
        // config.video.recordingTimeLimit = 5.0

        /* Defines the time limit for videos from the library.
           Defaults to 60 seconds. */
        config.video.libraryTimeLimit = 14400

        config.video.libraryTimeLimit = 14400

        config.video.minimumTimeLimit = 1
        
        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
        config.showsCrop = .none//.rectangle(ratio: (16/9))

        /* Defines the overlay view for the camera. Defaults to UIView(). */
        // let overlayView = UIView()
        // overlayView.backgroundColor = .red
        // overlayView.alpha = 0.3
        // config.overlayView = overlayView

        /* Customize wordings */
//        config.wordings.libraryTitle = "Gallery"
//        config.wordings.libraryPhotoTitle = "Photos"
//        config.wordings.libraryVideoTitle = "Videos"
        /* Defines if the status bar should be hidden when showing the picker. Default is true */
        config.hidesStatusBar = false

        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false

        config.maxCameraZoomFactor = 2.0

        config.library.maxNumberOfItems = 1
        config.libraryPhotoOnly.maxNumberOfItems = 1
        config.libraryVideoOnly.maxNumberOfItems = 1
        config.gallery.hidesRemoveButton = false

        /* Disable scroll to change between mode */
        // config.isScrollToChangeModesEnabled = false
        // config.library.minNumberOfItems = 2

        /* Skip selection gallery after multiple selections */
        // config.library.skipSelectionsGallery = true

        /* Here we use a per picker configuration. Configuration is always shared.
           That means than when you create one picker with configuration, than you can create other picker with just
           let picker = YPImagePicker() and the configuration will be the same as the first picker. */

        /* Only show library pictures from the last 3 days */
        //let threDaysTimeInterval: TimeInterval = 3 * 60 * 60 * 24
        //let fromDate = Date().addingTimeInterval(-threDaysTimeInterval)
        //let toDate = Date()
        //let options = PHFetchOptions()
        // options.predicate = NSPredicate(format: "creationDate > %@ && creationDate < %@", fromDate as CVarArg, toDate as CVarArg)
        //
        ////Just a way to set order
        //let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        //options.sortDescriptors = [sortDescriptor]
        //
        //config.library.options = options

//        config.library.preselectedItems = selectedItems
//        config.libraryPhotoOnly.preselectedItems = selectedItems
//        config.libraryVideoOnly.preselectedItems = selectedItems

        // Customise fonts
        //config.fonts.menuItemFont = UIFont.systemFont(ofSize: 22.0, weight: .semibold)
        //config.fonts.pickerTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .black)
        //config.fonts.rightBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .bold)
        //config.fonts.navigationBarTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)
        //config.fonts.leftBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)

        
        config.isForReels = isForReels
        
        
        let picker = YPImagePicker(configuration: config)

        picker.imagePickerDelegate = self

        /* Change configuration directly */
        // YPImagePickerConfiguration.shared.wordings.libraryTitle = "Gallery2"

        /* Multiple media implementation */
        picker.didFinishPicking { [unowned picker] items, cancelled in

            if cancelled {
                print("Picker was canceled")
                picker.dismiss(animated: true, completion: nil)
                return
            }
            _ = items.map { print("🧀 \($0)") }

            self.selectedItems = items
            if let firstItem = items.first {
                switch firstItem {
                case .photo(let photo):
//                    self.selectedImageV.image = photo.image
                    picker.dismiss(animated: true, completion: { [weak self] in
                        //                        self?.present(playerVC, animated: true, completion: nil)
                        //                        print("resolutionForLocalVideo 😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
                        
                        if let ptcTBC = self?.tabBarController as? PTCardTabBarController {
                            ptcTBC.showTabBar(false, animated: true)
                        }
                        
                        let vc = PostArticleVC.instantiate(fromAppStoryboard: .Schedule)
                        vc.selectedChannel = self!.selectedChannel
                        vc.scheduleDate = self!.scheduleDate
                        vc.dateTimeString = self!.dateTimeString
                        vc.imgPhoto = photo.originalImage
                        vc.postArticleType = .media
                        vc.selectedMediaType = .photo
                        vc.modalPresentationStyle = .fullScreen
                        vc.isOpenFromDrafts = self?.isDraftList ?? false
                        
                        vc.delegate = self
                        self?.navigationController?.pushViewController(vc, animated: true)
                    })
                    
                case .video(let video):

                    let assetURL = video.url
                    picker.dismiss(animated: true, completion: { [weak self] in
                        
                        if let ptcTBC = self?.tabBarController as? PTCardTabBarController {
                            ptcTBC.showTabBar(false, animated: true)
                        }
                        
                        let vc = PostArticleVC.instantiate(fromAppStoryboard: .Schedule)
                        vc.videoURL = assetURL
                        vc.scheduleDate = self!.scheduleDate
                        vc.dateTimeString = self!.dateTimeString
                        vc.selectedChannel = self!.selectedChannel
                        
                        vc.imgPhoto = video.thumbnail
                        vc.uploadingFileTaskID = video.taskID ?? ""
                        
                        if isForReels {
                      
                            vc.postArticleType = .reel
                        }
                        else {
                            vc.postArticleType = .media
                            vc.selectedMediaType = .video
                        }
                        vc.modalPresentationStyle = .fullScreen
                        vc.isOpenFromDrafts = self?.isDraftList ?? false
                        
                        vc.delegate = self
                        self?.navigationController?.pushViewController(vc, animated: true)

                    })
                }
            }
        }

        /* Single Photo implementation. */
        // picker.didFinishPicking { [unowned picker] items, _ in
        //     self.selectedItems = items
        //     self.selectedImageV.image = items.singlePhoto?.image
        //     picker.dismiss(animated: true, completion: nil)
        // }

        /* Single Video implementation. */
        //picker.didFinishPicking { [unowned picker] items, cancelled in
        //    if cancelled { picker.dismiss(animated: true, completion: nil); return }
        //
        //    self.selectedItems = items
        //    self.selectedImageV.image = items.singleVideo?.thumbnail
        //
        //    let assetURL = items.singleVideo!.url
        //    let playerVC = AVPlayerViewController()
        //    let player = AVPlayer(playerItem: AVPlayerItem(url:assetURL))
        //    playerVC.player = player
        //
        //    picker.dismiss(animated: true, completion: { [weak self] in
        //        self?.present(playerVC, animated: true, completion: nil)
        //        print("😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
        //    })
        //}

        present(picker, animated: true, completion: nil)
    }
}

//MARK:- Schedule Date/Time PopupVC Delegate
extension SchedulePostListVC: ScheduleDatePopupVCDelegate {
    
    func dismissScheduleDateTimeSelected(dateTime: String, localDate: String) {
        
        scheduleDate = localDate
        dateTimeString = dateTime

        let vc = UploadArticleBottomSheetVC.instantiate(fromAppStoryboard: .Schedule)
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
}

//MARK:- CommunityGuideVC Delegate
extension SchedulePostListVC: CommunityGuideVCDelegate {
    
    func dimissCommunityGuideApprovedDelegate() {
        
        SharedManager.shared.performWSToCommunityGuide()

        if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails), (user.setup ?? false) {
            
            let vc = ScheduleDatePopupVC.instantiate(fromAppStoryboard: .Schedule)
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
        else {
            
            let vc = PopupVC.instantiate(fromAppStoryboard: .Home)
            vc.isFromProfileView = true
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }

    }
}

//MARK:- PopupVC Delegate
extension SchedulePostListVC: PopupVCDelegate {
    
    func popupVCDismissed() {

        let vc = EditProfileVC.instantiate(fromAppStoryboard: .Main)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}


extension SchedulePostListVC: PostArticleVCDelegate {
    
    
    func backButtonPressed() {
        
    }
    
    
    func updatedItemForDrafts() {
        
        if isDraftList {
            performWSToGetDraftPost(page: "")
        }
        else {
            performWSToGetSchedulePost(page: "")
        }
        
    }
}
