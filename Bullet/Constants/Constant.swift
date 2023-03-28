//
//  Constant.swift
//  Bullet
//
//  Created by Khadim Hussain on 02/05/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import Foundation
import UIKit

class Constant {

//    Development Environment
//    Auth:
//    https://account.dev.bullets.app
//
//    Backend API:
//    https://api.dev.bullets.app
    
//    client_id: YiVGPipYhfY7jb6
//    client_password: Dh3JlIyL3BkA3No9JKx2ZpAGfMmrfc
    
            
//    Use api.staging.bullets.app and account.staging.bullets.app for temporary staging access
    struct Staging {
        
        static let apiBase = "https://api.test.bullets.app/"//"https://api.staging.bullets.app/"//"https://api.dev.bullets.app/"
        static let authBaseURL = "https://account.test.bullets.app/"//"https://account.staging.bullets.app/"//"https://account.dev.bullets.app/"
        static let authTokenURL = authBaseURL + "oauth/token"
        
        static let appClientID = "YiVGPipYhfY7jb6"
        static let appClientSecret = "Dh3JlIyL3BkA3No9JKx2ZpAGfMmrfc"
        static let googleClientID = "709274277066-s297ov3fk0444eul8bedmubl4h98kpkk.apps.googleusercontent.com"
    }
    
    struct Production {
        
        static let apiBase = "https://api.bullets.app/"
        static let authBaseURL = "https://account.bullets.app/"
        static let authTokenURL = authBaseURL + "oauth/token"
        
        static let appClientID = "zvrRTNKY0An6YuC"
        static let appClientSecret = "v8BV52pOl8HdWGSuGWoNdnJzP4U4vr"
        static let googleClientID = "883200977297-v760ap6sa48thpd1r4u5pf1kpbtfn0ia.apps.googleusercontent.com"
        
    }

//    static let APP_TOKEN_URL = "https://nib.us.auth0.com/oauth/token"
//    static let APP_CLIENT_ID = "a5scsV7j86bluLrgtQ7yIfBSGFSZeJAp"
    
//    static let authClientID = "a5scsV7j86bluLrgtQ7yIfBSGFSZeJAp"
//    static let authDomain = "nib.us.auth0.com"
//    static let authAudienceURL = "https://api.newsinbullets.app"
    
    //MARK: - User Defaults Constances
    static let UD_firebaseToken = "firebaseToken"
    static let UD_userId = "userId"
    static let UD_userToken = "userToken1"
    static let UD_userEmail = "userEmail"
    static let UD_userSetup = "userSetup"
    static let UD_userPassword = "userPassword"
    static let UD_refreshToken = "refreshToken"
    static let UD_topicsList = "topicsList"
    static let UD_isLocalTheme = "isLocalTheme"
    static let UD_isSocialLinked = "isSocialLinked"
    static let UD_isHapticOn = "isHapticOn"
    static let UD_languageId = "languageId"
    static let UD_languageSelected = "languageSelected"
    static let UD_languageFlag = "languageFlag"
    static let UD_adsAvailable = "adsAvailable"
    static let UD_adsUnitKey = "adsUnitKey"
    static let UD_adsUnitFeedKey = "UD_adsUnitFeedKey"
    static let UD_appLanguageName = "appLanguageName"
    static let UD_adsUnitReelKey = "UD_adsUnitReelKey"
    static let UD_adsType = "adsType"
    static let ratingTimeIntervel = "ratingTimeIntervel"
//    static let isForYouSelected = "isForYouSelected"
    static let isReelsVolumeMute = "isReelsVolumeMute"
    static let reelsCategoryId = "reelsCategoryId"
    static let articlesCategoryId = "articlesCategoryId"
    static let tabBarIndex = "tabBarIndex"
    static let userSavedDetails = "userSavedDetails"
    static let fontSizeType = "fontSizeType"
    static let guestUser = "guestUser"
    static let linkedUser = "linkedUser"
    static let UD_WalletLink = "wallet"
    
    static let UD_new_secondary_language = "UD_new_secondary_language"

    static let UD_new_languageSelected = "UD_new_languageSelected"
    static let UD_new_region_Selected = "UD_new_region_Selected"
    static let UD_new_has_selected_language = "UD_new_has_selected_language"

    static let UD_isCaptionsEnableReels = "isCaptionsEnableReels"
    static let UD_isAudioEnable = "isAudioEnable"
    static let UD_isAudioEnableReels = "UD_isAudioEnableReels"
    static let UD_isDataSaver = "isDataSaver"
    static let UD_isReelsAutoPlay = "reelsAutoPlay"
    static let UD_isBulletsAutoPlay = "bulletsAutoPlay"
    static let UD_isReaderMode = "readerMode"
    static let UD_filterType = "filterType"
    static let UD_refreshFeedOnKillApp = "refreshFeedOnKillApp"
    static let UD_refreshReelsOnKillApp = "refreshReelsOnKillApp"
    static let UD_isOnBoardingScreenLoaded = "isOnBoardingScreenLoaded"
    static let UD_AppFirstEverLaunch = "UD_AppFirstEverLaunch"
    static let Selected_Reel_Category = "Selected_Reel_Category"
    static let isReelsFollowingNeedRefresh = "isReelsFollowingNeedRefresh"
    
    //Static Types
    static let TYPE_TOPIC = "TOPIC"
    static let TYPE_SOURCE = "SOURCE"
    static let STATUS_SUCCESS = "SUCCESS"
    static let STATUS_SUCCESS_LIKE = "Article liked successfully"
    static let isAppOnboardScreensLoaded = "isAppOnboardScreensLoaded"
    static let isOnboardingPreferenceLoaded = "isOnboardingPreferenceLoaded"
    
    static let lastModifiedTimeArticlesForYou = "lastModifiedTimeArticlesForYou"
    static let lastModifiedTimeArticlesFollowing = "lastModifiedTimeArticlesFollowing"
    
    //Cache type
    static let CACHE_ARTICLES_CATEGORIES  = "ARTICLES_CATEGORIES"
    static let CACHE_HOME_CATEGORIES  = "HOME_CATEGORIES"
    static let CACHE_HOME_TOPICS      = "HOME_TOPICS"
    static let CACHE_HOME_SOURCES     = "HOME_SOURCES"
    static let CACHE_HOME_AUTHORS     = "HOME_AUTHORS"
    static let CACHE_REELS            = "CACHE_REELS"
    static let CACHE_REELS_Follow            = "CACHE_REELS_Follow"

    static let CACHE_HOME_ARTICLES = "HOME_ARTICLES"
    static let CACHE_HOME_ARTICLES_FOLLOWING = "HOME_ARTICLES_FOLLOWING"
    static let CACHE_COMMUNITY_FEED_ARTICLES = "COMMUNITY_FEED_ARTICLES"
    static let CACHE_DISCOVER_PAGE = "DISCOVER_PAGE"
    static let CACHE_UploadTask = "uploadTask"
    
    
    static let cellColors = ["E01335","5025E1","975D1B","E13300","641E58","83A52C","1E3264", "850000", "15B9C5"]

    //MARK:- Font

    static let font_SelectedTitle = UIFont(name: FONT_Mulli_Semibold, size: 20)!
    static let font_unSelectedTitle = UIFont(name: FONT_Mulli_Semibold, size: 14)!

    
    static let FONT_Bullet_SEMI_BOLD = UIFont(name: FONT_Mulli_Semibold, size: 14)!
    
    // MARK: - Mulli Font
    static let FONT_Mulli_BLACK = "Muli-Black"
    static let FONT_Mulli_EXTRABOLD = "Muli-ExtraBold"
    static let FONT_Mulli_BOLD = "Muli-Bold"
    static let FONT_Mulli_REGULAR = "Muli-Regular"
    static let FONT_Mulli_Semibold = "Muli-SemiBold"
    
    static let FONT_ROBOTO_BLACK = "Roboto-Black"
    static let FONT_ROBOTO_BOLD = "Roboto-Bold"
    static let FONT_ROBOTO_REGULAR = "Roboto-Regular"
    static let FONT_ROBOTO_ITALIC = "Roboto-Italic"
    static let FONT_ROBOTO_MEDIUM = "Roboto-Medium"
    
    static let FONT_ProximaNova_BLACK = "ProximaNova-Black"
    static let FONT_ProximaNova_BOLD = "ProximaNova-Extrabld"
    static let FONT_ProximaNova_REGULAR = "ProximaNova-Regular"
    static let FONT_ProximaNova_Thin = "ProximaNova-Thin"
    static let FONT_ProximaNova_MEDIUM = "ProximaNova-Bold"
    
    
    static let FONT_Martel_BOLD = "Martel-Bold"
    static let FONT_Martel_REGULAR = "Martel-Regular"
    
    static let FONT_Sarala_BOLD = "Sarala-Bold"
    static let FONT_Sarala_REGULAR = "Sarala-Regular"
    
    static let FONT_Oswald_Bold = "Oswald-Bold"
    static let FONT_Gilroy_ExtraBold = "Gilroy-ExtraBold"
    
    
    static let tabFont = UIFont(name: FONT_Mulli_Semibold, size: 11)!
    static let tabFontSmall = UIFont(name: FONT_Mulli_Semibold, size: 10)!

    //color for app
    struct appColor {
        
        static let followBackgroundColor = UIColor(displayP3Red: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1)
        
        static let backgroundGray = UIColor(displayP3Red: 245.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1)
        
        static let lightRed = UIColor(displayP3Red: 0.969, green: 0.204, blue: 0.345, alpha: 1)
        static let lightBlue = UIColor(displayP3Red: 103.0/255.0, green: 104.0/255.0, blue: 171.0/255.0, alpha: 1)
        static let lightGray = UIColor(displayP3Red: 0.871, green: 0.908, blue: 0.95, alpha: 1)
        static let darkGray = UIColor(displayP3Red: 0.138, green: 0.125, blue: 0.292, alpha: 1)
        static let mediumGray = UIColor(displayP3Red: 0.42, green: 0.393, blue: 0.463, alpha: 1)
        
        static let purple = UIColor(displayP3Red: 224.0/255.0, green: 19.0/255.0, blue: 53.0/255.0, alpha: 1) // rgba(224, 19, 53, 1)
        static let customGrey = UIColor(displayP3Red: 132/255.0, green: 131/255.0, blue: 139/255.0, alpha: 1)
        static let btnCustomGrey = UIColor(displayP3Red: 43/255.0, green: 42/255.0, blue: 47/255.0, alpha: 1)
        static let blue = UIColor(displayP3Red: 250.0/255.0, green: 8.0/255.0, blue: 21.0/255.0, alpha: 1) //rgba(250, 8, 21, 1)
        
        static let buttonLightGaryText = UIColor(displayP3Red: 0.744, green: 0.793, blue: 0.846, alpha: 1)
        
        static let buttonUnselected = UIColor(displayP3Red: 0.744, green: 0.793, blue: 0.846, alpha: 1)
        
        static let shadowColorDark = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.1)
        
        static let borderGray = UIColor(displayP3Red: 0.91, green: 0.922, blue: 0.925, alpha: 1)
        
        
        
//        static let shadowColorDark = UIColor(displayP3Red: 0.744, green: 0.793, blue: 0.846, alpha: 1)
    }
    
    //App Grediant Colors for ForYou Page
    struct appDarkThemeGrediant {
 
        static let StartColor = UIColor(displayP3Red: 19.0/255.0, green: 19.0/255.0, blue: 19.0/255.0, alpha: 1)
        static let MidColor = UIColor(displayP3Red: 40.0/255.0, green: 39.0/255.0, blue: 39.0/255.0, alpha: 1)
        static let EndColor = UIColor(displayP3Red: 59.0/255.0, green: 58.0/255.0, blue: 58.0/255.0, alpha: 1)
    }
    struct appLightThemeGrediant {
 
        static let StartColor = UIColor(displayP3Red: 233.0/255.0, green: 233.0/255.0, blue: 233.0/255.0, alpha: 1)
        static let MidColor = UIColor(displayP3Red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1)
        static let EndColor = UIColor(displayP3Red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
    }
    
    struct font {
        
        static let font_Bold = UIFont(name: FONT_Mulli_Semibold, size: 16)
        static let font_SemiBold = UIFont(name: FONT_Mulli_Semibold, size: 16)
        static let font_Bold_activity = UIFont(name: FONT_Mulli_Semibold, size: 12)
    }
    
    enum DiscoverTypes: String {
        case REELS,TOPICS,ARTICLE,ARTICLES,PLACES,CHANNELS,AUTHORS,ARTICLE_VIDEOS
    }
    
    //MARK: - Analytics Events
    struct analyticsEvents {
        
        //static let NewZealandiOSVoluum = "New_Zealand_iOS_Voluum"
        static let appInstall = "app_install"
        static let appOpen = "app_open"
        static let signUpClick = "sign_up_click"
        static let googleSignup = "google_signup"
        static let facebookSignup = "facebook_signup"
        static let appleidSignup = "appleid_signup"
        static let signinClick = "signin_click"
        static let homePageClick = "home_page_click"
        static let articleOpen = "articleOpen"
        static let swipeNext = "swipe_next"
        //static let articleSwipeLeft = "article_swipe_left"
        //static let articleSwipeRight = "article_swipe_right"
        static let sourceOpen = "source_open"
        static let shareClick = "share_click"
        static let moreLikeThisClick = "more_like_this_click"
        static let lessLikeThisClick = "less_like_this_click"
        static let reportClick = "report_click"
        static let mute = "mute"
        static let unmute = "unmute"
        static let readingSpeedClick = "reading_speed_click"
        static let headlinesOnly = "headlines_only"
        static let headlinesBullets = "headlines_bullets"
        static let sourcePageClick = "source_page_click"
        static let topicPageClick = "topic_page_click"
        static let searchPageClick = "search_page_click"
        static let accountPageClick = "account_page_click"
        static let reelsPageClick = "reels_page_click"
        static let followTopic = "follow_topic"
        static let followSource = "follow_source"
        static let unfollowedTopic = "unfollowed_topic"
        static let unfollowedSource = "unfollowed_source"
        static let blockTopic = "block_topic"
        static let blockSource = "block_source"
        static let unblockopic = "unblock_topic"
        static let blockauthor = "block_author"
        static let unblockauthor = "unblock_author"
        static let unblockSource = "unblock_source"
        static let changeEmail = "change_email"
        static let changePassword = "change_password"
        static let aboutClick = "about_click"
        static let pushForeground = "push_foreground"
        static let pushBackgroud = "push_backgroud"
        static let pushAppkill = "push_appkill"
        static let helpCenter = "help_center"
        static let topicOpen = "topic_open"
        static let lightMode = "light_mode"
        static let darkMode = "dark_mode"
        static let autoMode = "auto_mode"
        static let policyClick = "policy_click"
        static let termsClick = "terms_click"
        static let logout = "logout"
        static let page_time = "pageTime"
        static let widgetOpen = "widget_open"
        static let widgetMoreLikeThis = "widget_more_like_this"
        static let pushClicks = "push_clicks"
        static let appNotCrashed = "app_not_crashed"
        static let appCrashed = "app_crashed"
        
        static let notificationOpenArticle = "notification_open_article"
        static let notificationOpenReel = "notification_open_reel"
        static let notificationOpenVideo = "notification_open_video"
        static let notificationReceive = "notification_receive"
        static let notificationDismiss = "notification_dismiss"
        //static let screenViewExpanded = "screen_view_expanded"
        //static let screenViewList = "screen_view_list"
        static let expandNextAuto = "expand_next_auto"
        static let listNextAuto = "list_next_auto"
        static let regSelectLanguage = "reg_select_language"
        static let regSelectSource = "reg_select_source"
        static let regSelectEdition = "reg_select_edition"
        static let regSelectTopic = "reg_select_topic"
        static let tutorialStart = "tutorial_start"
        static let tutorialFinish = "tutorial_finish"
        static let articleHero = "article_hero"

        //NEW EVENT
        static let videoFinishedPlaying = "ARTICLE_VIDEO_COMPLETE"
        static let reelsFinishedPlaying = "REEL_COMPLETE"
        static let articleDetailsPageOpened = "ARTICLE_DETAIL_PAGE"
        static let articleViewed = "ARTICLE_VIEW"
        static let reelViewed = "REEL_VIEW"
        static let articleSwipeEvent = "ARTICLE_SWIPE"
        static let videoDurationEvent = "VIDEO_DURATION"
        static let reelsDurationEvent = "REEL_DURATION"
        
        
        static let archiveClick = "archive_click"
        static let cfReportclick = "cf_report_click"
        static let datasaverBulletsAutoPlay = "datasaver_bulletsap"
        static let datasaverReelsAutoPlay = "datasaver_reelsap"
        static let datasaverVideoAutoPlay = "datasaver_videosap"
        static let datasaverReaderModeAutoPlay = "datasaver_readermode"
        static let discoverDailyroundupClick = "discover_dailyroundup_click"
        
        
        static let discoverChannelFollow = "discover_channel_follow"
        static let discoverChannelOpen = "discover_channel_open"
        static let discoverChannelUnfollow = "discover_channel_unfollow"
        
        
        static let discoverTopicsOpen = "discover_topics_open"
        static let discoverTopicsFollow = "discover_topics_follow"
        static let discoverTopicsUnfollow = "discover_topics_unfollow"
        
        static let discoverReelOpen = "discover_reel_open"
        static let discoverReelWatch = "discover_reel_watch"
        static let discoverVideosOpen = "discover_vidoes_open"
        static let discoverVideosWatch = "discover_vidoes_watch"
        
        static let feedComment = "feed_comment"
        static let feed_like = "feedLike"
        static let feedSourceOpen = "feed_source_open"
        
        static let followLocation = "follow_location"
        static let unfollowedLocation = "unfollowed_location"
        
        static let followAuthor = "follow_author"
        static let unfollowedAuthor = "unfollowed_author"
        
        static let logoutClick = "logout_click"
        
    }
    
    struct newsArticle {
        
        static let FEED_NEW_POST                           = "NEW_POST"
        static let FEED_ARTICLE_HERO                       = "ARTICLE_HERO"
        static let FEED_ARTICLE_HORIZONTAL                 = "ARTICLE_HORIZONTAL"
        static let FEED_ARTICLE_LIST                       = "ARTICLE_LIST"
        static let FEED_REELS                              = "REELS"
        static let FEED_ADS                                = "ADS"
        static let FEED_TOPICS                             = "TOPICS"
        static let FEED_CHANNELS                           = "CHANNELS"



        static let ARTICLE_TYPE_YOUTUBE                    = "YOUTUBE"
        static let ARTICLE_TYPE_ADS                        = "ADS"
        static let ARTICLE_TYPE_EXTENDED                   = "EXTENDED"
        static let ARTICLE_TYPE_SIMPLE                     = "SIMPLE"
        static let ARTICLE_TYPE_VIDEO                      = "VIDEO"
        static let ARTICLE_TYPE_HEADER                     = "HEADER"
        static let ARTICLE_TYPE_FOOTER                     = "FOOTER"
        static let ARTICLE_TYPE_IMAGE                      = "IMAGE"
        static let ARTICLE_TYPE_REEL                       = "REEL"


        static let ARTICLE_STATUS_SCHEDULED                = "SCHEDULED"
        static let ARTICLE_STATUS_PROCESSING               = "PROCESSING"
        static let ARTICLE_STATUS_DRAFT                    = "DRAFT"
        static let ARTICLE_STATUS_PUBLISHED                = "PUBLISHED"


        static let ARTICLE_TYPE_SUGGESTED_TOPICS           = "SUGGESTED_TOPICS"
        //let ARTICLE_TYPE_SUGGESTED_FEED             = "SUGGESTED_FEED"
        static let ARTICLE_TYPE_SUGGESTED_CHANNELS         = "SUGGESTED_CHANNELS"
        static let ARTICLE_TYPE_SUGGESTED_REELS            = "SUGGESTED_REELS"
        static let ARTICLE_TYPE_SUGGESTED_AUTHORS          = "SUGGESTED_AUTHORS"
        static let ARTICLE_TYPE_FEED_FOOTER                = "FEED_FOOTER"
        static let ARTICLE_TYPE_RELATED_CELL               = "RELATED_CELL"
        static let ARTICLE_TYPE_LARGE_REEL                 = "LARGE_REELS"
        static let ARTICLE_TYPE_CAROUSEL_VIDEOS            = "ARTICLE_VIDEOS"
        
        
        static let BOTTOM_INSET: CGFloat                   = 2000
        
    }
    
    struct commonCellSize {
        
        static let normalMenuItemHeight: CGFloat = 60
        static let extendedMenuItemHeight: CGFloat = 120
        
    }
    
}


class ImageLoader: UIImageView {
    
    public func loadImageWith(from urlString: String, completion: @escaping (Bool, UIImage) -> ()) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(false, UIImage())
                return
            }
            DispatchQueue.main.async {
                if let imageToCache = UIImage(data: data) {
                    completion(true, imageToCache)
                } else {
                    completion(false, UIImage())
                }
            }
        }.resume()
    }
}

let Oauth2Keys =
[
    "consumerKey": "",
    "consumerSecret": ""
]

struct ApplicationAlertMessages {
    
    static let kAppName = NSLocalizedString("Newsreels", comment: "")
    static let kMsgInternetNotAvailable = NSLocalizedString("Check your internet Connection and try again.", comment: "")
    static let kMsgSomethingWentWrong = NSLocalizedString("Oops! Something went wrong. Please try again.", comment: "")
    static let kMsgAddToFavorite = NSLocalizedString("Saved", comment: "")
    static let kMsRemoveFromFavorite = NSLocalizedString("Removed from Saved", comment: "")
    static let kMsgUnableToLoadImage = NSLocalizedString("Image not loading...", comment: "")
    static let kMsgSavedVideoSuccessfully = NSLocalizedString("video saved successfully", comment: "")
    
}


