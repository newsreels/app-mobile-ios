//
//  Languages.swift
//  Bullet
//
//  Created by Mahesh on 14/12/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import Foundation
import UIKit

//enum Language: Equatable {
//
//    case english(English)
//    case chinese(Chinese)
//    case korean
//    case japanese
//
//    enum English {
//        case us
//        case uk
//        case australian
//        case canadian
//        case indian
//    }
//
//    enum Chinese {
//        case simplified
//        case traditional
//        case hongKong
//    }
//}
//
//extension Language {
//
//    var code: String {
//
//        switch self {
//        case .english(let english):
//            switch english {
//            case .us:                return "en"
//            case .uk:                return "en-GB"
//            case .australian:        return "en-AU"
//            case .canadian:          return "en-CA"
//            case .indian:            return "en-IN"
//            }
//
//        case .chinese(let chinese):
//            switch chinese {
//            case .simplified:       return "zh-Hans"
//            case .traditional:      return "zh-Hant"
//            case .hongKong:         return "zh-HK"
//            }
//
//        case .korean:               return "ko"
//        case .japanese:             return "ja"
//        }
//    }
//
//    var name: String {
//        switch self {
//        case .english(let english):
//            switch english {
//            case .us:                return "English"
//            case .uk:                return "English (UK)"
//            case .australian:        return "English (Australia)"
//            case .canadian:          return "English (Canada)"
//            case .indian:            return "English (India)"
//            }
//
//        case .chinese(let chinese):
//            switch chinese {
//            case .simplified:       return "简体中文"
//            case .traditional:      return "繁體中文"
//            case .hongKong:         return "繁體中文 (香港)"
//            }
//
//        case .korean:               return "한국어"
//        case .japanese:             return "日本語"
//        }
//    }
//}
//
//extension Language {
//
//    init?(languageCode: String?) {
//
//        guard let languageCode = languageCode else { return nil }
//        switch languageCode {
//        case "en", "en-US":     self = .english(.us)
//        case "en-GB":           self = .english(.uk)
//        case "en-AU":           self = .english(.australian)
//        case "en-CA":           self = .english(.canadian)
//        case "en-IN":           self = .english(.indian)
//
//        case "zh-Hans":         self = .chinese(.simplified)
//        case "zh-Hant":         self = .chinese(.traditional)
//        case "zh-HK":           self = .chinese(.hongKong)
//
//        case "ko":              self = .korean
//        case "ja":              self = .japanese
//        default:                return nil
//        }
//    }
//}


private var kBundleKey: UInt8 = 0

class BundleEx: Bundle {

    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = objc_getAssociatedObject(self, &kBundleKey) {
            return (bundle as! Bundle).localizedString(forKey: key, value: value, table: tableName)
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }

}

extension Bundle {

    static let once: Void = {
        object_setClass(Bundle.main, type(of: BundleEx()))
    }()

    class func setLanguage(_ language: String?) {
        Bundle.once
        let isLanguageRTL = Bundle.isLanguageRTL(language)
        if (isLanguageRTL) {
            
            Bundle.viewAlign(UISemanticContentAttribute.forceRightToLeft)
        } else {
            Bundle.viewAlign(UISemanticContentAttribute.forceLeftToRight)
        }
        UserDefaults.standard.set(isLanguageRTL, forKey: "AppleTextDirection")
        UserDefaults.standard.set(isLanguageRTL, forKey: "NSForceRightToLeftWritingDirection")
        UserDefaults.standard.synchronize()

        let value = language != nil ? Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj") ?? Bundle.main.path(forResource: "en", ofType: "lproj")!) : nil
        objc_setAssociatedObject(Bundle.main, &kBundleKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    class func isLanguageRTL(_ languageCode: String?) -> Bool {
        return (languageCode != nil && Locale.characterDirection(forLanguage: languageCode!) == .rightToLeft)
    }
    
    class func viewAlign(_ semanticContent: UISemanticContentAttribute) {
        
        UIImageView.appearance().semanticContentAttribute = semanticContent
        UIView.appearance().semanticContentAttribute = semanticContent
        UILabel.appearance().semanticContentAttribute = semanticContent
        UIButton.appearance().semanticContentAttribute = semanticContent
        UITextField.appearance().semanticContentAttribute = semanticContent
        UICollectionView.appearance().semanticContentAttribute = semanticContent
        UITableView.appearance().semanticContentAttribute = semanticContent
    }

}
