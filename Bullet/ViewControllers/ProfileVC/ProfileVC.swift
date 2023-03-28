//
//  ProfileVC.swift
//  Bullet
//
//  Created by Khadim Hussain on 06/01/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Toast_Swift
import SwiftTheme
import AVFoundation
import DataCache

class ProfileVC: UIViewController, SettingsNewVCDelegate {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgNotification: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblViewProfile: UILabel!
    @IBOutlet weak var viewPostArticle: UIView!
    

    @IBOutlet weak var lblPreferences: UILabel!
    @IBOutlet weak var lblAccount: UILabel!
    @IBOutlet weak var lblNotification: UILabel!
    @IBOutlet weak var lblTheme: UILabel!
    @IBOutlet weak var lblHaptics: UILabel!
    @IBOutlet weak var lblHelpFeedback: UILabel!
    @IBOutlet weak var lblOthers: UILabel!
    @IBOutlet weak var lblLogOut: UILabel!
    @IBOutlet weak var lblTextSize: UILabel!
    @IBOutlet weak var lblPosts: UILabel!
    @IBOutlet weak var lblWallet: UILabel!
    @IBOutlet weak var lblPersonalization: UILabel!
    @IBOutlet weak var lblAbout: UILabel!
    @IBOutlet weak var lblGeneral: UILabel!
    
    @IBOutlet weak var viewHapticMode: UIView!
    @IBOutlet weak var btnDark: UIButton!
    @IBOutlet weak var btnLight: UIButton!
    @IBOutlet weak var btnAuto: UIButton!
    @IBOutlet weak var btnOnHaptic: UIButton!
    @IBOutlet weak var btnOffHaptic: UIButton!
    @IBOutlet var viewCollectionSwitch: [UIView]!
    @IBOutlet weak var btnOnBulletsAuto: UIButton!
    @IBOutlet weak var btnOffBulletsAuto: UIButton!
    @IBOutlet weak var btnOnVideosAuto: UIButton!
    @IBOutlet weak var btnOffVideosAuto: UIButton!
    @IBOutlet weak var btnOnReelsAuto: UIButton!
    @IBOutlet weak var btnOffReelsAuto: UIButton!
    @IBOutlet weak var btnOnReaderAuto: UIButton!
    @IBOutlet weak var btnOffReaderAuto: UIButton!
        
    @IBOutlet weak var viewThemeSelect: UIView!
    @IBOutlet weak var viewBorderLine1: UIView!
    @IBOutlet weak var viewBorderLine2: UIView!
    @IBOutlet weak var viewAuto: UIView!

    @IBOutlet var lblCollection: [UILabel]!
    @IBOutlet var lblMainHeadingsCollection: [UILabel]!
    @IBOutlet var collectionViewBG: [UIView]!
    @IBOutlet var imgTitleEdge: [UIImageView]!
    @IBOutlet var viewMainHeaderBg: [UIView]!
    //Arrow Group
    @IBOutlet var imageArrowRightGroup: [UIImageView]!
    @IBOutlet weak var constraintThemeButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var viewProfile: UIView!
    
    //Schedule Post
    @IBOutlet weak var lblSchedulePost: UILabel!
    @IBOutlet weak var lblDrafts: UILabel!
    @IBOutlet weak var viewScrollContainer: UIView!
//    @IBOutlet weak var viewNewsDesk: UIView!
    @IBOutlet weak var lblVersion: UILabel!
    
    @IBOutlet weak var imgTikTok: UIImageView!
    @IBOutlet weak var imgTwitter: UIImageView!
    @IBOutlet weak var imgFB: UIImageView!
    @IBOutlet weak var imgYtube: UIImageView!
    @IBOutlet weak var imgInsta: UIImageView!
    
    //saved articles
    @IBOutlet weak var viewSavedArticle: UIView!
    @IBOutlet weak var lblSavedArticle: UILabel!

    // Data Saver
    @IBOutlet weak var lblDataSaver: UILabel!
    @IBOutlet weak var lblBulletsDataSaver: UILabel!
    @IBOutlet weak var lblVideoDataSaver: UILabel!
    @IBOutlet weak var ReelsDataSaver: UILabel!
    @IBOutlet weak var lblReadMode: UILabel!
    @IBOutlet weak var lblAudioSetting: UILabel!

    
    @IBOutlet weak var viewPreferences: UIView!
    @IBOutlet weak var viewFavorites: UIView!
    @IBOutlet weak var viewLanguageContent: UIView!
    @IBOutlet weak var viewAppLanguage: UIView!
    @IBOutlet weak var viewTheme: UIView!
    @IBOutlet weak var viewHaptic: UIView!
    @IBOutlet weak var lblFavorite: UILabel!
    @IBOutlet weak var lblNewsLanguage: UILabel!
    @IBOutlet weak var lblAppLanguage: UILabel!
    @IBOutlet weak var lblWalletAmount: UILabel!
    
    @IBOutlet weak var viewBulletsAuto: UIView!
    @IBOutlet weak var viewVideosAuto: UIView!
    @IBOutlet weak var viewReelsAuto: UIView!
    @IBOutlet weak var viewReaderAuto: UIView!
    @IBOutlet weak var viewWeather: UIView!
    
    @IBOutlet weak var scrollViewProfile: UIScrollView!
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var selectedItems = [YPMediaItem]()
    var isFirtTimeLoaded = false
    var lastReaderType = false

    var channelsArray = [ChannelInfo]()
    var followedChannelsArray = [ChannelInfo]()
    var topicsArray = [TopicData]()
    var placeSection = [locationsSection]()
    var placesArray = [Location]()
    var arrContentSize = [placesSize]()
    var nextPaginate = ""
    var nextPaginateFollowedChannel = ""
    var cellColors = ["E01335","5025E1","975D1B","E13300","641E58","83A52C","1E3264", "850000", "15B9C5"]
    var authorsArray = [Author]()
    
    
    // Normal Heights
    let yourChannelsMaxHeight: CGFloat = 200
    let suggestedChannelsMaxHeight: CGFloat = 200
    let topicsMaxHeight: CGFloat = 120
    let authorsMaxHeight: CGFloat = 200
    let placesMaxHeight: CGFloat = 50
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ANLoader.hide()
        
        //LOCALIZABLE STRING
        self.setupLocalization()
        
        
        viewThemeSelect.cornerRadius = viewThemeSelect.frame.height / 2
        viewThemeSelect.borderWidth = 1
        viewThemeSelect.borderColor = .black//"#707070".hexStringToUIColor()
        
        viewHapticMode.cornerRadius = viewHapticMode.frame.height / 2
        viewHapticMode.borderWidth = 1
        viewHapticMode.borderColor = .black//"#707070".hexStringToUIColor()
        
        viewBulletsAuto.cornerRadius = viewBulletsAuto.frame.height / 2
        viewBulletsAuto.borderWidth = 1
        viewBulletsAuto.borderColor = .black//"#707070".hexStringToUIColor()
        
        viewVideosAuto.cornerRadius = viewVideosAuto.frame.height / 2
        viewVideosAuto.borderWidth = 1
        viewVideosAuto.borderColor = .black//"#707070".hexStringToUIColor()
        
        viewReelsAuto.cornerRadius = viewReelsAuto.frame.height / 2
        viewReelsAuto.borderWidth = 1
        viewReelsAuto.borderColor = .black//"#707070".hexStringToUIColor()
        
        viewReaderAuto.cornerRadius = viewReaderAuto.frame.height / 2
        viewReaderAuto.borderWidth = 1
        viewReaderAuto.borderColor = .black//"#707070".hexStringToUIColor()
        
        
//        imgNotification.theme_image = GlobalPicker.imgNotification
    
        lblTitle.textColor = .black//GlobalPicker.textColor
        lblEmail.textColor = .black//GlobalPicker.textColor
        
//        imgLanguage.layer.cornerRadius = imgLanguage.frame.height / 2
        
        imgTwitter.theme_image = GlobalPicker.twitterMenuIcon
        imgFB.theme_image = GlobalPicker.fbMenuIcon
        imgYtube.theme_image = GlobalPicker.youtubeMenuIcon
        imgInsta.theme_image = GlobalPicker.instaMenuIcon
        
        lblVersion.text = "\(NSLocalizedString(ApplicationAlertMessages.kAppName, comment: "")) \(Bundle.main.releaseVersionNumber ?? "1.0")"


        setSettingsArrowImage()
        setHapticUI()
        setBulletsAutoUI()
        setVideoAutoUI()
        setReelsAutoUI()
        setReaderModeAutoUI()

        btnAuto.layer.cornerRadius = btnAuto.frame.height / 2
        btnLight.layer.cornerRadius = btnDark.frame.height / 2
        btnDark.layer.cornerRadius = btnDark.frame.height / 2
        
        btnOnHaptic.layer.cornerRadius = btnDark.frame.height / 2
        btnOffHaptic.layer.cornerRadius = btnDark.frame.height / 2
        btnOnHaptic.titleLabel?.adjustsFontSizeToFitWidth = true
        btnOffHaptic.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
        btnOnBulletsAuto.layer.cornerRadius = btnOnBulletsAuto.frame.height / 2
        btnOffBulletsAuto.layer.cornerRadius = btnOffBulletsAuto.frame.height / 2
        btnOnBulletsAuto.titleLabel?.adjustsFontSizeToFitWidth = true
        btnOffBulletsAuto.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
        btnOnVideosAuto.layer.cornerRadius = btnOnVideosAuto.frame.height / 2
        btnOffVideosAuto.layer.cornerRadius = btnOffVideosAuto.frame.height / 2
        btnOnVideosAuto.titleLabel?.adjustsFontSizeToFitWidth = true
        btnOffVideosAuto.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
        btnOnReelsAuto.layer.cornerRadius = btnOnReelsAuto.frame.height / 2
        btnOffReelsAuto.layer.cornerRadius = btnOffReelsAuto.frame.height / 2
        btnOnReelsAuto.titleLabel?.adjustsFontSizeToFitWidth = true
        btnOffReelsAuto.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
        btnOnReaderAuto.layer.cornerRadius = btnOnReaderAuto.frame.height / 2
        btnOffReaderAuto.layer.cornerRadius = btnOffReaderAuto.frame.height / 2
        btnOnReaderAuto.titleLabel?.adjustsFontSizeToFitWidth = true
        btnOffReaderAuto.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
        
        if #available(iOS 13.0, *) {
            constraintThemeButtonWidth.constant = 165
            
            let selectedThemeType = UserDefaults.standard.bool(forKey: Constant.UD_isLocalTheme)
            if selectedThemeType == false {
                
                btnAuto.layer.backgroundColor = MyThemes.current == .dark ? Constant.appColor.purple.cgColor : Constant.appColor.blue.cgColor
                btnDark.layer.backgroundColor = UIColor.clear.cgColor
                btnLight.layer.backgroundColor = UIColor.clear.cgColor
                btnAuto.tintColor = UIColor.white
                btnDark.tintColor = Constant.appColor.customGrey
                btnLight.tintColor = Constant.appColor.customGrey
                
                viewBorderLine1.isHidden = true
                viewBorderLine2.isHidden = false
            }
            else {
                
                //didTapThemeColour(MyThemes.current == .dark ? btnDark : btnLight)
                setThemeSelection(sender: MyThemes.current == .dark ? btnDark : btnLight)
            }
        }
        else {
            constraintThemeButtonWidth.constant = 110
            viewAuto.isHidden = true
            //didTapThemeColour(MyThemes.current == .dark ? btnDark : btnLight)
            setThemeSelection(sender: MyThemes.current == .dark ? btnDark : btnLight)
        }
        
        lblCollection.forEach {
            $0.addTextSpacing(spacing: 1.45)
            $0.font = UIFont(name: Constant.FONT_Mulli_EXTRABOLD, size: 12)
        }
        
        lblMainHeadingsCollection.forEach { lbl in
            lbl.addTextSpacing(spacing: 1.45)
        }
        viewMainHeaderBg.forEach { viewBg in
            viewBg.backgroundColor = "#E01335".hexStringToUIColor()
        }
        
        lblWalletAmount.textColor = "#39AE49".hexStringToUIColor()
        
//        viewProfile.backgroundColor = .black//GlobalPicker.backgroundColorWhiteBlack

        viewWeather.isHidden = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
                
        if let ptcTBC = tabBarController as? PTCardTabBarController {
            ptcTBC.showTabBar(true, animated: true)
        }
        let navVC = (self.navigationController?.navigationController as? AppNavigationController)
        if navVC?.showDarkStatusBar == false {
            navVC?.showDarkStatusBar = true
            navVC?.setNeedsStatusBarAppearanceUpdate()
        }
        
        
        if isFirtTimeLoaded {
            
            nextPaginate = ""
            
        }
        isFirtTimeLoaded = true
        
        setProfileData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
//        if lastReaderType != SharedManager.shared.readerMode {
//            SharedManager.shared.isTabReload = true
//        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imgProfile.cornerRadius = imgProfile.frame.height / 2
        imgProfile.contentMode = .scaleAspectFill
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        imageArrowRightGroup.forEach { (imageView) in
            DispatchQueue.main.async {
                if SharedManager.shared.isSelectedLanguageRTL() {
                    imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                } else {
                    imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
                imageView.layoutIfNeeded()
            }
        }
        
        imgTitleEdge.forEach { imageView in
            DispatchQueue.main.async {
                if SharedManager.shared.isSelectedLanguageRTL() {
                    imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                } else {
                    imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
                imageView.layoutIfNeeded()
            }
        }
        
        
        DispatchQueue.main.async {
            if SharedManager.shared.isSelectedLanguageRTL() {
                self.lblTitle.semanticContentAttribute = .forceRightToLeft
                self.lblTitle.textAlignment = .right
                self.lblEmail.semanticContentAttribute = .forceRightToLeft
                self.lblEmail.textAlignment = .right
                self.lblViewProfile.semanticContentAttribute = .forceRightToLeft
                self.lblViewProfile.textAlignment = .right
            } else {
                self.lblTitle.semanticContentAttribute = .forceLeftToRight
                self.lblTitle.textAlignment = .left
                self.lblEmail.semanticContentAttribute = .forceLeftToRight
                self.lblEmail.textAlignment = .left
                self.lblViewProfile.semanticContentAttribute = .forceLeftToRight
                self.lblViewProfile.textAlignment = .left
            }
            
            self.lblCollection.forEach { label in
                if SharedManager.shared.isSelectedLanguageRTL() {
                    label.semanticContentAttribute = .forceRightToLeft
                    label.textAlignment = .right
                } else {
                    label.semanticContentAttribute = .forceLeftToRight
                    label.textAlignment = .left
                }
            }
            
            self.lblMainHeadingsCollection.forEach { label in
                if SharedManager.shared.isSelectedLanguageRTL() {
                    label.semanticContentAttribute = .forceRightToLeft
                    label.textAlignment = .right
                } else {
                    label.semanticContentAttribute = .forceLeftToRight
                    label.textAlignment = .left
                }
            }
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func setCollectionViewData(isMultipleRow: Bool) {
        
        let setCollectionViewCellSize = {(array: [Location]) -> [CGSize] in
            
            var arrCellSize = [CGSize]()
            var totalWidth: CGFloat = 0
            var arrMaxWidth = [CGFloat]()
            
            for (i, dict) in array.enumerated() {
                var textWidth: CGFloat = dict.name?.textWidth(COLLECTION_HEIGHT_PLACES, textFont: UIFont(name: Constant.FONT_Mulli_BOLD, size: 12)!) ?? 0 + (SIZE_EXTRA_TEXT)
                arrMaxWidth.append(textWidth)
                textWidth = textWidth > CGFloat(CELL_MAX_WIDTH) ? textWidth + CGFloat(CELL_SPACING) : CGFloat(CELL_MAX_WIDTH)
                
                //For max cell width || And somtimes text fits to view border so to avoid that.
                textWidth = textWidth > CGFloat(CELL_MAX_WIDTH) || textWidth > (CGFloat(CELL_MAX_WIDTH) - CGFloat(SIZE_EXTRA_TEXT)) ? textWidth + CGFloat(CELL_SPACING) + CGFloat(SIZE_EXTRA_TEXT) : CGFloat(CELL_MAX_WIDTH)
                totalWidth += textWidth
                arrCellSize.append(CGSize(width: textWidth, height: COLLECTION_HEIGHT_PLACES))
            }

            return arrCellSize
        }
        
        for (i, places) in placeSection.enumerated() {
            
            if let list = places.LIST_LIST {
                arrContentSize.append(placesSize(ROW: i, SIZE: setCollectionViewCellSize(list)))
            }
        }
    }
    
    func setSettingsArrowImage() {
        let lightImage = UIImage(named: "nextFollowing")?.sd_tintedImage(with: Constant.appColor.blue)
        let darkImage = UIImage(named: "nextFollowing")?.sd_tintedImage(with: Constant.appColor.purple)
        let colorImage = ThemeImagePicker(images: lightImage!,darkImage!)
        
        imageArrowRightGroup.forEach { (imageView) in
            imageView.theme_image = colorImage
//            theme_setImage(colorImage, forState: .nor)
        }
        
        imgTitleEdge.forEach { (imageView) in
            
            imageView.image = UIImage(named: "icn_home_edge")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = "#E01335".hexStringToUIColor()

        }
        
    }

    func setHapticUI() {
        let isHapticOn = UserDefaults.standard.bool(forKey: Constant.UD_isHapticOn)
        if isHapticOn {
            
            self.setOnOffHaptic(sender: self.btnOnHaptic)
        }
        else {
        
            self.setOnOffHaptic(sender: self.btnOffHaptic)
        }
    }
    
    func setBulletsAutoUI() {
        let isHapticOn = UserDefaults.standard.bool(forKey: Constant.UD_isBulletsAutoPlay)
        if isHapticOn {
            
            self.setOnOffBulletsAuto(sender: self.btnOnBulletsAuto)
        }
        else {
        
            self.setOnOffBulletsAuto(sender: self.btnOffBulletsAuto)
        }
    }
    
    func setVideoAutoUI() {
        let isHapticOn = UserDefaults.standard.bool(forKey: Constant.UD_isDataSaver)
        if isHapticOn {
            
            self.setOnOffVideosAuto(sender: self.btnOnVideosAuto)
        }
        else {
        
            self.setOnOffVideosAuto(sender: self.btnOffVideosAuto)
        }
    }
    
    func setReelsAutoUI() {
        let isHapticOn = UserDefaults.standard.bool(forKey: Constant.UD_isReelsAutoPlay)
        if isHapticOn {
            
            self.setOnOffReelsAuto(sender: self.btnOnReelsAuto)
        }
        else {
        
            self.setOnOffReelsAuto(sender: self.btnOffReelsAuto)
        }
    }
    
    func setReaderModeAutoUI() {
        let isHapticOn = UserDefaults.standard.bool(forKey: Constant.UD_isReaderMode)
        if isHapticOn {
            
            self.setOnOffReaderMode(sender: self.btnOnReaderAuto)
        }
        else {
        
            self.setOnOffReaderMode(sender: self.btnOffReaderAuto)
        }
        
    }
    
    
    
    func setupLocalization() {
        
        lblTitle.text = NSLocalizedString("Menu", comment: "")
                    
   //     lblPostArticle.text = NSLocalizedString("POST ARTICLE", comment: "")
//        lblSettings.text = NSLocalizedString("Settings", comment: "")

        lblAppLanguage.text = NSLocalizedString("APP LANGUAGE", comment: "")
        lblNewsLanguage.text = NSLocalizedString("News Content Language", comment: "").uppercased()
        lblAccount.text  = NSLocalizedString("ACCOUNT", comment: "")
//        lblViewAll.text  = NSLocalizedString("VIEW ALL & MANAGE", comment: "")

        lblNotification.text = NSLocalizedString("NOTIFICATIONS", comment: "")
        
        lblTheme.text = NSLocalizedString("READER THEME", comment: "")
        lblHaptics.text = NSLocalizedString("HAPTICS", comment: "")
        lblAudioSetting.text = NSLocalizedString("AUDIO SETTINGS", comment: "")
        lblTextSize.text = NSLocalizedString("ARTICLE TEXT SIZE", comment: "")
        lblSchedulePost.text = NSLocalizedString("SCHEDULE POST", comment: "")
        lblDrafts.text = NSLocalizedString("DRAFTS", comment: "")
        btnAuto.setTitle(NSLocalizedString("Auto", comment: ""), for: .normal)
        btnLight.setTitle(NSLocalizedString("Light", comment: ""), for: .normal)
        btnDark.setTitle(NSLocalizedString("Dark", comment: ""), for: .normal)
        btnOffHaptic.setTitle(NSLocalizedString("Off", comment: ""), for: .normal)
        btnOnHaptic.setTitle(NSLocalizedString("On", comment: ""), for: .normal)

        lblDataSaver.text = NSLocalizedString("DATA SAVER", comment: "")
        lblOthers.text = NSLocalizedString("OTHERS", comment: "")
        lblHelpFeedback.text = NSLocalizedString("HELP AND FEEDBACK", comment: "")
        lblLogOut.text = NSLocalizedString("LOG OUT", comment: "")
        
        lblGeneral.text = NSLocalizedString("GENERAL", comment: "").uppercased()
//        lblNewsDesk.text = NSLocalizedString("NEWS DESK", comment: "").uppercased()
        lblPosts.text = NSLocalizedString("POSTS", comment: "").uppercased()
        lblWallet.text = NSLocalizedString("WALLET", comment: "").uppercased()
        lblPersonalization.text = NSLocalizedString("PERSONALIZATIONS", comment: "").uppercased()
//        lblNetwork.text = NSLocalizedString("NETWORK", comment: "").uppercased()
        lblAbout.text = NSLocalizedString("ABOUT", comment: "").uppercased()

        
        lblSavedArticle.text = NSLocalizedString("FAVORITES ARTICLES", comment: "")

        lblFavorite.text = NSLocalizedString("FAVORITES", comment: "").uppercased()
        
        lblBulletsDataSaver.text = NSLocalizedString("BULLETS AUTO PLAY", comment: "").uppercased()
        lblVideoDataSaver.text = NSLocalizedString("VIDEOS AUTO PLAY", comment: "").uppercased()
        ReelsDataSaver.text = NSLocalizedString("REELS AUTO PLAY", comment: "").uppercased()
        lblReadMode.text = NSLocalizedString("Reader Mode", comment: "").uppercased()
        
        btnOffBulletsAuto.setTitle(NSLocalizedString("Off", comment: ""), for: .normal)
        btnOnBulletsAuto.setTitle(NSLocalizedString("On", comment: ""), for: .normal)
        
        btnOffVideosAuto.setTitle(NSLocalizedString("Off", comment: ""), for: .normal)
        btnOnVideosAuto.setTitle(NSLocalizedString("On", comment: ""), for: .normal)
        
        btnOffReelsAuto.setTitle(NSLocalizedString("Off", comment: ""), for: .normal)
        btnOnReelsAuto.setTitle(NSLocalizedString("On", comment: ""), for: .normal)
        
        btnOffReaderAuto.setTitle(NSLocalizedString("Off", comment: ""), for: .normal)
        btnOnReaderAuto.setTitle(NSLocalizedString("On", comment: ""), for: .normal)
        
        
    }
    
    
    func didTapRefreshOnBackButton() {
        
        self.lblEmail.text = UserDefaults.standard.value(forKey: Constant.UD_userEmail) as? String
    }
    
    func setOnOffHaptic(sender: UIButton) {
        
        if sender.tag == 0 {
            
            //Off Haptic
            //btnOffHaptic.layer.backgroundColor = MyThemes.current == .dark ? Constant.appColor.purple.cgColor : Constant.appColor.blue.cgColor
            btnOffHaptic.layer.backgroundColor = Constant.appColor.purple.cgColor
            btnOnHaptic.layer.backgroundColor = UIColor.clear.cgColor
            
            btnOffHaptic.tintColor = UIColor.white
            btnOnHaptic.tintColor = Constant.appColor.customGrey
            
            UserDefaults.standard.set(false, forKey: Constant.UD_isHapticOn)
        }
        else {
            
            //On Haptic
            btnOffHaptic.layer.backgroundColor = UIColor.clear.cgColor
            btnOnHaptic.layer.backgroundColor = Constant.appColor.purple.cgColor

            btnOffHaptic.tintColor = Constant.appColor.customGrey
            btnOnHaptic.tintColor = UIColor.white
            
            UserDefaults.standard.set(true, forKey: Constant.UD_isHapticOn)
        }
    }
    
    func setOnOffBulletsAuto(sender: UIButton) {
        
        if sender.tag == 0 {
            
            //Off Haptic
            btnOffBulletsAuto.layer.backgroundColor = Constant.appColor.purple.cgColor
            btnOnBulletsAuto.layer.backgroundColor = UIColor.clear.cgColor
            
            btnOffBulletsAuto.tintColor = UIColor.white
            btnOnBulletsAuto.tintColor = Constant.appColor.customGrey
            
            UserDefaults.standard.set(false, forKey: Constant.UD_isBulletsAutoPlay)
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.datasaverBulletsAutoPlay, status: "0")
            
        }
        else {
            
            //On Haptic
            btnOffBulletsAuto.layer.backgroundColor = UIColor.clear.cgColor
            btnOnBulletsAuto.layer.backgroundColor = Constant.appColor.purple.cgColor

            btnOffBulletsAuto.tintColor = Constant.appColor.customGrey
            btnOnBulletsAuto.tintColor = UIColor.white
            
            UserDefaults.standard.set(true, forKey: Constant.UD_isBulletsAutoPlay)
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.datasaverBulletsAutoPlay, status: "1")
            
        }
    }
    
    func setOnOffVideosAuto(sender: UIButton) {
        
        if sender.tag == 0 {
            
            //Off Haptic
            btnOffVideosAuto.layer.backgroundColor = Constant.appColor.purple.cgColor
            btnOnVideosAuto.layer.backgroundColor = UIColor.clear.cgColor
            
            btnOffVideosAuto.tintColor = UIColor.white
            btnOnVideosAuto.tintColor = Constant.appColor.customGrey
            
            UserDefaults.standard.set(false, forKey: Constant.UD_isDataSaver)
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.datasaverVideoAutoPlay, status: "0")
            
        }
        else {
            
            //On Haptic
            btnOffVideosAuto.layer.backgroundColor = UIColor.clear.cgColor
            btnOnVideosAuto.layer.backgroundColor = Constant.appColor.purple.cgColor

            btnOffVideosAuto.tintColor = Constant.appColor.customGrey
            btnOnVideosAuto.tintColor = UIColor.white
            
            UserDefaults.standard.set(true, forKey: Constant.UD_isDataSaver)
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.datasaverVideoAutoPlay, status: "1")
            
        }
    }
    
    
    func setOnOffReelsAuto(sender: UIButton) {
        
        if sender.tag == 0 {
            
            //Off Haptic
            btnOffReelsAuto.layer.backgroundColor = Constant.appColor.purple.cgColor
            btnOnReelsAuto.layer.backgroundColor = UIColor.clear.cgColor
            
            btnOffReelsAuto.tintColor = UIColor.white
            btnOnReelsAuto.tintColor = Constant.appColor.customGrey
            
            UserDefaults.standard.set(false, forKey: Constant.UD_isReelsAutoPlay)
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.datasaverReelsAutoPlay, status: "0")
            
        }
        else {
            
            //On Haptic
            btnOffReelsAuto.layer.backgroundColor = UIColor.clear.cgColor
            btnOnReelsAuto.layer.backgroundColor = Constant.appColor.purple.cgColor

            btnOffReelsAuto.tintColor = Constant.appColor.customGrey
            btnOnReelsAuto.tintColor = UIColor.white
            
            UserDefaults.standard.set(true, forKey: Constant.UD_isReelsAutoPlay)
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.datasaverReelsAutoPlay, status: "1")
            
        }
    }
    
    func setOnOffReaderMode(sender: UIButton) {
        
        if sender.tag == 0 {

            //Off Haptic
            btnOffReaderAuto.layer.backgroundColor = Constant.appColor.purple.cgColor
            btnOnReaderAuto.layer.backgroundColor = UIColor.clear.cgColor

            btnOffReaderAuto.tintColor = UIColor.white
            btnOnReaderAuto.tintColor = Constant.appColor.customGrey

            UserDefaults.standard.set(false, forKey: Constant.UD_isReaderMode)
            
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.datasaverReaderModeAutoPlay, status: "0")

        }
        else {

            //On Haptic
            btnOffReaderAuto.layer.backgroundColor = UIColor.clear.cgColor
            btnOnReaderAuto.layer.backgroundColor = Constant.appColor.purple.cgColor

            btnOffReaderAuto.tintColor = Constant.appColor.customGrey
            btnOnReaderAuto.tintColor = UIColor.white

            UserDefaults.standard.set(true, forKey: Constant.UD_isReaderMode)
            
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.datasaverReaderModeAutoPlay, status: "1")
        }
    }
    
    
    func setThemeSelection(sender: UIButton) {
        
        if sender.tag == 0 {
            
            //Auto
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.autoMode, eventDescription: "")
            self.btnDark.layer.backgroundColor = UIColor.clear.cgColor
            self.btnLight.layer.backgroundColor = UIColor.clear.cgColor
            self.btnAuto.tintColor = UIColor.white
            self.btnDark.tintColor = Constant.appColor.customGrey
            self.btnLight.tintColor = Constant.appColor.customGrey
            
            viewBorderLine1.isHidden = true
            viewBorderLine2.isHidden = false
            
            SharedManager.shared.setThemeAutomatic()
            
            self.btnAuto.layer.backgroundColor = MyThemes.current == .dark ? Constant.appColor.purple.cgColor : Constant.appColor.blue.cgColor
            
        }
        else if sender.tag == 1 {
            
            //Light
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.lightMode, eventDescription: "")
            self.btnAuto.layer.backgroundColor = UIColor.clear.cgColor
            self.btnDark.layer.backgroundColor = UIColor.clear.cgColor
            self.btnAuto.tintColor = Constant.appColor.customGrey
            self.btnDark.tintColor = Constant.appColor.customGrey
            self.btnLight.tintColor = UIColor.white
            
            viewBorderLine1.isHidden = true
            viewBorderLine2.isHidden = true
            
            MyThemes.switchTo(theme: .light)
            UserDefaults.standard.set(true, forKey: Constant.UD_isLocalTheme)
            UserDefaults.standard.set(false, forKey: "dark")
            
            self.btnLight.layer.backgroundColor = MyThemes.current == .dark ? Constant.appColor.purple.cgColor : Constant.appColor.blue.cgColor
        }
        else {
            
            //Dark
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.darkMode, eventDescription: "")
            self.btnAuto.layer.backgroundColor = UIColor.clear.cgColor
            self.btnLight.layer.backgroundColor = UIColor.clear.cgColor
            self.btnAuto.tintColor = Constant.appColor.customGrey
            self.btnDark.tintColor = UIColor.white
            self.btnLight.tintColor = Constant.appColor.customGrey
            
            viewBorderLine1.isHidden = false
            viewBorderLine2.isHidden = true
            
            MyThemes.switchTo(theme: .dark)
            UserDefaults.standard.set(true, forKey: Constant.UD_isLocalTheme)
            UserDefaults.standard.set(true, forKey: "dark")
            
            self.btnDark.layer.backgroundColor = MyThemes.current == .dark ? Constant.appColor.purple.cgColor : Constant.appColor.blue.cgColor
        }
        MyThemes.saveLastTheme()
        
        var style = ToastStyle()
        style.backgroundColor = MyThemes.current == .dark ? UIColor.white.withAlphaComponent(0.8) : UIColor.black.withAlphaComponent(0.8)
        style.messageColor = MyThemes.current == .dark ? "#3D485F".hexStringToUIColor(): "#FFFFFF".hexStringToUIColor()
        ToastManager.shared.style = style
        
        setSettingsArrowImage()
        setHapticUI()
        setBulletsAutoUI()
        setVideoAutoUI()
        setReelsAutoUI()
        setReaderModeAutoUI()
        
    }
    
    
    @IBAction func didTapManageYourChannels(_ sender: Any) {
        
        //Channels
        let vc = YourChannelsVC.instantiate(fromAppStoryboard: .Channel)
        let nav = AppNavigationController(rootViewController: vc)
        if MyThemes.current == .light {
            nav.showDarkStatusBar = true
        }
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nav, animated: true, completion: nil)
        
    }
    
    @IBAction func didTapManageTopics(_ sender: Any) {
        
        //topic
        let vc = FollowingTopicsVC.instantiate(fromAppStoryboard: .Channel)
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func didTapManageChannels(_ sender: Any) {
        
        //channels
        let vc = FollowingChannelsVC.instantiate(fromAppStoryboard: .Channel)
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func didTapManageAuthors(_ sender: Any) {
        
        //authors
        let vc = FollowingAuthorsVC.instantiate(fromAppStoryboard: .Channel)
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func didTapManagePlaces(_ sender: Any) {
        
        let vc = FollowingPlacesVC.instantiate(fromAppStoryboard: .Channel)
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func didTapPreferences(_ sender: Any) {
        
        let vc = ForYouPreferencesVC.instantiate(fromAppStoryboard: .Reels)
        vc.delegate = self
        vc.currentCategory = SharedManager.shared.curReelsCategoryId
        vc.isOpenFromMenu = true
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
        
        
    }
    
    
    
    @IBAction func didTapViewProfile(_ sender: UIButton) {
        
        if SharedManager.shared.isGuestUser && SharedManager.shared.isLinkedUser == false {
                        
            let vc = RegistrationNewVC.instantiate(fromAppStoryboard: .RegistrationSB)
            let navVC = UINavigationController(rootViewController: vc)
            self.navigationController?.present(navVC, animated: true, completion: nil)
        }
        else {
            
            //            if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails), (user.setup ?? false) {
            
            let vc = ViewProfileVC.instantiate(fromAppStoryboard: .Main)
            let navVC = AppNavigationController(rootViewController: vc)
            if MyThemes.current == .light {
                navVC.showDarkStatusBar = true
            }
            navVC.modalPresentationStyle = .fullScreen
            //vc.delegate = self
            self.present(navVC, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func didTapFollowingMenu(_ sender: UIButton) {
        
        if sender.tag == 1 {
            //topic
            let vc = FollowingTopicsVC.instantiate(fromAppStoryboard: .Channel)
            let nav = AppNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.navigationController?.present(nav, animated: true, completion: nil)
        }
        else if sender.tag == 2 {
            //channels
            let vc = FollowingChannelsVC.instantiate(fromAppStoryboard: .Channel)
            let nav = AppNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.navigationController?.present(nav, animated: true, completion: nil)
        }
        else if sender.tag == 3 {
            //authors
            let vc = FollowingAuthorsVC.instantiate(fromAppStoryboard: .Channel)
            let nav = AppNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.navigationController?.present(nav, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapSettings(_ sender: UIButton) {
        
        if sender.tag == 1 {
            
            //Editions
            let vc = OnboardingLanguageVC.instantiate(fromAppStoryboard: .Onboarding)
            vc.isFromProfileVC = true
            let navVC = AppNavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .overFullScreen
            navVC.navigationBar.isHidden = true
            self.present(navVC, animated: true, completion: nil)
            
        }
        else if sender.tag == 2 {
            
            //Language
            let vc = LanguageVC.instantiate(fromAppStoryboard: .Main)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
         
        }
        else if sender.tag == 3 {
            
            //TextSizeVC
            let vc = TextSizeVC.instantiate(fromAppStoryboard: .Main)
//            vc.modalPresentationStyle = .overFullScreen
            let nav = AppNavigationController(rootViewController: vc)
            if MyThemes.current == .light {
                nav.showDarkStatusBar = true
            }
            nav.modalPresentationStyle = .fullScreen
            
            self.present(nav, animated: true, completion: nil)
        }
        else if sender.tag == 4 {
            
            // MyAccountVC
            let vc = MyAccountVC.instantiate(fromAppStoryboard: .Main)
            let nav = AppNavigationController(rootViewController: vc)
            if MyThemes.current == .light {
                nav.showDarkStatusBar = true
            }
            nav.modalPresentationStyle = .fullScreen
            nav.navigationBar.isHidden = true
            self.present(nav, animated: true, completion: nil)
            
        }
        
        else if sender.tag == 5 {
            
            //Notification
            SharedManager.shared.sendAnalyticsEvent(eventType: Constant.analyticsEvents.pushClicks, eventDescription: "")
            let vc = NotificationVC.instantiate(fromAppStoryboard: .Main)
            let nav = AppNavigationController(rootViewController: vc)
            if MyThemes.current == .light {
                nav.showDarkStatusBar = true
            }
            nav.modalPresentationStyle = .fullScreen
            nav.navigationBar.isHidden = true
            self.present(nav, animated: true, completion: nil)
            
        }
        else if sender.tag == 6 {
            
            //data saver
            let vc = DataSaverSettingsVC.instantiate(fromAppStoryboard: .registration)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)

        }
        else if sender.tag == 7 {
            
          //personalization - color, haptic, audio settings
            let vc = PersonalizationVC.instantiate(fromAppStoryboard: .Main)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
        else if sender.tag == 8 {
            
            //help & feedback --- true
            let vc = CommonHelpFeedOthersVC.instantiate(fromAppStoryboard: .Main)
            vc.isFromHelpFeedback = true
            let nav = AppNavigationController(rootViewController: vc)
            if MyThemes.current == .light {
                nav.showDarkStatusBar = true
            }
            nav.modalPresentationStyle = .fullScreen
            nav.navigationBar.isHidden = true
            self.present(nav, animated: true, completion: nil)
        }
        else if sender.tag == 9 {
            
            //others -- false
            let vc = CommonHelpFeedOthersVC.instantiate(fromAppStoryboard: .Main)
            vc.isFromHelpFeedback = false
            let nav = AppNavigationController(rootViewController: vc)
            if MyThemes.current == .light {
                nav.showDarkStatusBar = true
            }
            nav.modalPresentationStyle = .fullScreen
            nav.navigationBar.isHidden = true
            self.present(nav, animated: true, completion: nil)
            
        }
        else if sender.tag == 10 {
            
            //logout
            DataCache.instance.cleanAll()
            performWSTologoutUser()
        }
        else if sender.tag == 11 {
            
            //schedule post
            let svc = SchedulePostListVC.instantiate(fromAppStoryboard: .Schedule)
            let nav = AppNavigationController(rootViewController: svc)
            if MyThemes.current == .light {
                nav.showDarkStatusBar = true
            }
            nav.modalPresentationStyle = .fullScreen
            nav.navigationBar.isHidden = true
            self.present(nav, animated: true, completion: nil)
        }
        else if sender.tag == 12 {
            
            if let walletLink = UserDefaults.standard.string(forKey: Constant.UD_WalletLink) {
                
                let vc = WalletWebviewVC.instantiate(fromAppStoryboard: .Channel)
                vc.webURL = walletLink
                vc.titleWeb = "WALLET"
                let nav = AppNavigationController(rootViewController: vc)
                if MyThemes.current == .light {
                    nav.showDarkStatusBar = true
                }
                nav.modalPresentationStyle = .overFullScreen
                
                self.present(nav, animated: true, completion: nil)
            }
        }
        
        else if sender.tag == 13 { 
            
            //Channels
            let vc = YourChannelsVC.instantiate(fromAppStoryboard: .Channel)
            let nav = AppNavigationController(rootViewController: vc)
            if MyThemes.current == .light {
                nav.showDarkStatusBar = true
            }
            nav.modalPresentationStyle = .fullScreen
            self.navigationController?.present(nav, animated: true, completion: nil)
        }
        
        else if sender.tag == 14 {
            
            //Followings
            let vc = FollowingVC.instantiate(fromAppStoryboard: .Channel)
            let nav = AppNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.navigationController?.present(nav, animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapFavorites(_ sender: Any) {
        
        let vc = DraftSavedArticlesVC.instantiate(fromAppStoryboard: .Schedule)
        vc.isFromSaveArticles = true
        let nav = AppNavigationController(rootViewController: vc)
        if MyThemes.current == .light {
            nav.showDarkStatusBar = true
        }
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    
    @IBAction func didTapNewsContent(_ sender: Any) {
        
        let vc = OnboardingLanguageVC.instantiate(fromAppStoryboard: .Onboarding)
        vc.isFromProfileVC = true
        let navVC = AppNavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .overFullScreen
        navVC.navigationBar.isHidden = true
        self.present(navVC, animated: true, completion: nil)
    }
    
    
    @IBAction func didTapAppLanguage(_ sender: Any) {
        
        //Language
        let vc = LanguageVC.instantiate(fromAppStoryboard: .Main)
//        vc.modalPresentationStyle = .overFullScreen
        let nav = AppNavigationController(rootViewController: vc)
        if MyThemes.current == .light {
            nav.showDarkStatusBar = true
        }
        nav.modalPresentationStyle = .fullScreen
        nav.navigationBar.isHidden = true
        self.present(nav, animated: true, completion: nil)
    }
    
    
    @IBAction func didTapSchedule(_ sender: Any) {
        
        //schedule post
        let svc = SchedulePostListVC.instantiate(fromAppStoryboard: .Schedule)
        let nav = AppNavigationController(rootViewController: svc)
        if MyThemes.current == .light {
            nav.showDarkStatusBar = true
        }
        nav.modalPresentationStyle = .fullScreen
        nav.navigationBar.isHidden = true
        self.present(nav, animated: true, completion: nil)
        
    }
    
    
    @IBAction func didTapAudioSettings(_ sender: UIButton) {
        
        let vc = AudioSettingsVC.instantiate(fromAppStoryboard: .registration)
        let nav = AppNavigationController(rootViewController: vc)
        if MyThemes.current == .light {
            nav.showDarkStatusBar = true
        }
        nav.modalPresentationStyle = .fullScreen
        nav.navigationBar.isHidden = true
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func didTapDrafts(_ sender: Any) {
        
        let vc = SchedulePostListVC.instantiate(fromAppStoryboard: .Schedule)
        vc.isDraftList = true
        let nav = AppNavigationController(rootViewController: vc)
        if MyThemes.current == .light {
            nav.showDarkStatusBar = true
        }
        nav.modalPresentationStyle = .fullScreen
        nav.navigationBar.isHidden = true
        self.present(nav, animated: true, completion: nil)
    }
    
    
    @IBAction func didTapThemeColour(_ sender: UIButton) {
     
        setThemeSelection(sender: sender)
    }
    
    @IBAction func didTapOnOffHaptic(_ sender: UIButton) {
        
        if sender.tag == 0 {
            
            setOnOffHaptic(sender: btnOffHaptic)
        }
        else {
            
            setOnOffHaptic(sender: btnOnHaptic)
            if UserDefaults.standard.bool(forKey: Constant.UD_isHapticOn) {
                var generator = UIImpactFeedbackGenerator()
                if #available(iOS 13.0, *) {
                    generator = UIImpactFeedbackGenerator(style: .soft)
                } else {
                    
                    generator = UIImpactFeedbackGenerator(style: .heavy)
                }
                generator.impactOccurred()
            }
        }
    }
    
    @IBAction func didTapOnOffBulletsDataSaver(_ sender: UIButton) {
        
        if sender.tag == 0 {
            
            setOnOffBulletsAuto(sender: btnOffBulletsAuto)
        }
        else {
            
            setOnOffBulletsAuto(sender: btnOnBulletsAuto)
            if UserDefaults.standard.bool(forKey: Constant.UD_isBulletsAutoPlay) {
                var generator = UIImpactFeedbackGenerator()
                if #available(iOS 13.0, *) {
                    generator = UIImpactFeedbackGenerator(style: .soft)
                } else {
                    
                    generator = UIImpactFeedbackGenerator(style: .heavy)
                }
                generator.impactOccurred()
            }
        }
        
        performWSToUpdateConfigView()
    }
    
    @IBAction func didTapOnOffVideoDataSaver(_ sender: UIButton) {
        
        if sender.tag == 0 {
            
            setOnOffVideosAuto(sender: btnOffVideosAuto)
        }
        else {
            
            setOnOffVideosAuto(sender: btnOnVideosAuto)
            if UserDefaults.standard.bool(forKey: Constant.UD_isDataSaver) {
                var generator = UIImpactFeedbackGenerator()
                if #available(iOS 13.0, *) {
                    generator = UIImpactFeedbackGenerator(style: .soft)
                } else {
                    
                    generator = UIImpactFeedbackGenerator(style: .heavy)
                }
                generator.impactOccurred()
            }
        }
        
        performWSToUpdateConfigView()
    }
    
    @IBAction func didTapOnOffReelsDataSaver(_ sender: UIButton) {
        
        if sender.tag == 0 {
            
            setOnOffReelsAuto(sender: btnOffReelsAuto)
        }
        else {
            
            setOnOffReelsAuto(sender: btnOnReelsAuto)
            if UserDefaults.standard.bool(forKey: Constant.UD_isReelsAutoPlay) {
                var generator = UIImpactFeedbackGenerator()
                if #available(iOS 13.0, *) {
                    generator = UIImpactFeedbackGenerator(style: .soft)
                } else {
                    
                    generator = UIImpactFeedbackGenerator(style: .heavy)
                }
                generator.impactOccurred()
            }
        }
        
        performWSToUpdateConfigView()
    }
    
    @IBAction func didTapOnOffReaderMode(_ sender: UIButton) {
        
        SharedManager.shared.isTabReload = true
        
        if sender.tag == 0 {
            
            setOnOffReaderMode(sender: btnOffReaderAuto)
        }
        else {
            
            setOnOffReaderMode(sender: btnOnReaderAuto)
            if UserDefaults.standard.bool(forKey: Constant.UD_isReaderMode) {
                var generator = UIImpactFeedbackGenerator()
                if #available(iOS 13.0, *) {
                    generator = UIImpactFeedbackGenerator(style: .soft)
                } else {
                    
                    generator = UIImpactFeedbackGenerator(style: .heavy)
                }
                generator.impactOccurred()
            }
        }
        
        performWSToUpdateConfigView()
        
    }
    
    
    
    @IBAction func didTapShowNotifications(_ sender: UIButton) {
        
        let vc = NotificationsListVC.instantiate(fromAppStoryboard: .Channel)
        let nav = AppNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.navigationController?.present(nav, animated: true, completion: nil)
        
    }
    
    @IBAction func didTapPostArticle(_ sender: UIButton) {
                     
        //SharedManager.shared.community = false
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
                    
                    let vc = UploadArticleBottomSheetVC.instantiate(fromAppStoryboard: .Schedule)
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
    
    @IBAction func didTapTikTok(_ sender: Any) {
        
//        https://vm.tiktok.com/ZSJwvRwFk/
        let appURLString = "https://vm.tiktok.com/ZSJwvRwFk/"
        let webURLString = "https://vm.tiktok.com/ZSJwvRwFk/"
        guard let appURL = URL(string: appURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
            return
        }
        
        guard let webURL = URL(string: webURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(webURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(webURL)
            }
        }
    }
    
    @IBAction func didTapTwitter(_ sender: Any) {
        //https://twitter.com/Newsreelsapp
        let appURLString = "twitter://user?screen_name=Newsreelsapp"
        let webURLString = "https://twitter.com/Newsreelsapp"
        guard let appURL = URL(string: appURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
            return
        }
        
        guard let webURL = URL(string: webURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(webURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(webURL)
            }
        }
    }
    
    @IBAction func didTapFb(_ sender: Any) {
        
        let appURLString = "fb://profile/100980738491568"
        let webURLString = "https://www.facebook.com/newsreelsofficial/"
        guard let appURL = URL(string: appURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
            return
        }
        
        guard let webURL = URL(string: webURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(webURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(webURL)
            }
        }
    }
    
    @IBAction func didTapYoutube(_ sender: Any) {
        
//https://www.youtube.com/c/NewsreelsOfficial

        let appURLString = "youtube://channel/UCAouHcHjTMJhZAE1E5tdjSg"
        let webURLString = "https://www.youtube.com/channel/UCAouHcHjTMJhZAE1E5tdjSg"
        guard let appURL = URL(string: appURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
            return
        }
        
        guard let webURL = URL(string: webURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(webURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(webURL)
            }
        }
    }
    
    @IBAction func didTapInsta(_ sender: Any) {
        
        //https://www.instagram.com/newsreelsofficial/
        let appURLString = "instagram://user?username=newsreelsofficial"
        let webURLString = "https://www.instagram.com/newsreelsofficial/"
        guard let appURL = URL(string: appURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
            return
        }
        
        guard let webURL = URL(string: webURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(webURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(webURL)
            }
        }
    }
}


//MARK:- EditionVC Delegate
extension ProfileVC: EditionVCDelegate {
    
    func didTapRefressSettings() {
        
        print("didTapRefressSettings")
//        performWSToGetSelectedEdition()
    }
    
}

//MARK:- UploadArticleBottomSheetVC Delegate
extension ProfileVC: UploadArticleBottomSheetVCDelegate {
    
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

//MARK:- CommunityGuideVC Delegate
extension ProfileVC: CommunityGuideVCDelegate {
    
    func dimissCommunityGuideApprovedDelegate() {
        
        SharedManager.shared.performWSToCommunityGuide()

        if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails), (user.setup ?? false) {
            
            let vc = UploadArticleBottomSheetVC.instantiate(fromAppStoryboard: .Schedule)
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

extension ProfileVC: YoutubeArticleVCDelegate {
    
    func submitYoutubeArticlePost(_ article: articlesData) {
        
        if let ptcTBC = tabBarController as? PTCardTabBarController {
            ptcTBC.showTabBar(false, animated: true)
        }
        
        let vc = PostArticleVC.instantiate(fromAppStoryboard: .Schedule)
        vc.yArticle = article
        vc.postArticleType = .youtube
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK : - Media Picker
extension ProfileVC: YPImagePickerDelegate {
    
    func noPhotos() {}

    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true// indexPath.row != 2
    }
        
    func openMediaPicker(isForReels: Bool) {
        
        var config = YPImagePickerConfiguration()
         config.library.onlySquare = true

        config.library.mediaType = .photoAndVideo
        config.library.itemOverlayType = .grid
        
        config.libraryPhotoOnly.mediaType = .photo
        config.libraryPhotoOnly.itemOverlayType = .grid
        
        config.libraryVideoOnly.mediaType = .video
        config.libraryVideoOnly.itemOverlayType = .grid
        
         config.showsPhotoFilters = false

        config.shouldSaveNewPicturesToAlbum = false

        config.video.compression = AVAssetExportPresetPassthrough

         config.albumName = ApplicationAlertMessages.kAppName

        config.startOnScreen = .library

        /* Defines which screens are shown at launch, and their order.
           Default value is `[.library, .photo]` */
        if isForReels {
            config.screens = [.libraryVideoOnly]
        } else {
            config.screens = [.library, .libraryPhotoOnly, .libraryVideoOnly]
        }
        

        config.video.libraryTimeLimit = 14400

        config.video.libraryTimeLimit = 14400

        config.video.minimumTimeLimit = 1
        
        /* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
        config.showsCrop = .none//.rectangle(ratio: (16/9))

        config.hidesStatusBar = false

        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false

        config.maxCameraZoomFactor = 2.0

        config.library.maxNumberOfItems = 1
        config.libraryPhotoOnly.maxNumberOfItems = 1
        config.libraryVideoOnly.maxNumberOfItems = 1
        config.gallery.hidesRemoveButton = false
        
        config.isForReels = isForReels
        
        
        let picker = YPImagePicker(configuration: config)

        picker.imagePickerDelegate = self

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
                      
                        if let ptcTBC = self?.tabBarController as? PTCardTabBarController {
                            ptcTBC.showTabBar(false, animated: true)
                        }
                        
                        let vc = PostArticleVC.instantiate(fromAppStoryboard: .Schedule)
                        vc.imgPhoto = photo.originalImage
                        vc.postArticleType = .media
                        vc.selectedMediaType = .photo
                        vc.modalPresentationStyle = .fullScreen
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
                        self?.navigationController?.pushViewController(vc, animated: true)

                    })
                }
            }
        }

        present(picker, animated: true, completion: nil)
    }
}

extension ProfileVC: PopupVCDelegate {
    
    func popupVCDismissed() {

        let vc = EditProfileVC.instantiate(fromAppStoryboard: .Main)
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK:- Edit Profile Delegate
extension ProfileVC: EditProfileVCDelegate {
    
    func setProfileData() {
        
        if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails) {
            
            let profile = user.profile_image ?? ""

            if profile.isEmpty {
                
                //imgProfile.theme_image = GlobalPicker.imgUserPlaceholder
                imgProfile.image = UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" : "icn_profile_placeholder_light")
            }
            else {
                imgProfile.sd_setImage(with: URL(string: profile), placeholderImage: nil)
            }
            
            let fname = user.first_name ?? ""
            let lname = user.last_name ?? ""
            
            if fname.isEmpty && lname.isEmpty {
                
                lblEmail.text = NSLocalizedString("Create your profile", comment: "")
                lblViewProfile.text = NSLocalizedString("Set your profile", comment: "")
            }
            else {
                
                lblEmail.text = fname + " " + lname
                lblViewProfile.text = NSLocalizedString("View your profile", comment: "")
            }
        }
        else {
            
            //imgProfile.theme_image = GlobalPicker.imgUserPlaceholder
            imgProfile.image = UIImage(named: MyThemes.current == .dark ? "icn_profile_placeholder_dark" : "icn_profile_placeholder_light")
            lblEmail.text = NSLocalizedString("Create your profile", comment: "")
            lblViewProfile.text = NSLocalizedString("Set your profile", comment: "")
        }

    }
}

extension ProfileVC: ForYouPreferencesVCDelegate {
    
    func userChangedCategory() {
        
        //we will save article id and selected index to update list on home screen
       // let subData = self.homeCategoriesArray[indexPath.section].data
        NotificationCenter.default.post(name: Notification.Name.notifyTapSubcategories, object: nil)
    }
    
    
    func userDismissed(vc: ForYouPreferencesVC, selectedPreference: Int, selectedCategory: String) {
    }
    
}
