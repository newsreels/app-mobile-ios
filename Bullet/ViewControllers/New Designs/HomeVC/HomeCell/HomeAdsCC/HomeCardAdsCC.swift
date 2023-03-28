//
//  HomeCardAdsCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 23/11/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import GoogleMobileAds

internal let CELL_IDENTIFIER_ADS_CARD = "HomeCardAdsCC"

protocol HomeCardAdsCCDelegate: class {
    
    //func handleSwipeLeftRightArticleDelegate(isLeftToRight: Bool)

}

class HomeCardAdsCC: UITableViewCell {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var viewGradientShadow: UIView!
    @IBOutlet weak var imgBlureBG: UIImageView!
    @IBOutlet weak var unifiedNativeAdsView: GADUnifiedNativeAdView!
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var lblAd: UILabel!
    @IBOutlet weak var btnSkipAd: UIButton!

    weak var delegateAdsCardCell: HomeCardAdsCCDelegate?

    private var swipeGesture = UISwipeGestureRecognizer()

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        lblAd.theme_textColor = GlobalPicker.textSourceColor
        viewBG.theme_backgroundColor = GlobalPicker.backgroundColor
        unifiedNativeAdsView.theme_backgroundColor = GlobalPicker.customTabbarBGColor
        btnSkipAd.theme_backgroundColor = GlobalPicker.adsButtonBGColor
        btnSkipAd.theme_setTitleColor(GlobalPicker.textColor, forState: .normal)
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
    }
    
    func setupCell() {
        
        //Pan Gestures
        let panLeft = PanDirectionGestureRecognizer(direction: .horizontal(.left), target: self, action: #selector(handlePanGesture(_:)))
        panLeft.cancelsTouchesInView = false
        self.addGestureRecognizer(panLeft)
        
        let panRight = PanDirectionGestureRecognizer(direction: .horizontal(.right), target: self, action: #selector(handlePanGesture(_:)))
        panRight.cancelsTouchesInView = false
        self.addGestureRecognizer(panRight)

        //Swipe Gestures
        let direction: [UISwipeGestureRecognizer.Direction] = [.left, .right]
        for dir in direction {
            self.swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeView(_:)))
            self.swipeGesture.direction = dir
            self.addGestureRecognizer(self.swipeGesture)
//            panUp.require(toFail: self.swipeGesture)
//            panDown.require(toFail: self.swipeGesture)
            panLeft.require(toFail: self.swipeGesture)
            panRight.require(toFail: self.swipeGesture)
        }
    }
    
    @objc func swipeView(_ sender: UISwipeGestureRecognizer) {
        
        if sender.direction == .right {
        //    print("swipe right")
        }
        else if sender.direction == .left {
      //      print("swipe left")
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


}




