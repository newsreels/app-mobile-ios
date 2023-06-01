//
//  GlobalPicker.swift
//  Demo
//
//  Created by Gesen on 16/3/1.
//  Copyright © 2016年 Gesen. All rights reserved.
//

import SwiftTheme
import Darwin

enum GlobalPicker {
    
     //First Position - Light Mode
     //Second Position - Dark Mode

    // Discover page
    static let backgroundDiscoverMainColor: ThemeColorPicker = ["#FBFBFB", "#121212"]//["#FAFAFA", "#090909"]
    static let backgroundDiscoverHeader: ThemeColorPicker = ["#FCFCFC", "#090909"]
    static let backgroundDiscoverBG: ThemeColorPicker = ["#F9F9F9", "#111111"]
    static let imgCloseDiscoverList: ThemeImagePicker = ["closeDiscoverListLight", "closeDiscoverListDark"]
    static let backgroundSearchBG: ThemeColorPicker = ["#F1F1F1", "#000000"]
    static let textPlaceHolderDiscover: ThemeStringAttributesPicker = [[NSAttributedString.Key.foregroundColor: "#A8A8A8".hexStringToUIColor()], [NSAttributedString.Key.foregroundColor: "#4D4D4D".hexStringToUIColor()]]
    static let textBWColorDiscover: ThemeColorPicker = ["#000", "#FFF"]
    static let textSubColorDiscover: ThemeColorPicker = ["#84838B", "#575757"]
    static let discoverLeftGradient: ThemeImagePicker = ["gradientLeftLight", "gradientLeft"]
    static let discoverRightGradient: ThemeImagePicker = ["gradientRightLight", "gradientRight"]

    
    //Color for news top headers
    static let newsHeaderBGColor: ThemeColorPicker = ["#F3F3F3", "#0E0E0E"]
    static let newsSelectedButtonBGColor: ThemeColorPicker = ["#FCFCFC", "#1A1A1A"]
    static let btnEditionImg: ThemeImagePicker = ["editionLight", "editionDark"]
    static let dividerLineBG: ThemeColorPicker = ["#d8d9d8", "#2B2A2F"]
    
//    static let btnListViewTypeImage: ThemeImagePicker = ["viewTypeListLight", "viewTypeListDark"]
//    static let btnViewTypeImage: ThemeImagePicker = ["viewTypeLight", "viewTypeDark"]
    static let btnSubCategoryImage: ThemeImagePicker = ["subCatMenuLight", "subCatMenuDark"]
    static let subCategoryCellBGColor: ThemeColorPicker = ["#E7E7E7", "#1A1A1A"]
    static let subCategoryHeaderBGColor: ThemeColorPicker = ["#F3F3F3", "#0E0E0E"]
    static let subCategoryTxtColor: ThemeColorPicker = ["#393737", "#FFFFFF"]
    
    
    //Theme selection screen colors
 //   static let themeImage: ThemeImagePicker = ["themeLight", "themeDark"]
    
    //post article images
    static let imgPostTopic: ThemeImagePicker = ["icn_post_topic_light", "icn_post_topic_dark"]
    static let imgPostPlace: ThemeImagePicker = ["icn_post_place_light", "icn_post_place_dark"]
    static let imgPostLanguage: ThemeImagePicker = ["icn_post_language_light", "icn_post_language_dark"]

    //ads
    static let adsButtonBGColor: ThemeColorPicker = ["#FFFFFF", "#1A1A1A"]
    static let adsBtnTextColor: ThemeColorPicker = ["#FFFFFF", "#FFFFFF"]
    static let adsBtnSkipBGColor: ThemeColorPicker = ["#FFFFFF", "#1A1A1A"]
    static let adsIcon: ThemeImagePicker = ["adsIconLight", "adsIconDark"]
    
    static let bgLoginColor: ThemeColorPicker = ["#F2F2F2", "#1A1A1A"]
    static let textWBColor: ThemeColorPicker = ["#FFF", "#000"]
    static let bgBWColor: ThemeColorPicker = ["#000", "#FFF"]
    static let backgroundColor: ThemeColorPicker = ["#FAFAFA", "#000"] //["#FFF", "#000"]
    static let backgroundColorWhiteBlack : ThemeColorPicker = ["#FFFFFF", "#000000"]
    static let backgroundColorBlackWhite : ThemeColorPicker = ["#000000", "#FFFFFF"]
    static let backgroundColorBlackWhiteCG : ThemeCGColorPicker = ["#000000", "#FFFFFF"]
    static let backgroundColorHomeCell: ThemeColorPicker = ["#FBFBFB", "#121212"] //["#FAFAFA", "#090909"]
    static let backgroundColorMenu: ThemeColorPicker = ["#E7E9EC", "#121212"]
    static let backgroundColorEdition: ThemeColorPicker = ["#F2F2F2", "#090909"]
    static let barTextColor = ThemeColorPicker.pickerWithColors(["#FFF", "#000"])
    
    static let imgSmallUser: ThemeImagePicker = ["icn_user_profile_dark", "icn_user_profile_light"]
    static let imgUserPlaceholder: ThemeImagePicker = ["icn_profile_placeholder_light", "icn_profile_placeholder_dark"]
    static let imgCoverPlaceholder: ThemeImagePicker = ["icn_profile_cover_dark", "icn_profile_cover_dark"]
    static let imgComingSoon: ThemeImagePicker = ["icn_coming_soon_light", "icn_coming_soon_dark"]
    static let btnYoutubeImg: ThemeImagePicker = ["icn_youtube_link_light", "icn_youtube_link_dark"]
    
    static let imgNotification: ThemeImagePicker = ["NotificationLight", "NotificationDark"]
    static let imgNotificationAlert: ThemeImagePicker = ["NotificationAlertLight", "NotificationAlertDark"]
    
    static let GrayScale5: ThemeColorPicker = ["#FFFFFF", "#ADADAD"]

    static let backgroundListColor: ThemeColorPicker = ["#E7E7E7", "#1A1A1A"]
    static let successPopupBGColor: ThemeColorPicker = ["#FFF", "#181818"]
    static let searchBGViewColor: ThemeColorPicker = ["#F7F7F7", "#181818"]
    static let backgroundCardColor: ThemeColorPicker = ["#F2F2F2", "#1A1A1A"]
    
    //Following screens
    static let followingViewBGColor: ThemeColorPicker = ["#F6F6F6", "#000000"]
    static let followingCardColor: ThemeColorPicker = ["#FFFFFF", "#121212"]
    static let followingSearchBGColor: ThemeColorPicker = ["#F1F1F1", "#121212"]
    
    static let imageBorderColor: ThemeCGColorPicker = ["#FFFFFF", "#121212"]

    static let bgTopStories: ThemeColorPicker = ["#FFF", "#000"]
    
    static let bgBlackWhiteColor: ThemeColorPicker = ["#FFF", "#000"]

    // color first color for light mode and second color for dark mode for entire app
    static let barTintColor: ThemeColorPicker = ["#F5F7FA", "#000000"]
    static let tabBarTintColor: ThemeColorPicker = ["#FCFCFC", "#090909"]
    static let tabTintColorSelectedImage: ThemeColorPicker = ["#E01335", "#E01335"]
    static let tabTintColorUnSelectedImage: ThemeColorPicker = ["#697389", "#84838B"]
    
    
    static let customTabbarBGColor: ThemeColorPicker = ["#FCFCFC", "#090909"]
    static let customTabbarBGColorReels: ThemeColorPicker = ["#000000", "#000000"]
    static let btnSelectedTabbarTintColor: ThemeColorPicker = ["#FA0815", "#E01335"]
    static let btnUnselectedTabbarTintColor: ThemeColorPicker = ["#909090", "#84838B"]
    static let gradientBulletShadow: ThemeAnyPicker = [[UIColor.init(white: 1, alpha: 0).cgColor, UIColor.white.cgColor], [UIColor.init(white: 0, alpha: 0).cgColor, UIColor.black.cgColor]]
    
    static let backgroundBottomView: ThemeColorPicker = ["#FFFFFF", "#181818"]
    static let backgroundShadow: ThemeColorPicker = ["#FFFFFF", "#181818"]
    static let btnStarImg: ThemeImagePicker = ["icn_star_light", "icn_star"]
    static let arrowImage: ThemeImagePicker = ["icn_arrow_light", "icn_arrow"]
    static let imgDot: ThemeImagePicker = ["icn_more_light", "icn_more"]
    static let imgSingleDot: ThemeImagePicker = ["newsDot", "newsDot_White"]
    static let imgTimePicker: ThemeImagePicker = ["icn_timer", "icn_timer_light"]
    static let imgShare: ThemeImagePicker = ["icn_share", "icn_share"]
    static let imgWifi: ThemeImagePicker = ["icn_wifi_light", "icn_wifi"]
    static let imgListMenu: ThemeImagePicker = ["list_icon_white", "list_icon"]
    static let imgVolumeMute: ThemeImagePicker = ["volumeMute_white", "volumeMute"]
    static let imgVolume: ThemeImagePicker = ["volumeOn_White", "volumeOn"]
    static let imgSettings: ThemeImagePicker = ["icn_settings_light", "icn_settings_dark"]
    static let btnImgCamera: ThemeImagePicker = ["icn_camera_light", "icn_camera_dark"]
    static let imgMedia: ThemeImagePicker = ["icn_media_light", "icn_media_dark"]
    static let imgNewsreels: ThemeImagePicker = ["icn_newsreels_light", "icn_newsreels_dark"]
    static let imgYoutube: ThemeImagePicker = ["icn_youtube_light", "icn_youtube_dark"]
    static let imgAddBulletArrow: ThemeImagePicker = ["icn_upload_big_arrow_light", "icn_upload_big_arrow"]
    static let imgBack: ThemeImagePicker = ["icn_back2", "icn_back2"]
    
    static let imgBackDetails: ThemeImagePicker = ["BackArrowBlack","BackArrowWhite"]
    
    static let imgMoreOptions: ThemeImagePicker = ["viewMoreOptionsBlack","viewMoreOptions"]
    
    static let imgBackWithCover: ThemeImagePicker = ["iconBack_Light", "iconBack_Dark"]
    static let imgApple: ThemeImagePicker = ["icn_more_light", "icn_more"]
    static let imgErrorFollow: ThemeImagePicker = ["no_data_error_icon_light", "DarkError"]

    static let listViewSelectedBG: ThemeColorPicker = ["#E7E7E7", "#1A1A1A"]
    static let listViewUnSelectedBG: ThemeColorPicker = ["#EDF0F4", "#0D0D0D"]
    static let cellBGColor: ThemeColorPicker = ["#FFFFFF","#161616"]
    static let cellShadowColor: ThemeColorPicker = ["#3AD9D226","#000000"]
    static let cellChannelBGColor: ThemeColorPicker = ["#FFFFFF","#090909"]
    static let viewLineBGColor: ThemeColorPicker = ["#E7E9EC", "#2B2A2F"]

    static let textMainTabUnselectedColor: ThemeColorPicker = ["#909090", "#8C8B91"]
    static let textMainTabSelectedColor: ThemeColorPicker = ["#000", "#FFF"] //was ["#FA0815", "#E01335"]
    static let textMainTabSelectedLineColor: ThemeColorPicker = ["#FA0815", "#E01335"]
    static let btnCellTintColor: ThemeColorPicker = ["#909090", "#FFF"]

    static let themeCommonColor: ThemeColorPicker = ["#FA0815", "#E01335"]
    static let themeCommonColorCG: ThemeCGColorPicker = ["#FA0815", "#E01335"]
    
    static let viewSearchBGColor: ThemeColorPicker = ["#E7E7E7", "#000"] 
    static let barStyle: ThemeBarStylePicker = [.black, .default]
    static let textPlaceHolder: ThemeStringAttributesPicker = [[NSAttributedString.Key.foregroundColor: "#3D485F".hexStringToUIColor()], [NSAttributedString.Key.foregroundColor: "#FFFFFF".hexStringToUIColor()]]
    static let textPlaceHolderChannel: ThemeStringAttributesPicker = [[NSAttributedString.Key.foregroundColor: "#84838B".hexStringToUIColor()], [NSAttributedString.Key.foregroundColor: "#84838B".hexStringToUIColor()]]
    
    
//    static let statusBarStyle: ThemeStatusBarStylePicker = [.default, .lightContent]
    static let btnImgBack: ThemeImagePicker = ["icn_back_light", "Icn_back2"]
    static let ImgRegistrationLogo: ThemeImagePicker = ["logoRigistrationDark", "logoRigistration"]
    static let imgBookmark: ThemeImagePicker = ["bookmark_light", "bookmark"]
    static let imgBookmarkWB: ThemeImagePicker = ["bookmark_lightWB", "bookmarkWB"]
    static let imgBookmarkTopic: ThemeImagePicker = ["bookmarkWhite", "bookmarkWB"]
    static let imgBookmarkBottomSheet: ThemeImagePicker = ["bookmarkWhite", "bookmarkWB"]
    static let btImgMenu: ThemeImagePicker = ["icn_menu_light", "icn_menu_dark"]
    
    static let imgLocationBookmark: ThemeImagePicker = ["bookmarkDiscoverLight", "bookmarkDiscover"]
    static let imgLocationBookmarkSelected: ThemeImagePicker = ["bookmarkSelectedDiscover", "bookmarkSelectedDiscover"]

    static let imgBookmarkSelected: ThemeImagePicker = ["bookmarkSelected_light", "bookmarkSelected"]
    static let imgBookmarkSelectedWB: ThemeImagePicker = ["bookmarkSelected_lightWB", "bookmarkSelectedWB"]
    static let imgUnSelectedBookmark: ThemeImagePicker = ["unselected_light", "unselected"]
    static let imgSelectedBookmark: ThemeImagePicker = ["selected", "selected"]
    static let imgBookmarkSavedArticle: ThemeImagePicker = ["bookmarkSelected_lightWB", "bookmarkSelectedWB"]
    static let imgTag: ThemeImagePicker = ["icn_tag_light", "icn_tag_dark"]

//    static let imgSearchUnSelectedBookmark: ThemeImagePicker = ["unselected_light", "unselected"]
//    static let imgSearchSelectedBookmark: ThemeImagePicker = ["selected", "selected"]
    static let textForYouSubTextSubColor: ThemeColorPicker = ["#84838B", "#84838B"]
    static let textSourceColor: ThemeColorPicker = ["#84838B", "#FFFFFF"]
    static let spbTopColor: ThemeColorPicker = ["#22CDC4", "#FFFFFF"]
    static let spbBottomColor: ThemeColorPicker = ["#22CDC4", "#E7E7E7"]
    static let viewHeadlineBgColor: ThemeColorPicker = ["#F1F1F1", "#171717"]
    static let textColor: ThemeColorPicker = ["#000000", "#FFFFFF"] //was ["#3D485F", "#FFFFFF"]
    static let textBWColor: ThemeColorPicker = ["#000", "#FFF"]
    static let textSubColor: ThemeColorPicker = ["#000000", "#84838B"]
    static let searchTintColor: ThemeColorPicker = ["#000000", "#FFFFFF"]
    static let tabCurrentViewBG: ThemeColorPicker = ["#000000", "#FFFFFF"]
    
    static let textTabItemColor: ThemeColorPicker = ["#000", "#FFF"]
    static let textTabUnItemColor: ThemeColorPicker = ["#393737", "#8C8B91"]
    static let textProfileHeadingsColor: ThemeColorPicker = ["#8C8B91", "#8C8B91"]
    static let textTabBarTitleSelectedColor: ThemeColorPicker = ["#393737", "#E01335"]
    static let bgSelectedColorHeaderTab: ThemeColorPicker = ["#E7E7E7", "#1A1A1A"]
    static let viewSeperatorListColor: ThemeColorPicker = ["#EDEDED", "#2B2A2F"]
    static let switchBGColor: ThemeColorPicker = ["#E7E7E7", "#2B2A2F"]
    static let viewCountColor: ThemeColorPicker = ["#FAFAFA", "#0E0E0E"]
    static let likeCountColor: ThemeColorPicker = ["#E01335", "#E01335"]
    
    static let imgUnSelectedTabColor: ThemeColorPicker = ["#393737", "#84838B"]
    static let imgSelectedTabColor: ThemeColorPicker = ["#393737", "#E01335"]
    static let tabSelectedBGColor: ThemeColorPicker = ["#E7E7E7", "#000000"]
    static let tabBGColor: ThemeColorPicker = ["#FFFFFF", "#000000"]
    static let viewHeaderTabColor: ThemeColorPicker = ["#FCFCFC", "#090909"]
    static let viewBGPostArticleColor: ThemeColorPicker = ["#FFFFFF", "#090909"]

    
    static let selectedImage: ThemeImagePicker = ["icn_home_selected", "icn_home_selected"]
    static let unSelectedImage: ThemeImagePicker = ["icn_home", "icn_home"]
    static let selectedImage2: ThemeImagePicker = ["icn_topic_selected", "icn_topic_selected"]
    static let unSelectedImage2: ThemeImagePicker = ["icn_topic", "icn_topic"]
    static let selectedImage3: ThemeImagePicker = ["icn_source_selected", "icn_source_selected"]
    static let unSelectedImage3: ThemeImagePicker = ["icn_source", "icn_source"]
    static let selectedTickMarkImage: ThemeImagePicker = ["tick_dark", "tickUnselected"]
    static let unSelectedTickMarkImage: ThemeImagePicker = ["plus_dark", "plus"]

    
    static let attributesSelected: ThemeStringAttributesPicker = [[.foregroundColor: "#E01335".hexStringToUIColor(), .font: Constant.tabFont], [.foregroundColor: "#E01335".hexStringToUIColor(), .font: Constant.tabFont]]
    static let attributesNormal: ThemeStringAttributesPicker = [[.foregroundColor: "#697389".hexStringToUIColor(), .font: Constant.tabFont], [.foregroundColor: "#8F8E95".hexStringToUIColor(), .font: Constant.tabFont]]
    
    static let attributesSelectedSmallDevice: ThemeStringAttributesPicker = [[.foregroundColor: "#E01335".hexStringToUIColor(), .font: Constant.tabFont], [.foregroundColor: "#E01335".hexStringToUIColor(), .font: Constant.tabFontSmall]]
    static let attributesNormalSmallDevice: ThemeStringAttributesPicker = [[.foregroundColor: "#697389".hexStringToUIColor(), .font: Constant.tabFont], [.foregroundColor: "#8F8E95".hexStringToUIColor(), .font: Constant.tabFontSmall]]
    
    static let attributeTitleRefreshControl: ThemeStringAttributesPicker = [[.foregroundColor: "#3D485F".hexStringToUIColor(), .font: Constant.tabFont], [.foregroundColor: "#FFFFFF".hexStringToUIColor(), .font: Constant.tabFont]]


    static let tutorialBorderColor: ThemeCGColorPicker = ["#FCFCFC", "#1A1A1A"]
    
    static let textborderColor: ThemeColorPicker = ["#C4C8CF", "#262626"]
    static let borderColor: ThemeCGColorPicker = ["#C4C8CF", "#262626"]
    static let borderWidth: ThemeCGFloatPicker = [1.8, 1.8]
    static let imgPlusColor: ThemeColorPicker = ["#C4C8CF", "#262626"]

    static let headerTextColor: ThemeColorPicker = ["#697389", "#8C8B91"]
    static let imgClose: ThemeImagePicker = ["icn_close_x_light", "icn_close_x"]
//    static let imgNoData: ThemeImagePicker = ["icn_no_data_white", "icn_no_data"]
    static let imgNoData: ThemeImagePicker = ["NoReelsFound", "NoReelsFound"]
    static let imgEndCard: ThemeImagePicker = ["icn_end_card_light", "icn_end_card"]
  //  static let imgSingleDot: ThemeImagePicker = ["newsDot_White", "newsDot"]

    static let navLogo: ThemeImagePicker = ["icn_logo_dark", "icn_logo_white"]
    static let navSearch: ThemeImagePicker = ["icn_search_light", "icn_search"]
    static let navProfile: ThemeImagePicker = ["icn_profile_light", "icn_profile"]
    static let navClose: ThemeImagePicker = ["icn_close_light", "icn_close"]
    static let navMore: ThemeImagePicker = ["icn_more_black", "icn_more_black"]

    static let tabHome: ThemeImagePicker = ["tabHomeLight","tabHome"]
    static let tabDiscover: ThemeImagePicker = ["tabSearchLight","tabSearch"]
    static let tabReels: ThemeImagePicker = ["tabReels","tabReels"]
    static let tabProfile: ThemeImagePicker = ["tabUserLight","tabUser"]
    
    
    //static let effectAlert = ["#FFF", "#000"]
    static let visualAlertThemePicker: ThemeVisualEffectPicker = [UIBlurEffect(style: .extraLight), UIBlurEffect(style: .dark)]
    
    //Card Griendent Color
    static let cardTopColor: ThemeCGColorPicker = ["#ffffff", "#141414"]
    static let cardBottomColor: ThemeCGColorPicker = ["#ffffff", "#040404"]

    static let cardTopColor2: ThemeCGColorPicker = ["#ffffff", "#040404"]
    static let cardBottomColor2: ThemeCGColorPicker = ["#ffffff", "#141414"]

    static let cardShadowColor: ThemeCGColorPicker = ["#8291AB", "#141414"]
    static let tabTopShadowColor: ThemeCGColorPicker = ["#FFF", "#000"]
    static let tabBarColor: ThemeCGColorPicker = ["#FFFFFF", "#1A1A1A"]
    static let topicShadowColor: ThemeCGColorPicker = ["#FFF", "#000"]

    static let activityViewColor: ThemeColorPicker = ["#3D485F", "#FFFFFF"]


    static let commentVCBGColor: ThemeColorPicker = ["#FAFAFA", "#0D0D0D"]
    static let commentVCTitleUnderLineColor: ThemeColorPicker = ["#E7E9EC", "#2B2A2F"]
    static let commentVCTitleColor: ThemeColorPicker = ["#000000", "#ffffff"]
    static let commentCellBGColor: ThemeColorPicker = ["#F3F3F3", "#0D0D0D"]
    static let commentTextViewTextColor: ThemeColorPicker = ["#23204A", "#BECAD8"]
    static let commentTextViewBGColor: ThemeColorPicker = ["#F3F3F3", "#1A1A1A"]
    static let commentCellTitleColor: ThemeColorPicker = ["#FFF", "#000"]
    static let commentNestedLineColor: ThemeColorPicker = ["#E5E4E9", "#363636"]
    static let commentCurvedImage: ThemeImagePicker = ["CurveIconLight", "CurveIcon"]
    
    static let commentTxtBorderColor: ThemeCGColorPicker = ["#E5E4E9", "#363636"]
    
    static let commentSendImage: ThemeImagePicker = ["Send_ic", "SendComment"]
    
    static let likedImage: ThemeImagePicker = ["LikedIcon","LikedIcon"]
    static let likeDefaultImage: ThemeImagePicker = ["LikeIcon_Light", "LikeIcon"]
//    static let likeDefaultImage: ThemeImagePicker = ["DetailsLike", "LikeIcon"]
    
    static let commentDefaultImage: ThemeImagePicker = ["CommentIcon", "CommentIconLight"]
//    static let commentDefaultImage: ThemeImagePicker = ["DetailsComment", "CommentIcon"]
    
    static let commentPopupImage: ThemeImagePicker = ["PopupIconLight", "PopupIconLight"]

    static let commonShare: ThemeImagePicker = ["DetailsShare","DetailsShareLight"]
    
    static let tabBarGradient: ThemeImagePicker = ["tabBarGradientLight", "tabBarGradientDark"]
    
    // Font size adjustment
    static let fontSizeThumbImage: ThemeImagePicker = ["PopupIconLight", "PopupIcon"]
    static let fontSizeTextColor: ThemeColorPicker = ["#000000", "#ffffff"]
    static let fontSizeUnselectedColor: ThemeColorPicker = ["#84838B", "#84838B"]
    static let fontSizeTextHighlightColor: ThemeColorPicker = ["#000000", "#ffffff"]
    static let sliderTintColor: ThemeColorPicker = ["#E01335", "#E01335"]
    static let fontSizeVCGradient: ThemeImagePicker = ["fontSizeGradientLight", "fontSizeGradient"]
    
//    static let fontSizeTextColor: ThemeColorPicker = ["#84838B", "#363636"]
    static let tabIconColor: ThemeColorPicker = ["#84838B","#84838B"]
    static let tabIconSelectedColor: ThemeColorPicker = ["#000000", "#ffffff"]
    static let tabIconSelectedColorReels: ThemeColorPicker = ["#ffffff", "#ffffff"]
    
    
    static let subcategoriesCloseBG: ThemeImagePicker = ["SubcategoriesCloseLightBG","SubcategoriesCloseBG"]
    static let subcategoriesClose: ThemeImagePicker = ["SubcategoriesCloseLight","SubcategoriesClose"]
    
    
    
    static let pickerTitleSelect: ThemeColorPicker = ["#000000","#FFFFFF"]
    static let pickerTitleNotSelect: ThemeColorPicker = ["#67676B", "#67676B"]
    static let downArrowTintColor: ThemeColorPicker = ["#000", "#FAFAFA"] //["#FFF", "#000"]
    
    
    static let relevantHeaderTextColor: ThemeColorPicker = ["#84838B", "#84838B"]
    static let relevantHeaderBackgroundColor: ThemeColorPicker = ["#FBFBFB", "#121212"]
    
    
    
    static let followButtonBackground: ThemeColorPicker = ["#F3F3F3", "#1A1A1A"]
    static let followButtonImageSelected: ThemeImagePicker = ["bookmarkSelected_white", "bookmarkSelectedFollow"]
    static let followButtonImageNotSelected: ThemeImagePicker = ["unselectedWhite", "unselected"]
    
    
    static let followersCountRelevant: ThemeColorPicker = ["#84838B", "#84838B"]
    
    
    static let backgroundGalleryTab: ThemeColorPicker = ["#FCFCFC", "#090909"]
    
    
    static let noPostColor: ThemeColorPicker = ["#C9C9C9", "#212123"]
    static let uploadPostColor: ThemeColorPicker = ["#C9C9C9", "#3A3A3A"]
    
    
    static let createChannelColor: ThemeColorPicker = ["#909090", "#8C8B91"]
    static let ChannelDescriptionColor: ThemeColorPicker = ["#84838B", "#84838B"]
    
    static let channelUnderlineColor: ThemeColorPicker = ["#E7E9EC", "#262628"]
    static let imgAddChannel: ThemeImagePicker = ["AddChannelIconLight", "AddChannelIcon"]
    static let closeSelection: ThemeImagePicker = ["closeSelection", "closeSelectionLight"]
    
    static let twitterMenuIcon: ThemeImagePicker = ["twitterMenu", "twitterMenu"]
    static let fbMenuIcon: ThemeImagePicker = ["fbMenu", "fbMenu"]
    static let youtubeMenuIcon: ThemeImagePicker = ["youtubeMenu", "youtubeMenu"]
    static let instaMenuIcon: ThemeImagePicker = ["instaMenu", "instaMenu"]
    
    static let skeletonColorLightMode: UIColor = .lightGray
    
    static let skeletonColorDarkMode: UIColor = .darkGray
    
    static let errorMessageIcon: ThemeImagePicker = ["LightError", "DarkError"]
    static let shadowColorDiscover : ThemeCGColorPicker = ["#808080", "#000000"]
    
    static let cropTextColor : ThemeColorPicker = ["#84838b", "#84838b"]
    
    static let backgroundColorEditions: ThemeColorPicker = ["#121212", "#121212"] //["#FAFAFA", "#090909"]
    
    
    // Registration New
    static let buttonUnselectedColor: ThemeColorPicker = ["#121212", "#121212"]
    
}
