//
//  Constant.swift
//  Bullet
//
//  Created by Khadim Hussain on 29/05/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import SystemConfiguration

class SharedManager {
    

    static let shared = SharedManager()
    
    var focussedCardIndex: Int = 0
    var currentCategoryIndex: Int = 0
    var duration: Int = 3
    
    let APP_BASE_URL = "https://api.staging.newsinbullets.app/"
    
    // MARK: - AlertView PopUp
    func showAlertView(source : UIViewController,title:String,message:String) {
        
        let alert = UIAlertController(title: title as String, message: message as String, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        source.present(alert, animated: true, completion: nil)
    }
    
    class func getTextWidth(_ text: String, textHeight: CGFloat, textFont: UIFont) -> CGFloat {
        let textRect = text.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: textHeight), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: textFont], context: nil)
        let textSize = textRect.size
        return textSize.width
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
}
