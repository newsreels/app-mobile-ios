//
//  PostArticleVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 29/11/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import PlayerKit
import AVFoundation
import Alamofire
import TagListView


protocol PostArticleVCDelegate: class {
    
    func backButtonPressed()
    func updatedItemForDrafts()
}

class PostArticleVC: UIViewController {

    //NAV
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNext: UILabel!
    @IBOutlet weak var viewNext: UIView!
    
    //Video
    @IBOutlet weak var viewVideoBG: UIView!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblVideoTime: UILabel!
    @IBOutlet weak var viewDuration: UIView!
    @IBOutlet weak var imgVideoThumnail: UIImageView!
    
    //Youtube
    @IBOutlet weak var viewYoutubeBG: UIView!
    @IBOutlet weak var youtubePlayer: YouTubePlayerView!
    @IBOutlet weak var viewPlaceholder: UIView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var imgYoutubePlay: UIImageView!
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var lblYoutubeDuration: UILabel!
    
    //Image
    @IBOutlet weak var viewImageBG: UIView!
    @IBOutlet weak var imgArticle: UIImageView!
    
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblProfileName: UILabel!
    
    @IBOutlet weak var viewHeadline: UIView!
    @IBOutlet weak var lblHeadline: UILabel!
    @IBOutlet weak var txtHeadline: UITextView!
    @IBOutlet weak var lblCharacter: UILabel!
    
    //Tag
    @IBOutlet weak var viewTagsBG: UIView!
    @IBOutlet weak var lblTags: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var imgTag: UIImageView!
    
    //Place
    @IBOutlet weak var viewPlacesBG: UIView!
    @IBOutlet weak var lblPlaces: UILabel!
    @IBOutlet weak var placeListView: TagListView!
    @IBOutlet weak var imgPlace: UIImageView!
    
    //location
    @IBOutlet weak var viewLanguageBG: UIView!
    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var imgLanguage: UIImageView!

    //source
    @IBOutlet weak var viewSource: UIView!
    @IBOutlet weak var imgSource: UIImageView!
    @IBOutlet weak var txtSourceName: UITextField!
    
    @IBOutlet weak var viewBullet1: UIView!
    @IBOutlet weak var lblBullet1: UILabel!

    @IBOutlet weak var viewBullet2: UIView!
    @IBOutlet weak var lblBullet2: UILabel!

    @IBOutlet weak var viewBullet3: UIView!
    @IBOutlet weak var lblBullet3: UILabel!

    @IBOutlet weak var viewBullet4: UIView!
    @IBOutlet weak var lblBullet4: UILabel!

    @IBOutlet weak var viewBullet5: UIView!
    @IBOutlet weak var lblBullet5: UILabel!

    @IBOutlet weak var viewBullet6: UIView!
    @IBOutlet weak var lblBullet6: UILabel!

    @IBOutlet weak var viewAddBullet: UIView!
    @IBOutlet weak var lblAddBullet: UILabel!
    
    @IBOutlet var viewCollection: [UIView]!
    @IBOutlet weak var viewStackBullets: UIStackView!
    
    @IBOutlet weak var lblReplace1: UILabel!
    @IBOutlet weak var lblReplace2: UILabel!

    //Schedule Post
    @IBOutlet weak var viewScheduleBG: UIView!
    @IBOutlet weak var lblSchedulePost: UILabel!
    
    //View Progress Container
    @IBOutlet var viewProgressContainer: UIView!
    @IBOutlet weak var viewCircularProgressBG: UIView!
    @IBOutlet weak var viewCircularProgress: CircularProgress!
    @IBOutlet weak var lblProgressStatus: UILabel!
    @IBOutlet weak var lblProgressName: UILabel!
    
    @IBOutlet weak var plaYButtonImage: UIImageView!
    
    
    var selectedItems = [YPMediaItem]()
    var player = RegularPlayer()

    var postArticleType = PostArticleType.media
    var selectedMediaType: mediaType!

    var localURL: URL!
    var videoURL: URL!
    var imgPhoto: UIImage?
    let dictBullet = ["data": "" as AnyObject, "image": "" as AnyObject]
    var noOfBullets = 0
    var Headlinetitle = ""
    var source = ""
    var link = ""
    var bullets = [[String: AnyObject]]()
    var imageURL = ""
    var scheduleDate = ""
    var dateTimeString = ""

    var isScheduleRequired = true
    var isEditable = false
    var yArticle: articlesData?
    var isOpenFromDrafts = false
    
    var url: String = "" {
        didSet {
            youtubePlayer.playerVars = [
                "playsinline": "1",
                "controls": "1",
                "rel" : "0",
                "cc_load_policy" : "0",
                "disablekb": "1",
                "modestbranding": "1"
                ] as YouTubePlayerView.YouTubePlayerParameters
            youtubePlayer.delegate = self
            youtubePlayer.loadVideoID(url)
        }
    }
    
    var urlThumbnail: String = "" {
        didSet {
            
            imgThumbnail.sd_setImage(with: URL(string: urlThumbnail), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
        }
    }
    
    var fName = ""
    var lName = ""
    var selectedChannel: ChannelInfo?

    var uploadingFileTaskID = ""
    weak var delegate: PostArticleVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setProgressRing()
        self.setDesignView()
        self.setupLocalization()

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = true
                
        noOfBullets = 2
        bullets = [dictBullet, dictBullet]

        if postArticleType == .media {
            
            //media
            self.viewYoutubeBG.isHidden = true
            if selectedMediaType == .photo {
                
                //image
                self.viewVideoBG.isHidden = true
                self.viewImageBG.isHidden = false

                viewSource.isHidden = false
                viewStackBullets.isHidden = false
                
                self.setImageArticle()
            }
            else {
                
                //video
                viewVideoBG.isHidden = false
                viewImageBG.isHidden = true

                viewSource.isHidden = true
                viewStackBullets.isHidden = true
                self.setupVideo()
            }
        }
        else if postArticleType == .reel {
            
            //newsreels
            self.viewVideoBG.isHidden = false
            self.viewImageBG.isHidden = true
            self.viewYoutubeBG.isHidden = true
            
            viewSource.isHidden = false
            viewStackBullets.isHidden = true
            self.setupVideo()
        }
        else if postArticleType == .youtube {

            //Youtube
            self.viewVideoBG.isHidden = true
            self.viewImageBG.isHidden = true
            self.viewYoutubeBG.isHidden = false
            viewSource.isHidden = true
            viewStackBullets.isHidden = true
            
            setupYoutube()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        DispatchQueue.main.async {
            if SharedManager.shared.isSelectedLanguageRTL() {
                self.txtHeadline.semanticContentAttribute = .forceRightToLeft
                self.txtHeadline.textAlignment = .right
            } else {
                self.txtHeadline.semanticContentAttribute = .forceLeftToRight
                self.txtHeadline.textAlignment = .left
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
                
        super.viewWillAppear(animated)
           
        UploadManager.shared.editingPostTaskID = self.uploadingFileTaskID
        UploadManager.shared.editingArticle = yArticle
        
        if self.isEditable {
            
            if postArticleType == .reel {
                
                viewTagsBG.isHidden = true
                viewPlacesBG.isHidden = true
                viewLanguageBG.isHidden = true
            }
            else {
                
                //Get language for article
                viewLanguageBG.isHidden = false
                let code = self.yArticle?.language ?? ""
                lblLanguage.text = "\(NSLocalizedString("Language", comment: "")): \(code)"
                if let languages = SharedManager.shared.loadJsonLanguages(filename: "languages") {
                        
                    if let lang = languages.first(where: { $0.code == code }) {
                        lblLanguage.text = "\(NSLocalizedString("Language", comment: "")): \(lang.name ?? "")"
                    }
                }

                self.performWSToGetTagsList(articleId: self.yArticle?.id ?? "")
                self.performWSToGetLocationsList(articleId: self.yArticle?.id ?? "")
            }
        }
        else {
            
            viewTagsBG.isHidden = true
            viewPlacesBG.isHidden = true
            viewLanguageBG.isHidden = true
        }
        
        imgProfile.cornerRadius = imgProfile.frame.height / 2
        imgProfile.contentMode = .scaleAspectFill

        //Tells us to while user edit(Draft/Schdeule List) from specific Channel Details
        if selectedChannel != nil {
            didSelectChannel(channel: selectedChannel)
        }
        else {
            
            if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails) {
                
                let profile = user.profile_image ?? ""

                fName = (user.first_name ?? "")
                lName = (user.last_name ?? "")
                
                if profile.isEmpty {
                    imgProfile.theme_image = GlobalPicker.imgUserPlaceholder
                }
                else {
                    imgProfile.sd_setImage(with: URL(string: profile), placeholderImage: nil)
                }
                            
                let fullName = (user.first_name ?? "") + " " + (user.last_name ?? "")
                lblProfileName.text = fullName.trim()

            }
            else {
                
                imgProfile.theme_image = GlobalPicker.imgUserPlaceholder
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        ANLoader.hide()
        stopAllVideosPlaying()
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        UploadManager.shared.editingPostTaskID = ""
        UploadManager.shared.editingArticle = nil
    }
    
    func stopAllVideosPlaying() {
        //Video View is showing
        if viewVideoBG.isHidden == false {
            self.player.pause()
        }
        else if viewYoutubeBG.isHidden == false {
            self.youtubePlayer.pause()
        }
    }
    
    func setDesignView() {
        
        self.view.theme_backgroundColor = GlobalPicker.backgroundColor
//        self.view.backgroundColor = MyThemes.current == .dark ? UIColor.black : "#F7F7F7".hexStringToUIColor()
        
        lblTitle.theme_textColor = GlobalPicker.textBWColor
        lblProfileName.theme_textColor = GlobalPicker.textBWColor
        imgBack.theme_image = GlobalPicker.imgBack
        viewNext.theme_backgroundColor = GlobalPicker.themeCommonColor
        imgTag.theme_image = GlobalPicker.imgPostTopic
        imgPlace.theme_image = GlobalPicker.imgPostPlace
        imgLanguage.theme_image = GlobalPicker.imgPostLanguage

        viewCollection.forEach { view in
            view.theme_backgroundColor = GlobalPicker.viewBGPostArticleColor
            //view.backgroundColor = MyThemes.current == .dark ? "#090909".hexStringToUIColor() : UIColor.white
        }
        viewPlacesBG.theme_backgroundColor = GlobalPicker.viewBGPostArticleColor
        viewLanguageBG.theme_backgroundColor = GlobalPicker.viewBGPostArticleColor

        txtSourceName.theme_textColor = GlobalPicker.textColor
        txtSourceName.theme_tintColor = GlobalPicker.textColor

        if isEditable {
            txtHeadline.theme_textColor = GlobalPicker.textColor
            txtHeadline.theme_tintColor = GlobalPicker.textColor
        }
        else {
            txtHeadline.textColor = "#67676B".hexStringToUIColor()
            txtHeadline.tintColor = "#67676B".hexStringToUIColor()
        }
        
        lblBullet1.textColor = "#67676B".hexStringToUIColor()
        lblBullet2.textColor = "#67676B".hexStringToUIColor()
        lblBullet3.textColor = "#67676B".hexStringToUIColor()
        lblBullet4.textColor = "#67676B".hexStringToUIColor()
        lblBullet5.textColor = "#67676B".hexStringToUIColor()
//        lblBullet6.textColor = "#67676B".hexStringToUIColor()
        
        viewBullet1.isHidden = false
        viewBullet2.isHidden = false
        viewBullet3.isHidden = true
        viewBullet4.isHidden = true
        viewBullet5.isHidden = true
//        viewBullet6.isHidden = true

        [tagListView, placeListView].forEach { view in
            view?.textColor = MyThemes.current == .dark ? "#FFFFFF".hexStringToUIColor() : "#3D485F".hexStringToUIColor()
            view?.tagBackgroundColor = MyThemes.current == .dark ? "#404040".hexStringToUIColor() : "#F1F1F1".hexStringToUIColor()
            view?.textFont = UIFont(name: Constant.FONT_Mulli_Semibold, size: 14) ?? UIFont.systemFont(ofSize: 14)
        }
    }
    
    func setupLocalization() {
        
        lblReplace1.text = NSLocalizedString("Replace", comment: "")
        lblReplace2.text = NSLocalizedString("Replace", comment: "")
        lblReplace1.textDropShadow()
        lblReplace2.textDropShadow()
        
        if isEditable {
            
            let type = self.yArticle?.status ?? ""
            if type == Constant.newsArticle.ARTICLE_STATUS_SCHEDULED {
                
                scheduleDate = self.yArticle?.publish_time ?? ""
                
                if let selectedDate = SharedManager.shared.utcToLocal(dateStr: scheduleDate) {
                    let selYear = selectedDate.get(.year)
                    let curYear = Date().get(.year)
                    if curYear != selYear {
                        lblSchedulePost.text = "\(selectedDate.dateString("EE, MMM dd, yyyy")) \(selectedDate.dateString("hh:mm a"))"
                    }
                    else {
                        lblSchedulePost.text = "\(selectedDate.dateString("EE, MMM dd")) \(selectedDate.dateString("hh:mm a"))"
                    }
                }
                else {
                    lblSchedulePost.text =  NSLocalizedString("Schedule Post", comment: "")
                }
            }
            else {
                
                if isScheduleRequired {
                    
                    lblSchedulePost.text =  NSLocalizedString("Schedule Post", comment: "")
                    viewScheduleBG.isHidden = false
                }
                else {
                    lblSchedulePost.text = ""
                    viewScheduleBG.isHidden = true
                }
            }
        }
        else {
            
            if scheduleDate == "" {
                lblSchedulePost.text =  NSLocalizedString("Schedule Post", comment: "")
            }
            else {
                lblSchedulePost.text = dateTimeString
            }
        }
        lblTags.text = NSLocalizedString("Topics", comment: "") + ":"
        lblPlaces.text = NSLocalizedString("Places", comment: "") + ":"

        if self.postArticleType == .reel {
            
            //newsreels
            lblTitle.text = NSLocalizedString(self.isEditable ? "Edit Newsreels" : "Newsreels", comment: "")
            lblNext.text = NSLocalizedString(self.isEditable ? "SAVE" : "NEXT", comment: "")
        }
        else {
            
            //media
            lblTitle.text = NSLocalizedString(self.isEditable ? "Edit article" : "Post article", comment: "")
            lblNext.text = NSLocalizedString(self.isEditable ? "SAVE" : "NEXT", comment: "")
            
            if isOpenFromDrafts {
                lblNext.text = NSLocalizedString("NEXT", comment: "")
            }
        }
        lblNext.addTextSpacing(spacing: 2.0)
        
        if postArticleType == .reel {
            lblCharacter.text = "0/150"

            lblHeadline.text = NSLocalizedString("Caption", comment: "")
            txtHeadline.text = NSLocalizedString("Create a Caption", comment: "")
        }
        else {
            lblCharacter.text = "0/100"

            lblHeadline.text = NSLocalizedString("Headline", comment: "")
            txtHeadline.text = NSLocalizedString("Create a headline", comment: "")
        }
        txtSourceName.placeholder = NSLocalizedString("Add Source Link (Optional)", comment: "")
        
        lblBullet1.text = NSLocalizedString("Add Bullet 1", comment: "")
        lblBullet2.text = NSLocalizedString("Add Bullet 2", comment: "")
        lblBullet3.text = NSLocalizedString("Add Bullet 3 (Optional)", comment: "")
        lblBullet4.text = NSLocalizedString("Add Bullet 4 (Optional)", comment: "")
        lblBullet5.text = NSLocalizedString("Add Bullet 5 (Optional)", comment: "")
//        lblBullet6.text = NSLocalizedString("Add Bullet 6 (Optional)", comment: "")

        lblAddBullet.text = "+ " + NSLocalizedString("Add Bullet", comment: "")
    }
    
    func setProgressRing() {
        
        viewProgressContainer.frame = view.frame
        view.addSubview(viewProgressContainer)
        viewProgressContainer.isHidden = true
        
        //progres ring
        self.view.layoutIfNeeded()
        viewCircularProgress.progressColor = "#E01335".hexStringToUIColor()
        viewCircularProgress.trackColor = "#4D0E19".hexStringToUIColor()
        viewCircularProgress.trackWidth = 8
        viewCircularProgress.progressWidth = 8
        //viewCircularProgress.tag = 101
        viewCircularProgress.center = self.viewCircularProgressBG.center
        lblProgressStatus.text = "0%"
        lblProgressStatus.textColor = .white
        
        lblProgressName.text = NSLocalizedString("Uploading video...", comment: "")
        lblProgressName.textColor = .white
    }
    
    func setImageArticle() {
        
        //editable of article is not working yet need to finished task for delete and edit
        
        if self.isEditable {
            
            imgArticle.sd_setImage(with: URL(string: yArticle?.image ?? ""), placeholderImage: UIImage(named: MyThemes.current == .dark ? "icn_placeholder_dark" :"icn_placeholder_light"))
            
            txtSourceName.text = yArticle?.link ?? ""
            
            noOfBullets = max(0, (self.yArticle?.bullets?.count ?? 0) - 1)
            
            if var bullets = self.yArticle?.bullets {
                                    
                Headlinetitle = bullets.first?.data ?? ""
                txtHeadline.text = self.Headlinetitle
                lblCharacter.text = "\(self.Headlinetitle.count)/100"
                bullets.remove(at: 0)
                
                for (index, bullet) in bullets.enumerated() {
                    
                    let titleAttr: [NSAttributedString.Key: Any] = [.foregroundColor: "#67676B".hexStringToUIColor(), .font: UIFont(name: Constant.FONT_Mulli_Semibold, size: 12)!]
                    let bulletAttr: [NSAttributedString.Key: Any] = [.foregroundColor: MyThemes.current == .dark ? UIColor.white : UIColor.black, .font: UIFont(name: Constant.FONT_Mulli_Semibold, size: 16)!]
                    
                    let attr1 = NSMutableAttributedString(string: NSLocalizedString("Bullet", comment: "") + " \(index + 1)\n", attributes: titleAttr)
                    let attr2 = NSMutableAttributedString(string: bullet.data ?? "", attributes: bulletAttr)
                    attr1.append(attr2)
                    
//                    if index == 0 {
//
//                        self.Headlinetitle = bullet.data ?? ""
//                        self.txtHeadline.text = self.Headlinetitle
//                        lblCharacter.text = "\(self.Headlinetitle.count)/100"
//                    }
                    if index == 0 {
                        
                        viewBullet1.isHidden = false
                        lblBullet1.attributedText = attr1
                    }
                    else if index == 1 {
                        
                        viewBullet2.isHidden = false
                        lblBullet2.attributedText = attr1
                        
                    }
                    else if index == 2 {
                        
                        viewBullet3.isHidden = false
                        lblBullet3.attributedText = attr1
                        
                    }
                    else if index == 3 {
                        
                        viewBullet4.isHidden = false
                        lblBullet4.attributedText = attr1
                        
                    }
                    else if index == 4 {
                        
                        viewBullet5.isHidden = false
                        lblBullet5.attributedText = attr1
                        viewAddBullet.isHidden = true
                        
                    }
//                    else if index == 5 {
//
//                        lblBullet6.attributedText = attr1
//                        self.viewBullet6.isHidden = false
//                        self.viewAddBullet.isHidden = true
//                    }
                    
                    //Check existing index
                    let isIndexValid = self.bullets.indices.contains(index)
                    if isIndexValid {
                        self.bullets[index] = (["data": bullet.data as AnyObject, "image": bullet.image as AnyObject])
                    }
                    else {
                        self.bullets.append(["data": bullet.data as AnyObject, "image": bullet.image as AnyObject])
                    }
                }
            }
        }
        else {
            self.imgArticle.image = imgPhoto
        }
    }
    
    func setupVideo() {
                    
        if self.uploadingFileTaskID != "" {
            
            viewVideo.isHidden = true
            imgVideoThumnail.image = imgPhoto
            plaYButtonImage.isHidden = false
            
        } else {
            
            viewVideo.isHidden = false
            imgVideoThumnail.image = imgPhoto
            plaYButtonImage.isHidden = true
            
            
            self.player.pause()
            self.player.seek(to: 0)
            self.player.delegate = self
            //self.addPlayerToView()
            player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            player.view.frame = self.viewVideo.frame
            player.fillMode = .fit
            self.viewVideo.insertSubview(player.view, at: 0)
            
            if self.isEditable {
                
                self.videoURL = URL(string: self.yArticle?.link ?? "")
                self.Headlinetitle = self.yArticle?.title ?? ""
                self.txtHeadline.text = self.Headlinetitle
                
                lblCharacter.text = (self.yArticle?.type ?? "") == Constant.newsArticle.ARTICLE_TYPE_REEL ? "\(self.Headlinetitle.count)/150" : "\(self.Headlinetitle.count)/100"
            }
            
            
            
            if videoURL != nil {
                self.player.set(AVURLAsset(url: videoURL))
            }
            
    //        self.btnVolume.isHidden = true
    //        if SharedManager.shared.isAudioEnable == false {
    //
    //            player.volume = 0
    //            btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
    //        }
    //        else {
    //
    //            player.volume = 1
    //            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
    //        }
    //
    //        self.btnVolume.isHidden = false
            
            player.volume = 1
            self.slider.value = 0
            player.seek(to: .zero)
            
            videoControllerStatus(isHidden: false)
        }
        
    }
    
    func setupYoutube() {
        
        self.activityLoader.stopAnimating()
        self.link = self.yArticle?.link ?? ""
        self.url = self.yArticle?.link ?? ""
        self.urlThumbnail = yArticle?.bullets?.first?.image ?? ""
        
        self.Headlinetitle = self.yArticle?.title ?? ""
        self.txtHeadline.text = self.Headlinetitle
        lblCharacter.text = "\(self.Headlinetitle.count)/100"
        
        lblYoutubeDuration.text = yArticle?.bullets?.first?.duration?.formatFromMilliseconds()
    }
    
    //MARK:- BUTTON ACTION
    @IBAction func didTapSchedulePost(_ sender: Any) {

        //print("Youtube")
        let vc = ScheduleDatePopupVC.instantiate(fromAppStoryboard: .Schedule)
        vc.delegate = self
        let date = self.lblSchedulePost.text?.trim() ?? ""
        if !date.isEmpty && date != NSLocalizedString("Schedule Post", comment: "") {
            vc.selectDateString = self.scheduleDate
        }
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func didTapUploadAction(_ sender: Any) {
        
        if postArticleType != .youtube {
            openMediaPicker()
        }
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        
        UploadManager.shared.clearUncompletedItems()
        self.delegate?.backButtonPressed()
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func didTapAddTag(_ sender: Any) {
        
        let vc = AddTagVC.instantiate(fromAppStoryboard: .Schedule)
        vc.article = self.yArticle
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapAddPlaces(_ sender: Any) {
        
        let vc = AddPlacesVC.instantiate(fromAppStoryboard: .Schedule)
        vc.article = self.yArticle
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapAddLanguage(_ sender: Any) {
  
        let vc = AppLanguageVC.instantiate(fromAppStoryboard: .Onboarding)
        vc.isFromPostArticle = true
        vc.delegateVC = self
        vc.article = self.yArticle
        vc.modalPresentationStyle = .overFullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    @IBAction func didTapAddBullet(_ sender: Any) {
        
        if noOfBullets == 2 {
            self.lblBullet3.text = NSLocalizedString("Add Bullet 3 (Optional)", comment: "")
            self.viewBullet3.isHidden = false
            bullets.append(dictBullet)
        }
        else if noOfBullets == 3 {
            self.lblBullet4.text = NSLocalizedString("Add Bullet 4 (Optional)", comment: "")
            self.viewBullet4.isHidden = false
            bullets.append(dictBullet)
        }
        else if noOfBullets == 4 {
            self.lblBullet5.text = NSLocalizedString("Add Bullet 5 (Optional)", comment: "")
            self.viewBullet5.isHidden = false
            self.viewAddBullet.isHidden = true
            bullets.append(dictBullet)
        }
//        else if noOfBullets == 5 {
//            self.lblBullet6.text = NSLocalizedString("Add Bullet 6", comment: "")
//            self.viewBullet6.isHidden = false
//            self.viewAddBullet.isHidden = true
//            bullets.append(dictBullet)
//        }
        noOfBullets += 1
        
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        
        stopAllVideosPlaying()
        
        self.view.endEditing(true)
        self.Headlinetitle = (self.txtHeadline.text ?? "").trim()
        self.source = (self.txtSourceName.text ?? "").trim()
        let bullet1 = (self.lblBullet1.text ?? "").trim()
        let bullet2 = (self.lblBullet2.text ?? "").trim()
        
        if self.postArticleType == .reel {
            
            if (self.txtHeadline.text == NSLocalizedString("Create a Caption", comment: "")) || self.Headlinetitle.isEmpty {
                
                //SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Enter a Caption", comment: "")
                SharedManager.shared.showAlertLoader(message: NSLocalizedString("Please add your reel caption", comment: ""))

                return
            }
        }
        else {
            
            if (self.txtHeadline.text == NSLocalizedString("Create a headline", comment: "")) || self.Headlinetitle.isEmpty {
                
                //SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Enter article headline", comment: ""))
                SharedManager.shared.showAlertLoader(message: NSLocalizedString("Please add your article headline", comment: ""))
                return
            }
        }
        
//        else if self.source.isEmpty {
//
//            SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Enter source name", comment: ""))
//        }
        
        if self.postArticleType == .media {
                            
            if selectedMediaType == .photo {
                
                //image
                if (self.lblBullet1.text == NSLocalizedString("Add Bullet 1", comment: "") || bullet1.isEmpty) {
                    
                    //SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Enter Bullet 1", comment: ""))
                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Please add bullet 1", comment: ""))
                    return
                }
                
                if (self.lblBullet2.text == NSLocalizedString("Add Bullet 2", comment: "") || bullet2.isEmpty) {
                    
                    //SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Enter Bullet 2", comment: ""))
                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Please add bullet 2", comment: ""))
                    return
                }
                
//                if !(self.source.isValidUrl()) && !(self.source.isEmpty) {
//
//                    SharedManager.shared.showAlertView(source: self, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString("Enter valid link", comment: ""))
//                    return
//                }
                
//                if self.isEditable {
//                    self.performWSToPreviewArticle()
//                }
//                else {
//                if !(self.imageURL.isEmpty) {
//                    self.performWSToUploadImage()
//                }
                self.performWSToUploadImage()
//                }
            }
            else {
                
                //video
                if self.isEditable {
                    
                    if self.videoURL == self.localURL {
//                        self.performWSToUploadVideo()
                        
                        self.performWSToPreviewArticle()
                    }
                    else {
                        self.performWSToPreviewArticle()
                    }
                }
                else {
//                    self.performWSToUploadVideo()
                    self.performWSToPreviewArticle()
                }
                
            }
        }
        else if self.postArticleType == .reel {
            
            //newsreels
            if self.isEditable {
                
                if self.videoURL == self.localURL {
//                    self.performWSToUploadVideo()
                    self.performWSToPreviewReel()
                }
                else {
                    self.performWSToPreviewReel()
                }
            }
            else {
//                self.performWSToUploadVideo()
                self.performWSToPreviewReel()
            }
        }
        else if self.postArticleType == .youtube {

            //youtube
            self.performWSToPreviewArticle()
        }
    }
    
    @IBAction func didTapBullets(_ sender: UIButton) {
        
        let vc = AddBulletVC.instantiate(fromAppStoryboard: .Schedule)
        vc.noOfBullet = sender.tag
        vc.isEditable = self.isEditable
        if let data = self.bullets[sender.tag]["data"] as? String {
            vc.stBullet = data
        }
        if let url = self.bullets[sender.tag]["image"] as? String {
            vc.imageURL = url
        }
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapPlayVideo(_ sender: UIButton) {
        
        
        if self.uploadingFileTaskID != "" {
            if let firstIndex = UploadManager.shared.arrayUploads.firstIndex(where: {$0.taskId == uploadingFileTaskID}) {
                
                if postArticleType != .reel {
                    let videoCropVC = VideoCropperViewController.instantiate(fromAppStoryboard: .Home)
                    videoCropVC.inputVideo  = YPMediaVideo(thumbnail: imgThumbnail.image, videoURL: UploadManager.shared.arrayUploads[firstIndex].assetURL, taskID: self.uploadingFileTaskID)

                    videoCropVC.isOpenForPreview = true
                    videoCropVC.selectedUploadItem = UploadManager.shared.arrayUploads[firstIndex]
                    videoCropVC.modalPresentationStyle = .fullScreen
                    self.present(videoCropVC, animated: true, completion: nil)
                } else {
                    
                    let reelsCropVC = ReelsCropperViewController.instantiate(fromAppStoryboard: .Home)
                    reelsCropVC.inputVideo  = YPMediaVideo(thumbnail: imgThumbnail.image, videoURL: UploadManager.shared.arrayUploads[firstIndex].assetURL, taskID: self.uploadingFileTaskID)

                    reelsCropVC.isOpenForPreview = true
                    reelsCropVC.selectedUploadItem = UploadManager.shared.arrayUploads[firstIndex]
                    reelsCropVC.modalPresentationStyle = .fullScreen
                    self.present(reelsCropVC, animated: true, completion: nil)
                    
                }
                
            }
        } else {
            
            
            plaYButtonImage.isHidden = true
            
            if self.viewDuration.isHidden  {
                
                if self.player.playing {
                    
                    self.videoControllerStatus(isHidden: false)
                }
                else {
                    
                    self.imgPlay.image = UIImage(named: "youtubePlay_Icon")
                    //self.imgPlay.isHidden = false
    //                self.btnVolume.isHidden = false
                    self.slider.isHidden = false
                    //self.lblVideoTime.isHidden = false
                    self.viewDuration.isHidden = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    
                    if self.player.playing {
                        
                        self.videoControllerStatus(isHidden: true)
                    }
                }
            }
            else {
                
                if player.duration == player.time {
                    
                    self.slider.value = 0
                    player.seek(to: .zero)
                    player.play()
                    
                    if self.player.playing {
                        
                        self.videoControllerStatus(isHidden: true)
                    }
                }
                else {
                    
                    if self.player.playing {
                        
                        self.playVideo(isPause: true)
                        self.imgPlay.image = UIImage(named: "youtubePlay_Icon")
                    }
                    else {
                        
                        
                        self.playVideo(isPause: false)
                        self.imgPlay.image = UIImage(named: "videoPause")

                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {

                            self.videoControllerStatus(isHidden: true)
                        }
                        
                    }
                }
            }
            
            
        }
        
    }
    
    func playVideo(isPause: Bool) {
        
//        self.btnVolume.isHidden = false
//        if SharedManager.shared.isAudioEnable == false {
//
//            player.volume = 0
//            btnVolume.setImage(UIImage(named: "volumeOffHomeVC"), for: .normal)
//        }
//        else {
//
//            player.volume = 1
//            btnVolume.setImage(UIImage(named: "volumeOnHomeVC"), for: .normal)
//        }
        
        if isPause {
            
            player.pause()
        }
        else {
            
            self.videoControllerStatus(isHidden: true)
            player.play()
        }
    }
    
    @IBAction func didTapPlayYoutube(_ button: UIButton) {
                
        if self.youtubePlayer.ready {
            
            self.youtubePlayer.play()
            self.imgPlay.isHidden = true
            self.activityLoader.startAnimating()
        }
    }
    
    @IBAction func didTapSelectProfile(_ sender: Any) {
        
        let vc = ProfileSelectionVC.instantiate(fromAppStoryboard: .Schedule)
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
}

extension PostArticleVC: AppLanguageVCDelegate {
    
    func setLanguageForArticle(langName: String) {
        
        lblLanguage.text = "\(NSLocalizedString("Language", comment: "")): \(langName)"
    }
}

extension PostArticleVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView == txtHeadline {
        
            if postArticleType == .reel {
                textView.text = textView.text == NSLocalizedString("Create a Caption", comment: "") ? nil : textView.text
            }
            else {
                textView.text = textView.text == NSLocalizedString("Create a headline", comment: "") ? nil : textView.text
            }
            textView.theme_textColor = GlobalPicker.textColor
            textView.theme_tintColor = GlobalPicker.textColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
                    
        if textView.text.isEmpty {
            
            if textView == self.txtHeadline {
                
                if postArticleType == .reel {
                    lblCharacter.text = "0/150"
                    textView.text = NSLocalizedString("Create a Caption", comment: "")
                }
                else {
                    lblCharacter.text = "0/100"
                    textView.text = NSLocalizedString("Create a headline", comment: "")
                }
                textView.textColor = "#67676B".hexStringToUIColor()
                textView.tintColor = "#67676B".hexStringToUIColor()
            }
        }

    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView == self.txtHeadline {
            
            self.updateCharacterCount()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if textView == self.txtHeadline {
            
            return textView.text.count +  (text.count - range.length) <= (postArticleType == .reel || (self.yArticle?.type ?? "") == Constant.newsArticle.ARTICLE_TYPE_REEL ? 150 : 100)
        }
        return false
    }
    
    private func updateCharacterCount() {
        
        let descriptionCount = self.txtHeadline.text.count
        if txtHeadline.text == NSLocalizedString("Create a headline", comment: "") || txtHeadline.text == NSLocalizedString("Create a Caption", comment: "") {
            
            self.lblCharacter.text = postArticleType == .reel || (self.yArticle?.type ?? "") == Constant.newsArticle.ARTICLE_TYPE_REEL ? "0/150" : "0/100"
        }
        else {
            
            //self.lblCharacter.text = "\((0) + descriptionCount)/100"
            self.lblCharacter.text = postArticleType == .reel || (self.yArticle?.type ?? "") == Constant.newsArticle.ARTICLE_TYPE_REEL ? "\((0) + descriptionCount)/150" : "\((0) + descriptionCount)/100"
        }
    }
}

//====================================================================================================
// MARK:- Web Service To Post Article
//====================================================================================================
extension PostArticleVC {
    
    func performWSToUploadVideo() {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        self.viewProgressContainer.isHidden = false
        DispatchQueue.main.async {
            self.lblProgressStatus.text = "0%"
            self.viewProgressContainer.isHidden = false
        }
        
        //        do {
        //            let resources = try videoURL.resourceValues(forKeys: [.fileSizeKey])
        //            let fileSize = resources.fileSize!
        //            print ("fileSize: \(fileSize)")
        //        } catch {
        //            print("Error: \(error)")
        //        }
        
        let params = ["video": videoURL.absoluteString] as [String : Any]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let completeUrl : String = WebserviceManager.shared.API_BASE + "media/videos"
        
        var headersToken = HTTPHeaders()
        headersToken = [
            "Authorization": "Bearer \(token)"
        ]
        headersToken["x-app-platform"] = "ios"
        headersToken["x-app-version"] = Bundle.main.releaseVersionNumberPretty
        headersToken["api-version"] = WebserviceManager.shared.API_VERSION
        headersToken["X-User-Timezone"] = TimeZone.current.identifier
        
        var prevProgress: Float = 0
        
        DispatchQueue.main.async {
            
            AF.upload(multipartFormData: { (multipartFormData) in
                
                for item in params {
                    
                    if let url = URL(string:item.value as! String) {
                        
                        do {
                            let videoData = try Data(contentsOf: url)
                            multipartFormData.append(videoData, withName: item.key, fileName: "video.mp4", mimeType: "video/mp4")
                        } catch {
                            debugPrint("Error Couldn't get Data from URL: \(url): \(error)")
                        }
                    }
                }
                
            }, to: URL(string: completeUrl)!, usingThreshold: UInt64.init(), method: .post, headers: headersToken, fileManager: FileManager.default)
            
            .uploadProgress { progress in // main queue by default
                print("Upload Progress: \(progress.fractionCompleted)")
                //print("Upload Estimated Time Remaining: \(String(describing: progress.estimatedTimeRemaining))")
                //print("Upload Total Unit count: \(progress.totalUnitCount)")
                //print("Upload Completed Unit Count: \(progress.completedUnitCount)")
                
                let percent = Int(progress.fractionCompleted * 100)
                self.viewCircularProgress.setProgressWithAnimation(duration: 0.1, fromValue: prevProgress, toValue: Float(progress.fractionCompleted))
                prevProgress = Float(progress.fractionCompleted)
                
                self.lblProgressStatus.text = "\(percent)%"

            }
            
            .responseJSON { (response) in
                
                //print("Parameters: \(self.parameters.description)")   // original url request
                //print("Response: \(String(describing: response.response))") // http url response
                //print("Result: \(response.result)")                         // response serialization result
                if let responseData = response.data, let utf8Text = String(data: responseData, encoding: .utf8) {
                    print("String Data: \(utf8Text)")
                    
                    do{
                        
                        let FULLResponse = try
                            JSONDecoder().decode(UploadSuccessDC.self, from: responseData)
                        
                        self.viewProgressContainer.isHidden = true
                        if FULLResponse.success == true {
                            
                            self.imageURL = FULLResponse.key ?? ""
                            if self.postArticleType == .reel {
                                self.performWSToPreviewReel()
//                                self.didTapBackButton(UIButton())
                            }
                            else {
                                self.performWSToPreviewArticle()
                            }
                        }
                        else {
                            SharedManager.shared.logAPIError(url: completeUrl, error: "respone failed", code: "\(response.response?.statusCode ?? 0)")
                            SharedManager.shared.showAlertLoader(message: NSLocalizedString("Oops! Something went wrong. Please try again.", comment: ""))
                        }
                        
                    } catch let jsonerror {
                        SharedManager.shared.logAPIError(url: completeUrl, error: "json parse error", code: "\(response.response?.statusCode ?? 0)")
                        self.viewProgressContainer.isHidden = true
                        ANLoader.hide()
                        print("error parsing json objects", jsonerror)
                    }
                }
                else {
                    self.viewProgressContainer.isHidden = true
                    SharedManager.shared.logAPIError(url: completeUrl, error: response.error?.localizedDescription ?? "", code: "\(response.response?.statusCode ?? 0)")
                    print(response.error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    func performWSToUploadImage() {
        
        if !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
                
        ANLoader.showLoading()
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        var dicSelectedImages = [String: UIImage]()
        dicSelectedImages["image"] = self.imgArticle.image
        
        WebService.URLRequestBodyParams("media/images", method: .post, parameters: nil, headers: token, ImageDic: dicSelectedImages) { (response) in
            do{
                
                let FULLResponse = try
                    JSONDecoder().decode(UploadSuccessDC.self, from: response)
                
                if FULLResponse.success == true {
                    
                    self.imageURL = FULLResponse.results ?? ""
                    self.performWSToPreviewArticle()
                }
                
                ANLoader.hide()
            } catch let jsonerror {
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "media/images", error: jsonerror.localizedDescription, code: "")
            }
        } withAPIFailure: { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
            SharedManager.shared.logAPIError(url: "media/images", error: error, code: "")
        }
    }
    
    func performWSToPreviewReel() {

        if !(SharedManager.shared.isConnectedToNetwork()){

            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }

        ANLoader.showLoading()
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        let id = self.isEditable ? self.yArticle?.id ?? "" : ""
        
        //newsreels
        let params = ["description": self.Headlinetitle,
                      "media": self.imageURL,
                      "source": selectedChannel?.id ?? "",
                      "link": self.source,
                      "id": id,
                      "scheduled_at": scheduleDate,
                      "status": "DRAFT"] as [String : Any]


        WebService.URLResponseJSONRequest("studio/reels", method: .post, parameters: params, headers: token) { (response) in
            do{

                let FULLResponse = try
                    JSONDecoder().decode(reelDC.self, from: response)

                ANLoader.hide()
                
                if self.isEditable && self.isOpenFromDrafts == false {
                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Reels edited successfully.", comment: ""))
                    self.delegate?.updatedItemForDrafts()
                    self.navigationController?.popToRootViewController(animated: true)
                }
                else {
                    
//                    SharedManager.shared.showAlertLoader(message: NSLocalizedString("Reels uploaded successfully.", comment: ""))
//                    self.didTapBackButton(UIButton())
                    
                    
                    
                    if let reel = FULLResponse.reel {
                        
                        UploadManager.shared.updatePostIDForTask(taskID: self.uploadingFileTaskID, postID: reel.id ?? "", sourceID: self.selectedChannel?.id ?? "")
                        UploadManager.shared.updatePostUploadStatus(taskID: self.uploadingFileTaskID, updateUserStatus: .drafted)
                        
                        let bullet = [Bullets(data: reel.description, audio: nil, duration: nil, image: nil)]
                        let article = articlesData(id: reel.id, title: reel.description, media: reel.media, image: reel.image, link: reel.media, color: nil, publish_time: reel.publish_time, source: reel.source, bullets: bullet, topics: nil, status: reel.status, mute: nil, type: Constant.newsArticle.ARTICLE_TYPE_REEL, meta: nil, info: reel.info, authors: reel.authors, media_meta: reel.media_meta)
                        
//                        let vc = PreviewPostArticleVC.instantiate(fromAppStoryboard: .Schedule)
//                        vc.postArticleType = .reel
//                        vc.articles = [article]
//                        vc.modalPresentationStyle = .fullScreen
//                        self.navigationController?.pushViewController(vc, animated: true)
                        
                        let vc = PreviewPostArticleVC.instantiate(fromAppStoryboard: .Schedule)
                        vc.postArticleType = self.postArticleType
                        vc.scheduleDate = self.scheduleDate
                        vc.articles = [article]
                        vc.paramsFromPostArticle = params
                        vc.articleIDFromPostArticle = article.id ?? ""
                        vc.selectedChannelFromPost = self.selectedChannel
                        vc.thumbnailImage = self.imgVideoThumnail.image
                        vc.modalPresentationStyle = .fullScreen
                        vc.uploadingFileTaskID = self.uploadingFileTaskID
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    }
                    else {
                        
                        if let error = FULLResponse.errors?.source {
                            SharedManager.shared.showAlertLoader(message: error)
                        }
                        else if let error = FULLResponse.errors?.link {
                            SharedManager.shared.showAlertLoader(message: error)
                        }
                        else {
                            if let message = FULLResponse.message {
                                SharedManager.shared.showAlertLoader(message: message)
                            }
                        }
                    }
                }

            } catch let jsonerror {
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: "studio/reels", error: jsonerror.localizedDescription, code: "")
            }
        } withAPIFailure: { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
            SharedManager.shared.logAPIError(url: "studio/reels", error: error, code: "")
        }
    }
    
    func performWSToPreviewArticle() {
        
        if !(SharedManager.shared.isConnectedToNetwork()) {
            
            SharedManager.shared.showAlertLoader(message: ApplicationAlertMessages.kMsgInternetNotAvailable, type: .error)
            return
        }
        
        ANLoader.showLoading()
        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        var params = [String: Any]()
        var query = ""
        let id = self.isEditable ? self.yArticle?.id ?? "" : ""
        
        //tell to reload profile  article when user is edit
        SharedManager.shared.isReloadProfileArticle = self.isEditable ? true : false
        
        if self.postArticleType == .media {
            
            if selectedMediaType == .photo {
                
                if isOpenFromDrafts {
                    
                } else if self.isEditable {
                    self.imageURL = self.yArticle?.image ?? ""
                } else {
                    // Draftss and others
                }

                //Filter Empty Bullets
                var tempBullets = [[String: AnyObject]]()
                for bul in self.bullets {
                    if let value = bul["data"] as? String {
                        if !value.isEmpty {
                            tempBullets.append(bul)
                        }
                    }
                }
                self.bullets = tempBullets

                params = ["title": self.Headlinetitle,
                          "image": self.imageURL,
                          "link": self.source,
                          "source": selectedChannel?.id ?? "",
                          "bullets": self.bullets,
                          "id": id,
                          "scheduled_at": scheduleDate] as [String : Any]
                
                query = "studio/articles/image"
            }
            else {
                
                //video
                params = ["title": self.Headlinetitle,
                          "video": self.imageURL,
                          "category_id": "",
                          "source": selectedChannel?.id ?? "",
                          "id": id,
                          "scheduled_at": scheduleDate] as [String : Any]
                
                query = "studio/articles/video"
            }
        }
        else if self.postArticleType == .youtube {
            
            //youtube
            params = ["headline": self.Headlinetitle,
                      "youtube_id": link,
                      "source": selectedChannel?.id ?? "",
                      "id": self.yArticle?.id ?? "",
                      "scheduled_at": scheduleDate] as [String : Any]
            
            query = "studio/articles/youtube"
        }

        WebService.URLResponseJSONRequest(query, method: .post, parameters: params, headers: token) { (response) in
            
            do{
                
                let FULLResponse = try
                    JSONDecoder().decode(postArticlesDC.self, from: response)
                
                ANLoader.hide()
                
                if self.isEditable && self.isOpenFromDrafts == false {
                    
                    if let msg = FULLResponse.message {
                        
                        SharedManager.shared.showAlertLoader(message: msg)
                    }
                    else {
                        SharedManager.shared.showAlertLoader(message: NSLocalizedString("Article edited successfully.", comment: ""))
                    }
                    self.delegate?.updatedItemForDrafts()
                    self.navigationController?.popToRootViewController(animated: true)
                }
                else {
                    
                    if let article = FULLResponse.article {
                        
                        UploadManager.shared.updatePostIDForTask(taskID: self.uploadingFileTaskID, postID: article.id ?? "", sourceID: self.selectedChannel?.id ?? "")
                        UploadManager.shared.updatePostUploadStatus(taskID: self.uploadingFileTaskID, updateUserStatus: .drafted)
                        
                        
                        let vc = PreviewPostArticleVC.instantiate(fromAppStoryboard: .Schedule)
                        vc.postArticleType = self.postArticleType
                        vc.scheduleDate = self.scheduleDate
                        vc.articles = [article]
                        vc.queryFromPostArticle  = query
                        vc.paramsFromPostArticle = params
                        vc.articleIDFromPostArticle = article.id ?? ""
                        vc.selectedChannelFromPost = self.selectedChannel
                        vc.thumbnailImage = self.imgVideoThumnail.image
                        vc.modalPresentationStyle = .fullScreen
                        vc.uploadingFileTaskID = self.uploadingFileTaskID
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                        
                    }
                    else {
                        
                        if let error = FULLResponse.errors?.source {
                            SharedManager.shared.showAlertLoader(message: error)
                        }
                        else if let error = FULLResponse.errors?.link {
                            SharedManager.shared.showAlertLoader(message: error)
                        }
                        else {
                            if let message = FULLResponse.message {
                                SharedManager.shared.showAlertLoader(message: message)
                            }
                        }
                    }
                }

            } catch let jsonerror {
                ANLoader.hide()
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: query, error: jsonerror.localizedDescription, code: "")
            }
            
        } withAPIFailure: { (error) in
            ANLoader.hide()
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetTagsList(articleId: String) {

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let apiUrl : String = "studio/\(articleId)/tags"
        WebService.URLResponse(apiUrl, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(TagsDC.self, from: response)
                
                if let tagsList = FULLResponse.tags {
                              
                    self.tagListView.removeAllTags()
                    self.viewTagsBG.isHidden = false

                    if tagsList.count > 0 {
                        for tag in tagsList {
                           
                            self.tagListView.addTag(tag.name ?? "")
                        }
//                        self.viewTagBG.isHidden = true
//                        self.viewSelectedTagBG.isHidden = false
                    }
                    else {
                        
//                        self.viewTagBG.isHidden = false
//                        self.viewSelectedTagBG.isHidden = true
                    }
                }
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: apiUrl, error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func performWSToGetLocationsList(articleId: String) {

        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        let apiUrl : String = "studio/\(articleId)/locations"
        WebService.URLResponse(apiUrl, method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(locationsDC.self, from: response)
                
                if let list = FULLResponse.locations {
                              
                    self.placeListView.removeAllTags()
                    self.viewPlacesBG.isHidden = false

                    if list.count > 0 {
                        for tag in list {
                           
                            self.placeListView.addTag(tag.name ?? "")
                        }
//                        self.viewTagBG.isHidden = true
//                        self.viewSelectedTagBG.isHidden = false
                    }
                    else {
                        
//                        self.viewTagBG.isHidden = false
//                        self.viewSelectedTagBG.isHidden = true
                    }
                }
            } catch let jsonerror {
                
                print("error parsing json objects",jsonerror)
                SharedManager.shared.logAPIError(url: apiUrl, error: jsonerror.localizedDescription, code: "")
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
}

//MARK:- ADD BULLETS DELEGATE
extension PostArticleVC: AddBulletVCDelegate {
    
    func setBulletOnDismissAction(_ bulletNo: Int, bullet: [String : AnyObject]?, isDeleted: Bool) {
        
        let titleAttr: [NSAttributedString.Key: Any] = [.foregroundColor: "#67676B".hexStringToUIColor(), .font: UIFont(name: Constant.FONT_Mulli_Semibold, size: 12)!]
        let bulletAttr: [NSAttributedString.Key: Any] = [.foregroundColor: MyThemes.current == .dark ? UIColor.white : UIColor.black, .font: UIFont(name: Constant.FONT_Mulli_Semibold, size: 16)!]

        if !isDeleted {
            
            //Add
            if let bul = bullet {
                
                let attr1 = NSMutableAttributedString(string: NSLocalizedString("Bullet", comment: "") + " \(bulletNo + 1)\n", attributes: titleAttr)
                let attr2 = NSMutableAttributedString(string: bul["data"] as! String, attributes: bulletAttr)
                attr1.append(attr2)
                
                let isIndexValid = self.bullets.indices.contains(bulletNo)
                if isIndexValid {
                    self.bullets[bulletNo] = bul
                }
                else {
                    self.bullets.append(bul)
                }
                
                if bulletNo == 0 {
                    lblBullet1.attributedText = attr1
                }
                else if bulletNo == 1 {
                    lblBullet2.attributedText = attr1
                }
                else if bulletNo == 2 {
                    lblBullet3.attributedText = attr1
                }
                else if bulletNo == 3 {
                    lblBullet4.attributedText = attr1
                }
                else if bulletNo == 4 {
                    lblBullet5.attributedText = attr1
                }
//                else if bulletNo == 5 {
//                    lblBullet6.attributedText = attr1
//                }
            }
        }
        else {
            
            //Delete
            self.viewBullet1.isHidden = true
            self.viewBullet2.isHidden = true
            self.viewBullet3.isHidden = true
            self.viewBullet4.isHidden = true
            self.viewBullet5.isHidden = true
//            self.viewBullet6.isHidden = true
            
            let isIndexValid = self.bullets.indices.contains(bulletNo)
            if isIndexValid {
                self.bullets.remove(at: bulletNo)
            }
            
            noOfBullets = self.bullets.count
            self.viewAddBullet.isHidden = false
            
            for (index, bullet) in bullets.enumerated() {
                                
                let attr1 = NSMutableAttributedString(string: NSLocalizedString("Bullet", comment: "") + " \(index + 1)\n", attributes: titleAttr)
                let attr2 = NSMutableAttributedString(string: bullet["data"] as! String, attributes: bulletAttr)
                attr1.append(attr2)

                if index == 0 {
                    
                    self.viewBullet1.isHidden = false
                    lblBullet1.attributedText = attr1
                }
                else if index == 1 {
                    
                    self.viewBullet2.isHidden = false
                    lblBullet2.attributedText = attr1
                    
                }
                else if index == 2 {
                    
                    self.viewBullet3.isHidden = false
                    lblBullet3.attributedText = attr1
                    
                }
                else if index == 3 {
                    
                    self.viewBullet4.isHidden = false
                    lblBullet4.attributedText = attr1
                    
                }
                else if index == 4 {
                    
                    self.viewBullet5.isHidden = false
                    lblBullet5.attributedText = attr1
                    self.viewAddBullet.isHidden = true
                }
//                else if index == 5 {
//
//                    lblBullet6.attributedText = attr1
//                    self.viewBullet6.isHidden = false
//                    self.viewAddBullet.isHidden = true
//                }
                
            }
        }
        
    }
}

//MARK:- PlayerDelegate
extension PostArticleVC: PlayerDelegate {
    
    // MARK: VideoPlayerDelegate
    func playerDidUpdateState(player: Player, previousState: PlayerState) {
        self.activityIndicator.isHidden = true
        
        switch player.state {
        case .loading:
            
            self.activityIndicator.isHidden = false
            
        case .ready:
            self.lblVideoTime.text = "\(player.duration.stringFromTimeInterval())"
            break
            
        case .failed:
            
            NSLog("🚫 \(String(describing: player.error))")
        }
    }
    
    func playerDidUpdatePlaying(player: Player) {
        
        imgThumbnail.isHidden = true
        self.playButton.isSelected = player.playing
    }
    
    func playerDidUpdateTime(player: Player) {
        guard player.duration > 0 else {
            return
        }
        
        let ratio = player.time / player.duration
        
        if self.slider.isHighlighted == false {
            
            UIView.animate(withDuration: 0.3) {
                
                self.lblVideoTime.text = "\(player.time.stringFromTimeInterval()) / \(player.duration.stringFromTimeInterval()) "
                self.slider.value = Float(ratio)
            }
        }
        
        if player.duration == player.time {
            
            self.videoControllerStatus(isHidden: false)
        }
    }
    
    func playerDidUpdateBufferedTime(player: Player) {
        guard player.duration > 0 else {
            return
        }
        //   let ratio = Int((player.bufferedTime / player.duration) * 100)
        //self.label.text = "Buffer: \(ratio)%"
    }
    
    func videoControllerStatus(isHidden:Bool) {
        
        if isHidden {
            
            self.imgPlay.image = UIImage(named: "videoPause")
            //self.imgPlay.isHidden = true
            self.slider.isHidden = true
            //self.lblVideoTime.isHidden = true
            self.viewDuration.isHidden = true
        }
        else {
            
            if player.time == 0 {
                
                self.imgPlay.image = UIImage(named: "youtubePlay_Icon")
            }
            else {
                
                self.imgPlay.image = UIImage(named: "videoPause")
            }
            //self.imgPlay.isHidden = false
            self.slider.isHidden = false
            //self.lblVideoTime.isHidden = false
            self.viewDuration.isHidden = false
        }
    }
}

extension PostArticleVC: YouTubePlayerDelegate {
    
    func playerUpdateCurrentTime(_ videoPlayer: YouTubePlayerView, time: String) {
    }
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        
        print("\(#function)")
        //self.imgThumbnail.isHidden = true
        
//        videoPlayer.getDuration(completion: { (duration) in
//            //self.lblDuration.text = "\(String(describing: duration))"
//            //print("getDuration", String(describing: duration))
//            self.lblYoutubeDuration.text = duration?.stringFromTimeInterval()
//        })
        
//        disableYoutubePlayerControls()
    }
    
//    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
//        return MyThemes.current == .dark ? .black : .white
//    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        
        if playerState == .Paused {
            self.activityLoader.stopAnimating()
            self.imgPlay.isHidden = false
        }
        else if playerState == .Ended {
            self.imgPlay.isHidden = false
        }
        else if playerState == .Playing {
            viewPlaceholder.isHidden = true
        }
        else if playerState == .Unstarted {
            viewPlaceholder.isHidden = true
        }
    }
    
//    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
//
//        self.imgThumbnail.isHidden = true
//    }
//
//    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
//        return MyThemes.current == .dark ? .black : .white
//    }
//
//    func playerViewPreferredInitialLoading(_ playerView: YTPlayerView) -> UIView? {
//        print("playerViewPreferredInitialLoading")
//        return nil
//    }
    
}

extension PostArticleVC: YPImagePickerDelegate {
    
    func noPhotos() {}

    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true// indexPath.row != 2
    }
        
    func openMediaPicker() {
        
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
        if self.postArticleType == .media {
            if self.selectedMediaType == .photo {
                config.screens = [.libraryPhotoOnly]
            }
            else {
                config.screens = [.libraryVideoOnly]
            }
        }
        else if self.postArticleType == .reel {
            config.screens = [.libraryVideoOnly]
        }
        //config.screens = [.library, .libraryPhotoOnly, .libraryVideoOnly]

        /* Can forbid the items with very big height with this property */
        // config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8

        /* Defines the time limit for recording videos.
           Default is 30 seconds. */
        // config.video.recordingTimeLimit = 5.0

        /* Defines the time limit for videos from the library.
           Defaults to 60 seconds. */
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
        
        config.isForReels = self.postArticleType == .reel ? true : false

        
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

                    picker.dismiss(animated: true, completion: { [weak self] in
                        
                        self?.imageURL = ""
                        self?.imgArticle.image = photo.originalImage
                    })
                case .video(let video):

                    self.imageURL = ""
                    self.videoURL = video.url
                    self.localURL = video.url
                    
                    self.imgThumbnail.image = video.thumbnail
                    
                    self.imgPhoto = video.thumbnail
                    self.uploadingFileTaskID = video.taskID ?? ""
                    UploadManager.shared.editingPostTaskID = self.uploadingFileTaskID
                    
                    picker.dismiss(animated: true, completion: { [weak self] in
                        if let url = video.url {
                            self?.player.set(AVURLAsset(url: url))
                        }
                    })
                }
            }
        }
        present(picker, animated: true, completion: nil)
    }
}

//MARK:- ScheduleDate PopupVC Delegate
extension PostArticleVC: ScheduleDatePopupVCDelegate {
    
    func dismissScheduleDateTimeSelected(dateTime: String, localDate: String) {
        
        scheduleDate = localDate
        lblSchedulePost.text = dateTime
    }
}


extension PostArticleVC: ProfileSelectionVCDelegate {
    
    func didSelectChannel(channel: ChannelInfo?) {
        
        if channel?.id != "" && channel?.id != SharedManager.shared.userId {
            
            lblProfileName.text = "\(NSLocalizedString("Post to", comment: "")) \(channel?.name ?? "")"
            selectedChannel = channel
            
            fName = channel?.name ?? ""
            lName = ""
            
            lblProfileName.text = (fName + " " + lName).trim()
            
            
        } else {
            
            lblProfileName.text = NSLocalizedString("Post to My Profile", comment: "")
            selectedChannel = nil
        }
        
        imgProfile.sd_setImage(with: URL(string: channel?.icon ?? ""), placeholderImage: nil)
        
    }
    
    
}

