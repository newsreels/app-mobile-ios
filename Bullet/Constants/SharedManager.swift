//
//  SharedManager.swift
//  Bullet
//
//  Created by Mahesh on 13/04/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import SystemConfiguration
import AVFoundation
import AppsFlyerLib
import PlayerKit
import FirebaseCrashlytics
import SafariServices
import SDWebImage
import FirebaseAnalytics
import DataCache
import Alamofire

public enum TabbarType: Int {
    
    case Reels
    case Home
    case Search
    case Following
    case Profile
}

public enum profilePageControllType: Int {
    
    case Relevant
    case Topic
    case Articles
    case Channels
    case Editions
    case Authors
    case Places
    case none
    
}

public enum LoginType: Int {
    
    case Google
    case Facebook
    case Apple
    case Email
    case Guest
}

enum ArticleType {
    
    case home
    case topic
    case places
    case source
    case savedArticle
    case notification
    case widget
}

enum FontSizeType: Int {
    
    case defaultSize
    case smallSize
    case mediumSize
    case largeSize
}

enum PostArticleType {
    
    case media
    case reel
    case youtube
}

enum mediaType: String {
    case video
    case photo
}

enum followType: String {
    case topics
    case sources
    case locations
    case authors
}

class SharedManager {
    
    static let shared = SharedManager()

    //Notification variables
    var isAppLaunchedThroughNotification = false
    var isVolumnOffCard = false
    var articleIdNotification = ""
    var reelsContextNotification = ""
    var viewArticleArray = [articlesData]()
    var reelsCategories = [MainCategoriesData]()
    var articlesCategories = [MainCategoriesData]()

    var topicHomeMenu = [TopicData]()
    var sourceHomeMenu = [ChannelInfo]()
    var authorHomeMenu = [Author]()
//    var force = false
    var bottomConstraint: NSLayoutConstraint?
    
    var subLocationList = [Location]()
    var subTopicsList = [TopicData]()
    var subSourcesList = [ChannelInfo]()
    var subSourcesTitle = ""
    var instaVideoLocalPath = ""
    var videoUrlTesting = URL(string: "")
    var instaMediaUrl = ""
    var isReelsVideo = false
    var mainSourcesIDsArray = [String]()
    var followSourcesIDsArray = [String]()
    var unFollowSourcesIDsArray = [String]()
    var sourcesIDsArray = [String]()

    var isShowRelevant = false
    var isShowBulletDetails = false
    var isShowPushNotification: Bool = false
    var isSubSourceView: Bool = false

    var isForYouTabReelsReload: Bool = false
    var isFollowingTabReelsReload: Bool = false
    var reloadRequiredFromTopics: Bool = false
    var isTabReload: Bool = false
    var isDiscoverTabReload: Bool = false
    var isUserTapOnTabbar: Bool = false
    var subTabBarType: profilePageControllType = .none
    let cache = NSCache<NSString, NSData>()
    var videoFocusedIndex: Int = 0
    var currentArticleIndex: Int = 0
    var duration: Int = 3
    var cardVisibleRect: CGRect = CGRect.zero

    //FOR RELATIVE
    let relativeFontConstantSmallScreen: CGFloat = 0.040
    let relativeFontConstantLargeScreen: CGFloat = 0.051

    var isTutorialDone = false
    
    var isOnPrefrence = false
    var isFromPNBackground = false
    
    //var dataSaver = false
    var videoAutoPlay: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constant.UD_isDataSaver)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.UD_isDataSaver)
        }
    }
    var reelsAutoPlay: Bool {
        get {
            return UserDefaults.standard.value(forKey: Constant.UD_isReelsAutoPlay) as? Bool ?? false
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.UD_isReelsAutoPlay)
        }
    }
    var bulletsAutoPlay: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constant.UD_isBulletsAutoPlay)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.UD_isBulletsAutoPlay)
        }
    }
    
    var readerMode: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constant.UD_isReaderMode)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.UD_isReaderMode)
        }
    }
    
    var filterType: String? {
        get {
            return UserDefaults.standard.object(forKey: Constant.UD_filterType) as? String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.UD_filterType)
        }
    }
    
    var refreshFeedOnKillApp: Date? {
        get {
            return UserDefaults.standard.object(forKey: Constant.UD_refreshFeedOnKillApp) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constant.UD_refreshFeedOnKillApp)
        }
    }
    
    var refreshReelsOnKillApp: Date? {
        get {
            return UserDefaults.standard.object(forKey: Constant.UD_refreshReelsOnKillApp) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constant.UD_refreshReelsOnKillApp)
        }
    }

    var appUsageCount: Int? {
        get {
            return UserDefaults.standard.object(forKey: UserDefaults.Key.usageCount.rawValue) as? Int
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Key.usageCount.rawValue)
        }
    }
    
    var isAppOnboardScreensLoaded: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constant.isAppOnboardScreensLoaded)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constant.isAppOnboardScreensLoaded)
        }
    }
    
    var isOnboardingPreferenceLoaded: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constant.isOnboardingPreferenceLoaded)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constant.isOnboardingPreferenceLoaded)
        }
    }
    
    var isSavedPreferenceAlertRequired = false
    

    var lastBackgroundTimeReels: Date?
    var speedRate = [String: Double]()
    
//    var isAudioEnableReels: Bool = true
    
    var homeVideoCarouselCCSize = CGSize.zero

    var orientationLock = UIInterfaceOrientationMask.portrait
    var canRotate = false
    
    var lastModifiedTimeDiscover = ""
    var lastModifiedTimeFeeds = ""
    
    var lastModifiedTimeArticlesForYou: String {
        get {
            return UserDefaults.standard.string(forKey: Constant.lastModifiedTimeArticlesForYou) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constant.lastModifiedTimeArticlesForYou)
        }
    }
    
    var lastModifiedTimeArticlesFollowing: String {
        get {
            return UserDefaults.standard.string(forKey: Constant.lastModifiedTimeArticlesFollowing) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constant.lastModifiedTimeArticlesFollowing)
        }
    }
    
    

    typealias CompletionHandler = (_ success:Bool) -> Void
//    var isAudioEnableReels: Bool = true {
//        didSet {
//            if isAudioEnableReels != SharedManager.shared.isAudioEnable {
//                SharedManager.shared.isAudioEnable = isAudioEnableReels
//            }
//        }
//    }
    
    
//    var isAudioEnable: Bool = false {
//        didSet {
//            if SharedManager.shared.isAudioEnableReels != isAudioEnable && SharedManager.shared.isReelsLoadedFirstTime {
//                SharedManager.shared.isAudioEnableReels = isAudioEnable
//            }
//        }
//    }
//
    
    var isAudioEnable: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constant.UD_isAudioEnable)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.UD_isAudioEnable)
        }
    }
    
    var AppFirstEverLaunch: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constant.UD_AppFirstEverLaunch)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.UD_AppFirstEverLaunch)
        }
    }
    
    var isAudioEnableReels: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constant.UD_isAudioEnableReels)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.UD_isAudioEnableReels)
        }
    }
    
    var isCaptionsEnableReels: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constant.UD_isCaptionsEnableReels)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.UD_isCaptionsEnableReels)
        }
    }
    
    var lastAudioValue : Float?
    
    var isReelsLoadedFirstTime = false
    
    var showHeadingsOnly = ""
    var isHeadlineComplete = true
    var isUserinteractWithHeadlinesOnly = false
    var isManualScrolling = false
    var readingSpeed = "1.0x"
    var localReadingSpeed = 1.0
    var isLongPressed = false
    var isVolumeOn = true
    var articleOnVolume = articlesData()
    var bulletCurrentIndex = 0
    var isDeviceVolume = true
    var isLanguageRTL = false
    
    var bulletPlayer: AVAudioPlayer?
    var deviceVolumeStatus = false
    var segementIndex = 0
    var isAppLaunchFirstTIME = false
    var isAudioMuted = false
//    var isTabbed = false
    var isPauseAudio = false
    var userAlert: Alert?

    var isResetIndex = false
//    var spbCardView : SegmentedProgressBar?
//    var spbListView : SegmentedProgressBar?
    var isFav = false
    var haveAritcles = true
//    var observerArray: Any!
    var observerChildArticle: Any!

    var community = true
    var adsInterval = 10
    var articleURLPageLoaded = false
    var isLoadWebFromArticles = false
    var isTopTabBarCurrentlHidden = false
    var curCategoryIndex = 0
    var isAppOpenFromDeepLink = false
    var isOnDiscover = true
    var viewSubCategoryIshidden = false
    var selectedChannelDesc = ""
    var selectedChannelImageURL = ""
            
    var isReloadProfileArticle: Bool = false
    var articleSearchListVCShowing = false
    var isVideoPlaying = false
    var isFromTabbarVC = false
    var movedFromReels = false
    var viewAnimation: AppLoaderView?
    var timeObserve = Notification.Name("timeObserve")
    var timerCancel = Notification.Name("timerCancel")
    let playingPlayersNotification = Notification.Name("playingPlayers")
    var playingPlayers: [String] = [] {
        didSet {
            if playingPlayers.count > 1 {
                NotificationCenter.default.post(name: playingPlayersNotification, object: nil, userInfo: nil)
            }
        }
    }
    var players = [PlayerPreloadModel]() {
        didSet {
            if players.count > 6 {
                players.removeFirst()
            }
        }
    }
    var isFirstimeSplashScreenLoaded = false
    
    var tabBarIndex: Int {
        get {
            return UserDefaults.standard.integer(forKey: Constant.tabBarIndex)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.tabBarIndex)
        }
    }
    
    var curReelsCategoryId: String {
        get {
            return UserDefaults.standard.string(forKey: Constant.reelsCategoryId) ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.reelsCategoryId)
        }
    }
    
    var curArticlesCategoryId: String {
        get {
            return UserDefaults.standard.string(forKey: Constant.articlesCategoryId) ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.articlesCategoryId)
        }
    }

    
    var isVideoCellSelected = true

    var languageId: String {
        get {
            return UserDefaults.standard.string(forKey: Constant.UD_languageId) ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.UD_languageId)
        }
    }

    var userId: String {
        get {
            return UserDefaults.standard.string(forKey: Constant.UD_userId) ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.UD_userId)
        }
    }
    
    var userDetails: Data {
        get {
            if let data = UserDefaults.standard.object(forKey: Constant.userSavedDetails) {
                return data as! Data
            }
            return Data.init()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constant.userSavedDetails)
        }
    }

    var selectedFontType: FontSizeType? {
        get {
            let fontSizeTypeIndex = UserDefaults.standard.integer(forKey: Constant.fontSizeType)
            return FontSizeType(rawValue: fontSizeTypeIndex)
        }
        set {
            UserDefaults.standard.set(newValue?.rawValue, forKey: Constant.fontSizeType)
        }
    }
    
    var isUserSetup: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constant.UD_userSetup)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.UD_userSetup)
        }
    }

    
    var isGuestUser: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constant.guestUser)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.guestUser)
        }
    }
    
    var isLinkedUser: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constant.linkedUser)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.linkedUser)
        }
    }
    
    var adsAvailable: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constant.UD_adsAvailable)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.UD_adsAvailable)
        }
    }
    
    var adType: String {
        get {
            // "FACEBOOK"
            return UserDefaults.standard.string(forKey: Constant.UD_adsType) ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.UD_adsType)
        }
    }
    
    //    let adUnitID = "ca-app-pub-3940256099942544/3986624511" //Google ads Dummy
    // google video test
    //"ca-app-pub-3940256099942544/1044960115"
    // fb test ad "VID_HD_16_9_15S_LINK#623788458503686_805567246992472"
    //"ca-app-pub-3940256099942544/3986624511"//UserDefaults.standard.bool(forKey: Constant.UD_adsUnitKey)
    var adUnitFeedID: String {
        get {
            
            return UserDefaults.standard.string(forKey: Constant.UD_adsUnitFeedKey) ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.UD_adsUnitFeedKey)
        }
    }
    
    var adUnitReelID: String {
        get {
            
            return UserDefaults.standard.string(forKey: Constant.UD_adsUnitReelKey) ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.UD_adsUnitReelKey)
        }
    }

    enum reelCategory:Int {
        case foryou, following, community
    }
    
    func setSelectedReelsCategory(category: reelCategory)  {
        
        UserDefaults.standard.setValue(category.rawValue, forKey: Constant.Selected_Reel_Category)
        
    }
    
    func getSelectedReelsCategory()-> Int {
        
        return UserDefaults.standard.integer(forKey: Constant.Selected_Reel_Category)
    }
    
    
    var isReelsFollowingNeedRefresh: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constant.isReelsFollowingNeedRefresh)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constant.isReelsFollowingNeedRefresh)
        }
    }
    
    var buttonTabSelected = 0
    var textSizeChanged = false
    
    
    // MARK: - Custom Bullet Font
    func getTitleFont() -> UIFont {
        
        switch selectedFontType {
        case .defaultSize:
            return UIFont(name: Constant.FONT_ROBOTO_MEDIUM, size: 22 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 22)
        case .smallSize:
            return UIFont(name: Constant.FONT_ROBOTO_MEDIUM, size: 18 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 18)
        case .mediumSize:
            return UIFont(name: Constant.FONT_ROBOTO_MEDIUM, size: 26 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 26)
        case .largeSize:
            return UIFont(name: Constant.FONT_ROBOTO_MEDIUM, size: 30 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 30)
        default:
            return UIFont(name: Constant.FONT_ROBOTO_MEDIUM, size: 22 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 22)
        }
    }
    
    func getBulletFont() -> UIFont {
        
        switch selectedFontType {
        case .defaultSize:
            return UIFont(name: Constant.FONT_ProximaNova_REGULAR, size: 17 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 17)
        case .smallSize:
            return UIFont(name: Constant.FONT_ProximaNova_REGULAR, size: 13 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 13)
        case .mediumSize:
            return UIFont(name: Constant.FONT_ProximaNova_REGULAR, size: 21 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 21)
        case .largeSize:
            return UIFont(name: Constant.FONT_ProximaNova_REGULAR, size: 25 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 25)
        default:
            return UIFont(name: Constant.FONT_ProximaNova_REGULAR, size: 17 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 17)
        }
    }
    
    
    // MARK: - Home Card Bullet Font
    
    func getHeaderTitleFont() -> UIFont {
        
        switch selectedFontType {
        case .defaultSize:
            return UIFont(name: Constant.FONT_ProximaNova_BOLD, size: 30 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 26)
        case .smallSize:
            return UIFont(name: Constant.FONT_ProximaNova_BOLD, size: 28 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 24)
        case .mediumSize:
            return UIFont(name: Constant.FONT_ProximaNova_BOLD, size: 36 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 32)
        case .largeSize:
            return UIFont(name: Constant.FONT_ProximaNova_BOLD, size: 40 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 36)
        default:
            return UIFont(name: Constant.FONT_ProximaNova_BOLD, size: 32 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 28)
        }
        
    }
    
    
    func getCardViewTitleFont() -> UIFont {
        
//        for family in UIFont.familyNames {
//            print("\(family)")
//
//            for name in UIFont.fontNames(forFamilyName: family) {
//                print("\(name)")
//            }
//        }
        
        switch selectedFontType {
        case .defaultSize:
            return UIFont.systemFont(ofSize: 26, weight: .bold)
            // UIFont(name: Constant.FONT_ProximaNova_MEDIUM, size: 26 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 22)
        case .smallSize:
            return UIFont.systemFont(ofSize: 24, weight: .bold)
            //UIFont(name: Constant.FONT_ProximaNova_MEDIUM, size: 24 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 20)
        case .mediumSize:
            return UIFont.systemFont(ofSize: 32, weight: .bold)
            //UIFont(name: Constant.FONT_ProximaNova_MEDIUM, size: 32 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 28)
        case .largeSize:
            return UIFont.systemFont(ofSize: 36, weight: .bold)
            //UIFont(name: Constant.FONT_ProximaNova_MEDIUM, size: 36 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 32)
        default:
            return UIFont.systemFont(ofSize: 28, weight: .bold)
            //UIFont(name: Constant.FONT_ProximaNova_MEDIUM, size: 28 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 24)
        }
    }
    
    func getCardViewBulletFont() -> UIFont {
        
        
        switch selectedFontType {
        case .defaultSize:
            return UIFont.systemFont(ofSize: 26, weight: .regular)
        case .smallSize:
            return UIFont.systemFont(ofSize: 24, weight: .regular)
        case .mediumSize:
            return UIFont.systemFont(ofSize: 32, weight: .regular)
        case .largeSize:
            return UIFont.systemFont(ofSize: 36, weight: .regular)
        default:
            return UIFont.systemFont(ofSize: 28, weight: .regular)
        }
        
        /*
        switch selectedFontType {
        case .defaultSize:
            return UIFont(name: Constant.FONT_ProximaNova_REGULAR, size: 22 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 22)
        case .smallSize:
            return UIFont(name: Constant.FONT_ProximaNova_REGULAR, size: 20 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 20)
        case .mediumSize:
            return UIFont(name: Constant.FONT_ProximaNova_REGULAR, size: 28 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 28)
        case .largeSize:
            return UIFont(name: Constant.FONT_ProximaNova_REGULAR, size: 32 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 32)
        default:
            return UIFont(name: Constant.FONT_ProximaNova_REGULAR, size: 24 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 24)
        }
        */
        
    }
    
    // MARK: - Home List Bullet Font
    func getListViewTitleFont() -> UIFont {
        
        switch selectedFontType {
        case .defaultSize:
            return UIFont.systemFont(ofSize: 17, weight: .bold)
            //UIFont(name: Constant.FONT_ProximaNova_MEDIUM, size: 17 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 17)
        case .smallSize:
            return UIFont.systemFont(ofSize: 13, weight: .bold)
            //UIFont(name: Constant.FONT_ProximaNova_MEDIUM, size: 13 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 13)
        case .mediumSize:
            return UIFont.systemFont(ofSize: 21, weight: .bold)
            //UIFont(name: Constant.FONT_ProximaNova_MEDIUM, size: 21 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 21)
        case .largeSize:
            return UIFont.systemFont(ofSize: 25, weight: .bold)
            //UIFont(name: Constant.FONT_ProximaNova_MEDIUM, size: 25 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 25)
        default:
            return UIFont.systemFont(ofSize: 17, weight: .bold)
//            UIFont(name: Constant.FONT_ProximaNova_MEDIUM, size: 17 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 17)
        }
        
    }
    
    func getListViewBulletFont() -> UIFont {
        
        switch selectedFontType {
        case .defaultSize:
            return UIFont.systemFont(ofSize: 17, weight: .medium)
            //UIFont(name: Constant.FONT_ROBOTO_REGULAR, size: 17 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 17)
        case .smallSize:
            return UIFont.systemFont(ofSize: 13, weight: .medium)
            //UIFont(name: Constant.FONT_ROBOTO_REGULAR, size: 13 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 13)
        case .mediumSize:
            return UIFont.systemFont(ofSize: 21, weight: .medium)
            //UIFont(name: Constant.FONT_ROBOTO_REGULAR, size: 21 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 21)
        case .largeSize:
            return UIFont.systemFont(ofSize: 25, weight: .medium)
            //UIFont(name: Constant.FONT_ROBOTO_REGULAR, size: 25 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 25)
        default:
            return UIFont.systemFont(ofSize: 17, weight: .medium)
            //UIFont(name: Constant.FONT_ROBOTO_REGULAR, size: 17 + self.adjustFontSizeForiPad()) ?? UIFont.systemFont(ofSize: 17)
        }
    }
        
    
    func adjustFontSizeForiPad()-> Double {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 5
        }
        return 0
    }
    
    
    // MARK: - AlertView PopUp
    func showAlertView(source : UIViewController, title:String, message:String) {
        
        let alert = UIAlertController(title: title as String, message: message as String, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        source.present(alert, animated: true, completion: nil)
    }
    
    func showAPIFailureAlert() {
        
        if let vc = (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController {
            SharedManager.shared.showAlertView(source: vc, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString(ApplicationAlertMessages.kMsgSomethingWentWrong, comment: ""))
        }
    }
    
    func clearProgressBar() {
    
//        
//        SharedManager.shared.spbListView?.cancel()
//        
//        
//        
//        SharedManager.shared.spbCardView?.removeFromSuperview()
    }
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
    
    func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<4:
            return NSLocalizedString("Hello", comment: "")
        case 4..<12:
            return NSLocalizedString("Good morning", comment: "")
        case 12..<17:
            return NSLocalizedString("Good afternoon", comment: "")
        case 17..<24:
            return NSLocalizedString("Good evening", comment: "")
        default:
            break
        }
        return "Hello"
    }
    
    func getTodaysDay()-> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        let current_date = dateFormatter.string(from: date)
        return current_date
    }
    
    func localToUTC(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone.current
        
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    
        return dateFormatter.string(from: date)
    }
    
    func utcToLocal(dateStr: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        //Check pulbished date is nil with format
        var pDate = dateFormatter.date(from: dateStr)
        if pDate == nil {
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX" //was "yyyy-MM-dd'T'HH:mm:ss'Z'"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            pDate = dateFormatter.date(from: dateStr)
        }
        return pDate
    }
    
    func utcToLocal(dateStr: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        //Check pulbished date is nil with format
        var pDate = dateFormatter.date(from: dateStr)
        if pDate == nil {
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX" //was "yyyy-MM-dd'T'HH:mm:ss'Z'"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            pDate = dateFormatter.date(from: dateStr)
        }

        var strDate = ""
        if let date = pDate {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "h:mm a"
        
            strDate = dateFormatter.string(from: date)
        }
        
        if let date = pDate {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "MMMM dd"
        
            strDate = strDate.isEmpty ? dateFormatter.string(from: date) : strDate + "-" + dateFormatter.string(from: date)
        }
        return strDate
    }
    
    func generateDatTimeOfNews(_ pubDate: String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        //Check pulbished date is nil with format
        var pDate = formatter.date(from: pubDate) //"2021-07-31T16:45:05Z"
        if pDate == nil {
            
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX" //was "yyyy-MM-dd'T'HH:mm:ss'Z'"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            pDate = formatter.date(from: pubDate)
        }

        let curStr = formatter.string(from: Date())
        
        if let pDate = pDate, let currentDate = formatter.date(from: curStr) {
                        
            let calendar = Calendar.current
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .month, .year])
            let differenceOfDate = calendar.dateComponents(components, from: pDate, to: currentDate)
            //print("date", differenceOfDate)
            var day = differenceOfDate.day!
            let hours = differenceOfDate.hour!
            let min = differenceOfDate.minute!
            
            if day > 0 {
                
                let daysDiff = calendar.dateComponents([.day], from: calendar.startOfDay(for: pDate), to: currentDate)
                //print("date", differenceOfDate)
                day = daysDiff.day!
            }
            
            if abs(day) == 0 {
                
                if abs(hours) < 2 {
                    
                    if abs(hours) < 1 {
                        
                        if min < 1 {
                            return "\(NSLocalizedString("JUST NOW", comment: ""))"
                        } else {
                            return "\(min) \(NSLocalizedString("MINS AGO", comment: ""))"
                        }
                        
//                        if abs(min) < 1 {
//                            return "moments ago".uppercased()
//                        }
//                        else if abs(min) < 2 {
//                            return "a minute ago".uppercased()
//                        }
//                        else {
//                            return "an hour ago".uppercased()
//                        }
                    }
                    else {
                        
                        return NSLocalizedString("AN HOUR AGO", comment: "")
                    }
                }
                else {
                    return "\(hours) \(NSLocalizedString("HOURS AGO", comment: ""))"
                }
            }
            else if abs(day) > 7 {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d"
                return "\(dateFormatter.string(from: pDate))".uppercased()
            }
            else if abs(day) == 7 {
                
                return NSLocalizedString("1 WEEK AGO", comment: "")
            }
            else if abs(day) < 2 {

                return NSLocalizedString("YESTERDAY", comment: "")
            }
            else if day > 1 {
                
                return "\(day) \(NSLocalizedString("DAYS AGO", comment: ""))"
            }
            else {
                
                return "\(-day) \(NSLocalizedString("DAYS AGO", comment: ""))"
            }
        }
        return ""
    }
    
    
    func generateDatTimeOfNewsShortType(_ pubDate: String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        //Check pulbished date is nil with format
        var pDate = formatter.date(from: pubDate)
        if pDate == nil {
            
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX" //was "yyyy-MM-dd'T'HH:mm:ss'Z'"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            pDate = formatter.date(from: pubDate)
        }

        let curStr = formatter.string(from: Date())
        
        if let pDate = pDate, let currentDate = formatter.date(from: curStr) {
            
//            let dateOfNow = Calendar.current.startOfDay(for: Date())
//            let dateNews = Calendar.current.startOfDay(for: pDate)
//
//            let components = Calendar.current.dateComponents([.day, .hour, .minute], from: dateOfNow, to: dateNews)
//            let day = components.day!
//            let hours = components.hour!
//            let min = components.minute!
            
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .month, .year])
            let differenceOfDate = Calendar.current.dateComponents(components, from: pDate, to: currentDate)
            //print("date", differenceOfDate)
            let day = differenceOfDate.day!
            let hours = differenceOfDate.hour!
            let min = differenceOfDate.minute!
            
            if abs(day) == 0 {
                
                if abs(hours) < 2 {
                    
                    if abs(hours) < 1 {
                        
                        if min < 1 {
                            return "\(NSLocalizedString("JUST NOW", comment: "").capitalized)"
                        } else {
                            return "\(min) \(NSLocalizedString("m", comment: ""))"
                        }
                        
//                        if abs(min) < 1 {
//                            return "moments ago".uppercased()
//                        }
//                        else if abs(min) < 2 {
//                            return "a minute ago".uppercased()
//                        }
//                        else {
//                            return "an hour ago".uppercased()
//                        }
                    }
                    else {
                        
                        return "1\(NSLocalizedString("h", comment: ""))"
                    }
                }
                else {
                    return "\(hours) \(NSLocalizedString("h", comment: ""))"
                }
            }
            else if abs(day) > 7 {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, yyyy"
                return "\(dateFormatter.string(from: pDate))".uppercased()
            }
            else if abs(day) == 7 {
                
                return NSLocalizedString("1w", comment: "")
            }
            else if abs(day) < 2 {

                return NSLocalizedString("1d", comment: "")
            }
            else if day > 1 {
                
                return "\(day) \(NSLocalizedString("d", comment: ""))"
            }
            else {
                
                return "\(-day) \(NSLocalizedString("d", comment: ""))"
            }
        }
        return ""
    }
    
    
    
    func getDocumentDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0]
    }
    
    func getDataFromDocumentDirectory(fileName: String, folderName: String) -> Data {
        let documentsDirectory = self.getDocumentDirectoryPath()
        let fileNameNew: String = folderName.count == 0 ? documentsDirectory : documentsDirectory + "/" + folderName + "/" + fileName
        if FileManager.default.fileExists(atPath: fileNameNew) {
            return NSData(contentsOfFile: fileNameNew) as Data? ?? Data.init()
        }
        return Data.init()
    }
    
    func getDocumentDirectoryPath(_ filename: String, folderName: String) -> String {
        let documentsDirectory = self.getDocumentDirectoryPath()
        let dataPath: String = folderName.count == 0 ? documentsDirectory : documentsDirectory + "/" + folderName
        
        if !FileManager.default.fileExists(atPath: dataPath) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
            } catch { 
 				}
        }
        return dataPath + "/"
    }
    
    func getDocumentDirectoryPath(_ filename: String) -> String {
        let documentsDirectory = self.getDocumentDirectoryPath()
        let dataPath: String = documentsDirectory + "/" + filename
        
        if !FileManager.default.fileExists(atPath: dataPath) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
            } catch {
 				 }
        }
        return dataPath + "/"
    }
    
    func getDataFromDocumentDirectory(_ fileName: String) -> Data {
        var fName = fileName
        let documentsDirectory = getDocumentDirectoryPath()
        fName = "\(documentsDirectory)/\(fName)"
        if FileManager.default.fileExists(atPath: fName) {
            return NSData(contentsOfFile: fName)! as Data
        }
        return Data.init()
    }
    
    func writeDataAtPath(filePath: String, location: URL, destinationUrl: URL, isOverWriteOld: Bool) -> Bool {
        let fileManager: FileManager = FileManager.default
        
        let writeFile = { () -> Bool in
            do {
                try fileManager.moveItem(at: location, to: destinationUrl)
                return true
            } catch { print("File write error : \(error.localizedDescription)") }
            return false
        }
        
        if fileManager.fileExists(atPath: location.absoluteString) && isOverWriteOld {
            do {
                try fileManager.removeItem(atPath: filePath)
                return writeFile()
            } catch { print("File remove error : \(error.localizedDescription)") }
        }
        else { return writeFile() }
        return false
    }
    
    func removeFileAt(_ filePath: URL) {
        let fileManager: FileManager = FileManager.default
        do {
            try fileManager.removeItem(at: filePath)
        } catch { print("File remove error : \(error.localizedDescription)") }
        
        //return false
    }
    
    func removeFileAtPath(_ filePath: String) {
        let fileManager: FileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch { print("File remove error : \(error.localizedDescription)") }
        
        //return false
    }
    
    //MARK: - AppsFlyer Events Report
    func sendAnalyticsEvent(eventType: String, eventDescription: String = "", article_id: String = "", duration: String = "", source_id: String = "", author_id: String = "", entity_id: String = "", status: String = "", channel_id: String = "", topics_id: String = "", section_name: String = "") {
        
        if eventType == Constant.analyticsEvents.videoDurationEvent || eventType == Constant.analyticsEvents.reelsDurationEvent {
            if article_id == "" || duration == "" || duration == "0" || duration == "0.0" || duration == "nan" {
                return
            }
        }
        
        if article_id.isEmpty || article_id == "" {
            
            return
        }
        
        #if DEBUG
        //print("AppsFlyerEvents:-", eventType)
        #else
//        AppsFlyerLib.shared().logEvent("\(eventType)", withValues: [
//            "description": "\(eventDescription ?? "")",
//            "userId": UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? "",
//            "email": UserDefaults.standard.value(forKey: Constant.UD_userEmail) ?? ""
//        ])
        #endif
        
        Analytics.logEvent("\(eventType)", parameters:
        [
            "article_id": article_id,
            "description": eventDescription,
            "duration": duration,
            "source_id":source_id,
            "author_id": author_id,
            "entity_id": entity_id,
            "status": status,
            "channel_id": channel_id,
            "topics_id": topics_id,
            "section_name": section_name
        ])
        
        
        //    ARTICLE_VIDEO_COMPLETE
        //    REEL_COMPLETE
        //    ARTICLE_VIEW
        //    ARTICLE_DETAIL_PAGE
        //    ARTICLE_SWIPE
        if eventType == Constant.analyticsEvents.videoFinishedPlaying || eventType == Constant.analyticsEvents.reelsFinishedPlaying || eventType == Constant.analyticsEvents.reelViewed || eventType == Constant.analyticsEvents.articleViewed || eventType == Constant.analyticsEvents.articleDetailsPageOpened || eventType == Constant.analyticsEvents.articleSwipeEvent || eventType == Constant.analyticsEvents.videoDurationEvent || eventType == Constant.analyticsEvents.reelsDurationEvent {
            
         
            self.performWSToUpdateAnalytics(ArticleId: article_id, eventName: eventType, duration: duration)
            
            
        }
        //"email": UserDefaults.standard.value(forKey: Constant.UD_userEmail) ?? ""
    }
    
//    func loadJsonSubTitles(filename fileName: String) -> subTitlesDC? {
//        
//        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
//            do {
//                let data = try Data(contentsOf: url)
//                let decoder = JSONDecoder()
//                let jsonData = try decoder.decode(subTitlesDC.self, from: data)
//                return jsonData
//            } catch {
//                print("error:\(error)")
//            }
//        }
//        return nil
//    }
    
    func loadJsonLanguages(filename fileName: String) -> [languagesData]? {
        
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(LanguagesDC.self, from: data)
                return jsonData.languages
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
    func loadJsonFeeds(filename fileName: String) -> [sectionsData]? {
        
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(feedInfoDC.self, from: data)
                return jsonData.sections
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
    func performWSToGetUserInfo() {

        let token = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        WebService.URLResponseAuth("auth/info", method: .get, parameters: nil, headers: token, withSuccess: { (response) in

            //ANLoader.hide()
            do {
                let FULLResponse = try
                    JSONDecoder().decode(userInfoDC.self, from: response)

                self.isUserSetup = FULLResponse.results?.setup ?? false

                if let userEmail = FULLResponse.results?.email {

                    UserDefaults.standard.set(userEmail, forKey: Constant.UD_userEmail)
                }
                if let isSocialLinked = FULLResponse.results?.hasPassword {

                    UserDefaults.standard.set(isSocialLinked, forKey: Constant.UD_isSocialLinked)
                }

            } catch let jsonerror {

                SharedManager.shared.logAPIError(url: "auth/info", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }

        }) { (error) in

            print("error parsing json objects",error)
        }
    }
    
    func performWSToUpdateArticleAnalytics(ArticleId:String, isFromReel:Bool) {

        // Update Firebase Analytics
//        self.sendAnalyticsEvent(eventType: Constant.articleViewed, eventDescription: "", article_id: ArticleId)
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        DispatchQueue.global(qos: .background).async {
            let url = isFromReel ? "analytics/reels/\(ArticleId)" : "analytics/articleview/\(ArticleId)"
            WebService.URLResponse(url, method: .post, parameters: nil, headers: token, withSuccess: { (response) in
                do{
                    let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)
                    
                    if let message = FULLResponse.message, message.lowercased() == "ok" {
                        
                        
                    }
                    else {
                        
#if DEBUG
                        //                    self.showAPIFailureAlert()
#else
#endif
                    }
                    
                } catch let jsonerror {
                    
                    //                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                    print("error parsing json objects",jsonerror)
                }
                
            }) { (error) in
                
                print("error parsing json objects",error)
            }
        }
    }
    
    func performWSDurationAnalytics(reelId: String, duration: String) {
        DispatchQueue.global(qos: .background).async {
            let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
            let parameters = "{\"duration\": \"\(duration)\"}"
            let postData = parameters.data(using: .utf8)
            
            var request = URLRequest(url: URL(string: "https://api.bullets.app/analytics/duration/\(reelId)")!,timeoutInterval: Double.infinity)
            request.addValue("ios", forHTTPHeaderField: "x-app-platform")
            request.addValue(Bundle.main.releaseVersionNumberPretty, forHTTPHeaderField: "x-app-version")
            request.addValue(WebserviceManager.shared.API_VERSION, forHTTPHeaderField: "api-version")
            request.addValue(Locale.current.languageCode ?? "en", forHTTPHeaderField: "x-user-language")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            request.httpMethod = "POST"
            request.httpBody = postData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print(String(describing: error))
                    return
                }
                print(String(data: data, encoding: .utf8)!)
            }
            
            task.resume()
            
        }
        //[POST] {{host}}/analytics/custom_event/:article_id/:event_name
        /*
        let url = "analytics/duration/\(reelId)"
        let params: [String: Any] = ["duration": duration]

        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let jsonString = String(data: jsonData, encoding: .utf8)!
        let jsonStringWithEscapedQuotes = jsonString.replacingOccurrences(of: "\"", with: "\\\"")


        WebService.URLResponse(url, method: .post, data: jsonStringWithEscapedQuotes, headers: token, withSuccess: { (response) in

            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)
                if let message = FULLResponse.message, message.lowercased() == "ok" {

                }
                else {

                    #if DEBUG
                    self.showAPIFailureAlert()
                    #else
                    #endif
                }

            } catch let jsonerror {

                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }

        }) { (error) in

            print("error parsing json objects",error)
        }
         */
    }
    
    func performWSToUpdateAnalytics(ArticleId: String, eventName: String, duration: String) {
        DispatchQueue.global(qos: .background).async {
            let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
            
            //[POST] {{host}}/analytics/custom_event/:article_id/:event_name
            
            let url = "analytics/custom_event/\(ArticleId)/\(eventName)?duration=\(duration)"
            
            WebService.URLResponse(url, method: .post, parameters: nil, headers: token, withSuccess: { (response) in
                
                do{
                    let FULLResponse = try
                    JSONDecoder().decode(messageData.self, from: response)
                    
                    if let message = FULLResponse.message, message.lowercased() == "ok" {
                        
                    }
                    else {
                        
#if DEBUG
                        self.showAPIFailureAlert()
#else
#endif
                    }
                    
                } catch let jsonerror {
                    
                    SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                    print("error parsing json objects",jsonerror)
                }
                
            }) { (error) in
                
                print("error parsing json objects",error)
            }
        }
    }
    
    
    func performWSToCommunityGuide() {
                        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        WebService.URLResponse("user/terms/community-guidelines", method: .post, parameters: nil, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(CommunityGuideDC.self, from: response)
                            
                SharedManager.shared.community = FULLResponse.accept ?? true
                
            } catch let jsonerror {
            
                SharedManager.shared.logAPIError(url: "user/terms/community-guidelines", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            
            print("error parsing json objects",error)
        }
    }
    
    func resizeImageByHeight(_ image: UIImage, height: CGFloat) -> UIImage {
        let imageWidth: CGFloat = image.size.width;
        let imageHeight: CGFloat = image.size.height;
        let newWidth: CGFloat = (imageWidth / imageHeight) * height;
        return self.imageByScalingToSize(image, targetSize: CGSize(width: newWidth, height: height))
    }
    
    func imageByScalingToSize(_ sourceImage: UIImage, targetSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 2.0);
        sourceImage.draw(in: CGRect(x: 0, y: 0,width: targetSize.width,height: targetSize.height))
        let generatedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return generatedImage;
    }
    
    
    /// Check app language code for  finding RTL Languages
    func isSelectedLanguageRTL()-> Bool {
        if let language = LanguageHelper.shared.getSavedLanguage() {
            let code = language.code
            if code == "fa" || code == "ar" || code == "iw" || code == "ur" {
                return true
            } else {
                return false
            }

        } else {
            let code = UserDefaults.standard.string(forKey: Constant.UD_languageSelected)
            if code == "fa" || code == "ar" || code == "iw" || code == "ur" {
                return true
            } else {
                return false
            }
        }
    }
    
    func isSelectedLanguageRTL(selectedLanguage: String)-> Bool {
        if selectedLanguage == "fa" || selectedLanguage == "ar" || selectedLanguage == "iw" || selectedLanguage == "ur" {
            return true
        } else {
            return false
        }
    }
    
    
    func setThemeAutomatic() {
        
        UserDefaults.standard.set(false, forKey: Constant.UD_isLocalTheme)
        if UIViewController().isDarkMode {

            MyThemes.switchTo(theme: .dark)
        }
        else {

            MyThemes.switchTo(theme: .light)
        }
        
    }
    
    
    func anotherGetRandomColor()->UIColor{

        let newRed   = Double(arc4random_uniform(256))/255.0
        let newGreen = Double(arc4random_uniform(256))/255.0
        let newBlue  = Double(arc4random_uniform(256))/255.0

        return UIColor(displayP3Red: CGFloat(newRed), green: CGFloat(newGreen), blue: CGFloat(newBlue), alpha: 1.0)
    }
    
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    // Return Bullet List trailing space
    func getBulletListLabelTrailing(selectedLanguage: String?) -> CGFloat {
        
        let correctionValue: CGFloat = 10
        
        if selectedLanguage != nil && selectedLanguage != "" && SharedManager.shared.isSelectedLanguageRTL(selectedLanguage: selectedLanguage ?? "") {
             // Check app language, and set leading
            if SharedManager.shared.isSelectedLanguageRTL() {
                return 4 + correctionValue //4
            } else {
                return 12 + correctionValue//12
            }
        } else {
            
            // Check app language, and set leading
            if SharedManager.shared.isSelectedLanguageRTL() {
                
                return 12 + correctionValue // 12
            } else {
                
                return 16 + correctionValue // 16
            }
        }
        
    }
 
    func performWSToUpdateRegion(_ regionID: String, completionHandler: @escaping (_ status: Bool) -> Void) {
        
//        ANLoader.showLoading()

        let params = ["region": regionID]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        WebService.URLResponse("news/regions", method: .patch, parameters: params, headers: token, withSuccess: { (response) in
            completionHandler(true)
            ANLoader.hide()

            do{
                let json = try JSONSerialization.jsonObject(with: response, options: []) as? [String : Any]
             }catch{ print("erroMsg") }

        }) { (error) in
            ANLoader.hide()
            completionHandler(false)
            print("error parsing json objects",error)
        }
    }

    
    func performWSToUpdateLanguage(id: String, isRefreshedToken: Bool, completionHandler: @escaping (_ status: Bool) -> Void) {
        
        let params = ["language": id]
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
//        ANLoader.showLoading()
        WebService.URLResponseAuth("auth/update-profile/language", method: .patch, parameters: params, headers: token, withSuccess: { (response) in
            ANLoader.hide()
            do{
                let FULLResponse = try
                    JSONDecoder().decode(messageDC.self, from: response)
                
                if FULLResponse.message?.uppercased() == Constant.STATUS_SUCCESS {
                    
                    if isRefreshedToken {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {

                            WebService.checkValidToken { _ in

                                completionHandler(true)
                            }
                        })
                    }
                    else {
                        completionHandler(true)
                    }
                    
                } else {
                    completionHandler(false)
                }
                
                
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "auth/update-profile/language", error: jsonerror.localizedDescription, code: "")
                completionHandler(false)
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
//            ANLoader.hide()
            completionHandler(false)
            print("error parsing json objects",error)
        }
    }
    
    
    func logAPIError(url: String, error: String, code: String) {
        DispatchQueue.global(qos: .background).async {
        // testing
        // report only 500 and 503 for now
        var report = false
        if code == "500" || code == "503" {
            report = true
        }
        if report == false {
            return
        }
        
        
        let code = Int(code) ?? 0
        if (code < 300) {
            return
        }
        
        let deviceID =  UIDevice.current.identifierForVendor?.uuidString ?? ""
        let userToken = UserDefaults.standard.value(forKey: Constant.UD_userToken) ?? ""
        
        if userToken as! String == "" {
            
            let keysAndValues = [
                "API_Base" : WebserviceManager.shared.APP_BUILD_TYPE.rawValue,
                "version" : WebserviceManager.shared.API_VERSION,
                "error": error,
                "code": code,
                "token": ""
            ] as [String : Any]
            
            //            NSDictionary *userInfo = @{
            //                NSLocalizedDescriptionKey: NSLocalizedString(@"The request failed.", nil),
            //                NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The response returned a 404.", nil),
            //                NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Does this page exist?", nil),
            //                ProductID: @"123456";
            //                UserID: @"Jane Smith"
            //            };
            
            let error = NSError(domain: url, code: Int(code), userInfo: keysAndValues)
            Crashlytics.crashlytics().record(error: error)
            //logEvent("\(url)", parameters: keysAndValues)
            
        }
        else {
            if let user = try? JSONDecoder().decode(UserProfile.self, from: SharedManager.shared.userDetails) {
                let userid = user.id ?? ""
                let keysAndValues = [
                    "userid" : userid,
                    "API_Base" : WebserviceManager.shared.APP_BUILD_TYPE.rawValue,
                    "version" : WebserviceManager.shared.API_VERSION,
                    "Profile_Completed": user.setup ?? false ? "Yes" : "No",
                    "error": error,
                    "code": code,
                    "token": true
                ] as [String : Any]
                
                
                //                Analytics.logEvent("\(url)", parameters: keysAndValues)
                
                let error = NSError(domain: url, code: Int(code) , userInfo: keysAndValues)
                Crashlytics.crashlytics().record(error: error)
                
            } else {
                
                let keysAndValues = [
                    "userid" : "no_user_details",
                    "API_Base" : WebserviceManager.shared.APP_BUILD_TYPE.rawValue,
                    "version" : WebserviceManager.shared.API_VERSION,
                    "Profile_Completed": "No",
                    "error": error,
                    "code": code,
                    "token": true
                ] as [String : Any]
                
                //                Analytics.logEvent("\(url)", parameters: keysAndValues)
                let error = NSError(domain: url, code: Int(code) , userInfo: keysAndValues)
                Crashlytics.crashlytics().record(error: error)
                
            }
            
        }
    }
        
        
    }
    
    
    // MARK: - Get Comments Count
    func performWSToGetCommentsCount(id:String, completionHandler: @escaping (_ social: Info?) -> Void) {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)
        
        //        ANLoader.showLoading()
        WebService.URLResponse("news/articles/\(id)/social", method: .get, parameters: nil, headers: token, withSuccess: { (response) in
            ANLoader.hide()
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(socialData.self, from: response)
                
                
                if let info = FULLResponse.info {
                    completionHandler(info)
                } else {
                    completionHandler(nil)
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: "news/articles/\(id)/social", error: jsonerror.localizedDescription, code: "")
                completionHandler(nil)
                print("error parsing json objects",jsonerror)
            }
            
        }) { (error) in
            completionHandler(nil)
            print("error parsing json objects",error)
        }
    }
    
    
    
    func openWebPageViewController(parentVC: UIViewController, pageUrlString: String, isPresenting: Bool) {
        
        var formatString = pageUrlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        if formatString?.lowercased().hasPrefix("http://") == false && formatString?.lowercased().hasPrefix("https://") == false {
            formatString = "http://" + (formatString ?? "")
        }
        
        if let url = URL(string: formatString ?? "") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = false
            config.barCollapsingEnabled = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            if isPresenting {
                parentVC.present(vc, animated: true)
            } else {
                parentVC.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func saveAllVideosThumbnailsToCache(imageURL: String?) {
//        if let url = URL(string: imageURL ?? "") {
//            SDWebImageManager.shared.loadImage(with: url, options: .highPriority, progress: nil) { image, data, error, cacheType, status, url in
//                if error == nil {
////                    print("image downloaded successfully \(cacheType), \(status), \(url?.absoluteString ?? "")")
////                    if let cacheKey = SDWebImageManager.shared.cacheKey(for: url) {
////                        SDWebImageManager.shared.imageCache.queryImage(forKey: cacheKey, options: [], context: nil, cacheType: .all) { image, data, typ in
////
////                            if image != nil {
////                                print("image present in cache")
////                            }
////
////                        }
////                    }
//                    
//                }
//            }
//        }
    }
    
    func loadImageFromCache(imageURL: String?, completionHandler: @escaping (_ image: UIImage?) -> Void) {
        
//        if let url = URL(string: imageURL ?? "") {
//            if let cacheKey = SDWebImageManager.shared.cacheKey(for: url) {
//               let _ = SDWebImageManager.shared.imageCache.queryImage!(forKey: cacheKey, options: [], context: nil, cacheType: .all) { image, data, typ in
//                    completionHandler(image)
//                }
//            }
//        }
    }
 
    func getImageFrom(gradientLayer:CAGradientLayer) -> UIImage? {
        var gradientImage:UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }
    
    
    func getGradient(viewGradient: UIView,colours: [UIColor], locations: [NSNumber]?, startPoint: CGPoint?, endPoint: CGPoint?) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = viewGradient.bounds
        gradient.colors = colours.map { $0.cgColor }
        // top to bottom gradient
        gradient.locations = locations
        // Linear
        if startPoint != nil && endPoint != nil {
            gradient.startPoint = startPoint!
            gradient.endPoint = endPoint!
        }
        gradient.name = "gradient"
        return gradient
    }
    
    
    func formatPoints(num: Double) ->String{
        var thousandNum = num/1000
        var millionNum = num/1000000
        if num >= 1000 && num < 1000000{
            if(floor(thousandNum) == thousandNum){
                return("\(Int(thousandNum))k")
            }
            return("\(thousandNum.roundToPlaces(places: 1))k")
        }
        if num > 1000000{
            if(floor(millionNum) == millionNum){
                return("\(Int(thousandNum))k")
            }
            return ("\(millionNum.roundToPlaces(places: 1))M")
        }
        else{
            if(floor(num) == num){
                return ("\(Int(num))")
            }
            return ("\(num)")
        }

    }
    
    func formatLabel(label: UILabel, with message: String) {
        
        let fontName = "Muli-Regular"
        let fontSize = 16.0
        let defaultFont = "Muli-Bold"
        let defaultSize = 16.0

        let htmlStyle = "<style> p {color:\(MyThemes.current == .dark ? "white" : "black"); font-family:\(fontName); font-size:\(fontSize)px;} b {color:\(MyThemes.current == .dark ? "white" : "black"); font-family:\(defaultFont); font-size:\(defaultSize)px;} </style>"
        
        let html = "\(htmlStyle)<p>\(message)</p>"
//        let formattedText = //String.format(strings: ["view more"], inString: "<p>" + message + "</p>)
        label.attributedText = html.htmlToAttributedString
        label.numberOfLines = 0
//       let tap = UITapGestureRecognizer(target: self, action: #selector(handleTermTapped))
//        label.addGestureRecognizer(tap)
//        label.isUserInteractionEnabled = true
//        label.textAlignment = .center
        
        
    }
    
    
    func performWSToUpdateUserFollow(vc: UIViewController? = nil, id:[String], isFav: Bool, type: followType, completionHandler: @escaping CompletionHandler) {
        
        if let vc = vc, !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertView(source: vc, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString(ApplicationAlertMessages.kMsgInternetNotAvailable, comment: ""))
            completionHandler(false)
            return
        }
        
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        var params = ["topics":id]
        var url = !isFav ? "news/topics/unfollow" : "news/topics/follow"
        if type == .sources {
            params = ["sources":id]
            url = !isFav ? "news/sources/unfollow" : "news/sources/follow"
        }
        if type == .locations {
            params = ["locations":id]
            url = !isFav ? "news/locations/unfollow" : "news/locations/follow"
        }
        if type == .authors {
            params = ["authors":id]
            url = !isFav ? "news/authors/unfollow" : "news/authors/follow"
        }
         
        WebService.URLResponseJSONRequest(url, method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateTopicDC.self, from: response)
                
                if FULLResponse.message == "Success" {
//                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.isDiscoverTabReload = true
                    SharedManager.shared.isForYouTabReelsReload = true
                    SharedManager.shared.isFollowingTabReelsReload = true
                    
                   completionHandler(true)
                } else {
                    completionHandler(false)
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                completionHandler(false)
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            
            completionHandler(false)
            print("error parsing json objects",error)
        }
    }
    
    func performWSToUpdateUserBlock(vc: UIViewController? = nil, id:[String], isBlock: Bool, type: followType, completionHandler: @escaping CompletionHandler) {
        
        if let vc = vc, !(SharedManager.shared.isConnectedToNetwork()){
            
            SharedManager.shared.showAlertView(source: vc, title: NSLocalizedString(ApplicationAlertMessages.kAppName, comment: ""), message: NSLocalizedString(ApplicationAlertMessages.kMsgInternetNotAvailable, comment: ""))
            completionHandler(false)
            return
        }
        
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken) ?? ""
        var params = ["topics":id]
        var url = !isBlock ? "news/topics/unblock" : "news/topics/block"
        if type == .sources {
            params = ["sources":id]
            url = !isBlock ? "news/sources/unblock" : "news/sources/block"
        }
        if type == .locations {
            params = ["locations":id]
            url = !isBlock ? "news/locations/unblock" : "news/locations/block"
        }
        if type == .authors {
            params = ["authors":id]
            url = !isBlock ? "news/authors/unblock" : "news/authors/block"
        }
        
        WebService.URLResponseJSONRequest(url, method: .post, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(updateTopicDC.self, from: response)
                
                if FULLResponse.message == "Success" {
//                    SharedManager.shared.isTabReload = true
                    SharedManager.shared.isDiscoverTabReload = true
                    SharedManager.shared.isForYouTabReelsReload = true
                    SharedManager.shared.isFollowingTabReelsReload = true
                    
                   completionHandler(true)
                } else {
                    completionHandler(false)
                }
                
            } catch let jsonerror {
                
                SharedManager.shared.logAPIError(url: url, error: jsonerror.localizedDescription, code: "")
                completionHandler(false)
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in
            
            completionHandler(false)
            print("error parsing json objects",error)
        }
    }
    
    
    func performWSToGetReelsData(completionHandler: @escaping CompletionHandler) {
        
        let token  = UserDefaults.standard.string(forKey: Constant.UD_userToken)

        let params = [
            "page": "",
            "type": "FOR_YOU",
            "tag": ""
        ] as [String : Any]
        
        WebService.URLResponse("news/reels", method: .get, parameters: params, headers: token, withSuccess: { (response) in
            
            do{
                let FULLResponse = try
                    JSONDecoder().decode(ReelsModel.self, from: response)
                                
                if let reelsData = FULLResponse.reels, reelsData.count > 0 {
                                        
                    //write Cache Codable types object reels
                    do {
                        try DataCache.instance.write(codable: FULLResponse, forKey: Constant.CACHE_REELS)
                    } catch {
                     }
                }
                completionHandler(true)
                
            } catch let jsonerror {
                SharedManager.shared.logAPIError(url: "news/reels", error: jsonerror.localizedDescription, code: "")
                print("error parsing json objects",jsonerror)
                completionHandler(true)
            }
        }) { (error) in
            print("error parsing json objects",error)
            completionHandler(true)
        }
    }
    
    func minutesBetweenDates(_ oldDate: Date, _ newDate: Date) -> CGFloat {

        //get both times sinces refrenced date and divide by 60 to get minutes
        let newDateMinutes = newDate.timeIntervalSinceReferenceDate/60
        let oldDateMinutes = oldDate.timeIntervalSinceReferenceDate/60

        //then return the difference
        return CGFloat(newDateMinutes - oldDateMinutes)
    }
    
    
    
    func showLoaderInWindow() {
        
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.keyWindow else {
                return
            }
            if self.viewAnimation == nil {
                self.viewAnimation = AppLoaderView(frame: window.bounds)
                window.addSubview(self.viewAnimation!)
                self.viewAnimation!.backgroundColor = UIColor.black
            }
        }
        
    }
    
    func hideLaoderFromWindow() {
        
        DispatchQueue.main.async {
            self.viewAnimation?.stopAnimations()
            self.viewAnimation?.removeFromSuperview()
            
            self.viewAnimation = nil
        }
        
    }
    
    
    func showBlockingLoader(isShowOnWindow: Bool = true) {
        
        if isShowOnWindow {
            DispatchQueue.main.async {
                guard let window = UIApplication.shared.keyWindow else {
                    return
                }
                window.startBlockingActivityIndicator()
            }
        }
        
        
    }
    
    func hideBlockingLoader(isAnimated: Bool = true) {
        
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.keyWindow else {
                return
            }
            window.hideBlockingActivityIndicator(isAnimated: isAnimated)
        }
        
    }
    
    func cancelAllCurrentAlamofireRequests() {
        
        Alamofire.Session.default.session.getTasksWithCompletionHandler({ dataTasks, uploadTasks, downloadTasks in
                dataTasks.forEach { $0.cancel() }
                uploadTasks.forEach { $0.cancel() }
                downloadTasks.forEach { $0.cancel() }
        })
    }
    
    
    // MARK: - Show Alert loader
    // replaceement to toast
    func showAlertLoader(message: String, closeText: String = "",type: CommonAlertView.alertType = .alert, isAutoDismiss: Bool = true ) {
        
        /*
        if let vc = (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController {
            if vc.view.viewWithTag(8888) != nil {
                return
            }
            let alertView = CommonAlertView(frame: CGRect(x: 0, y: 0, width: vc.view.frame.size.width, height: 200))
            alertView.tag = 8888
            alertView.message = NSLocalizedString("\(message)", comment: "")
            alertView.selectedUIType = type
            alertView.closeButtonText = closeText
            alertView.isAutoDismiss = isAutoDismiss
            
            vc.view.addSubview(alertView)
            vc.view.bringSubviewToFront(alertView)
            
        }*/
        if let viewWindow = (UIApplication.shared.keyWindow) {
            if viewWindow.viewWithTag(8888) != nil {
                return
            }
            let alertView = CommonAlertView(frame: CGRect(x: 0, y: 0, width: viewWindow.frame.size.width, height: 200))
            alertView.tag = 8888
            alertView.message = NSLocalizedString("\(message)", comment: "")
            alertView.selectedUIType = type
            alertView.closeButtonText = closeText
            alertView.isAutoDismiss = isAutoDismiss
            
            viewWindow.addSubview(alertView)
            viewWindow.bringSubviewToFront(alertView)
            
        }
        
    }
    
    
    
    func getFamilyName(font: AppFont?)-> String {
        
        var  style = font?.style ?? ""
        style = style.isEmpty ? "regular" : style
        
        if font?.family?.lowercased() == "roboto" {
            if style == "bold" {
                style = Constant.FONT_ROBOTO_BOLD
            }
            else if style == "italic" {
                style = Constant.FONT_ROBOTO_ITALIC
            }
            else {
                style = Constant.FONT_ROBOTO_REGULAR
            }
        }
        else if font?.family?.lowercased() == "mulli" {
            if style == "bold" {
                style = Constant.FONT_Mulli_BOLD
            }
            else {
                style = Constant.FONT_Mulli_REGULAR
            }
        }
        else if font?.family?.lowercased() == "martel" {
            if style == "bold" {
                style = Constant.FONT_Martel_BOLD
            }
            else {
                style = Constant.FONT_Martel_REGULAR
            }
        }
        else if font?.family?.lowercased() == "sarala" {
            if style == "bold" {
                style = Constant.FONT_Sarala_BOLD
            }
            else {
                style = Constant.FONT_Sarala_REGULAR
            }
        }
        
        
        return style
        
    }
    
    
    
}


//extension UIFont {
//    class func printFontNames() {
//        for family in UIFont.familyNames {
//            let fonts = UIFont.fontNames(forFamilyName: family)
//
//            print("Family: ", family, "Font Names: ", fonts)
//        }
//    }
//}
