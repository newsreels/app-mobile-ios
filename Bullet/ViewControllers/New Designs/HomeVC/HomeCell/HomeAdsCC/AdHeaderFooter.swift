//
//  AdHeaderFooter.swift
//  Bullet
//
//  Created by Faris Muhammed on 29/06/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import FBAudienceNetwork
import GoogleMobileAds

class AdHeaderFooter: UITableViewHeaderFooterView {

    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var viewUnifiedNativeAd: GADUnifiedNativeAdView!
    @IBOutlet weak var imgWifi: UIImageView!
    @IBOutlet weak var viewDividerLine: UIView!
    @IBOutlet weak var constraintContainerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var lblAds: UILabel!
    
    // Facebook Ad
    @IBOutlet weak var adUIView: UIView!
    @IBOutlet weak var adIconImageView: FBMediaView!
    @IBOutlet weak var adCoverMediaView: FBMediaView!
    @IBOutlet weak var adCallToActionButton: UIButton!
    @IBOutlet weak var adTitleLabel: UILabel!
    @IBOutlet weak var adBodyLabel: UILabel!
    @IBOutlet weak var sponsoredLabel: UILabel!
//    @IBOutlet weak var adOptionsView: FBAdOptionsView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewDividerLine.theme_backgroundColor = GlobalPicker.dividerLineBG
        lblAds.theme_textColor = GlobalPicker.textSourceColor
        imgWifi.theme_image = GlobalPicker.imgWifi
        
        
//        if adType.uppercased() == "FACEBOOK" {
//
//            // Show facebook ads
//            viewUnifiedNativeAd.isHidden = true
//            adUIView.isHidden = false
//
//
//        } else {
//
//            viewUnifiedNativeAd.isHidden = false
//            adUIView.isHidden = true
//        }
        viewUnifiedNativeAd.isHidden = true
        adUIView.isHidden = true
        
        adTitleLabel.theme_textColor = GlobalPicker.textBWColor
        adBodyLabel.theme_textColor = GlobalPicker.textBWColor
        sponsoredLabel.theme_textColor = GlobalPicker.textBWColor
    }

    func loadGoogleAd(nativeAd: GADUnifiedNativeAd?) {
        
        guard let nativeAd = nativeAd else { return }
        
        viewUnifiedNativeAd.isHidden = false
        adUIView.isHidden = true
        //print("Ad loader came with results")
        print("Received native ad: \(nativeAd)")
        viewUnifiedNativeAd.nativeAd = nativeAd

        viewUnifiedNativeAd.mediaView?.mediaContent = nativeAd.mediaContent
        viewUnifiedNativeAd.mediaView?.contentMode = .scaleAspectFill
        
        // Associate the ad view with the ad object.
        // This is required to make the ad clickable.
        (viewUnifiedNativeAd.headlineView as? UILabel)?.theme_textColor = GlobalPicker.textBWColor
        (viewUnifiedNativeAd.headlineView as? UILabel)?.text = nativeAd.headline
        viewUnifiedNativeAd.headlineView?.isHidden = nativeAd.headline == nil

        (viewUnifiedNativeAd.bodyView as? UILabel)?.theme_textColor = GlobalPicker.textBWColor
        (viewUnifiedNativeAd.bodyView as? UILabel)?.text = nativeAd.body
        viewUnifiedNativeAd.bodyView?.isHidden = nativeAd.body == nil

        //                        (adView.callToActionView as? UIButton)?.theme_backgroundColor = GlobalPicker.adsButtonBGColor
        (viewUnifiedNativeAd.callToActionView as? UIButton)?.setTitleColor(.white, for: .normal)
        //  (adView.callToActionView as? UIButton)?.theme_setTitleColor(UIColor.white, forState: .normal)
        (viewUnifiedNativeAd.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        viewUnifiedNativeAd.callToActionView?.isHidden = nativeAd.callToAction == nil

        //                        (adView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        //                        adView.iconView?.isHidden = nativeAd.icon == nil

        //   (adView.starRatingView as? UIImageView)?.image = imageOfStars(fromStarRating:nativeAd.starRating)
        viewUnifiedNativeAd.starRatingView?.isHidden = nativeAd.starRating == nil

        //                        (adView.storeView as? UILabel)?.theme_textColor = GlobalPicker.textColor
        //                        (adView.storeView as? UILabel)?.text = nativeAd.store
        //                        adView.storeView?.isHidden = nativeAd.store == nil

        //                        (adView.priceView as? UILabel)?.theme_textColor = GlobalPicker.textColor
        //                        (adView.priceView as? UILabel)?.text = nativeAd.price
        //                        adView.priceView?.isHidden = nativeAd.price == nil

        (viewUnifiedNativeAd.advertiserView as? UILabel)?.theme_textColor = GlobalPicker.textBWColor
        (viewUnifiedNativeAd.advertiserView as? UILabel)?.text = nativeAd.advertiser
        viewUnifiedNativeAd.advertiserView?.isHidden = nativeAd.advertiser == nil

        // In order for the SDK to process touch events properly, user interaction should be disabled.
        viewUnifiedNativeAd.callToActionView?.isUserInteractionEnabled = false
        
        //            }
        
        //        }
    }
    
    
    func loadFacebookAd(nativeAd: FBNativeAd?, viewController: UIViewController) {
        
        guard let nativeAd = nativeAd else { return }
        
        viewUnifiedNativeAd.isHidden = true
        adUIView.isHidden = false
        
        
        // 3. Register what views will be tappable and what the delegate is to notify when a registered view is tapped
        // Here only the call-to-action button and the media view are tappable, and the delegate is the view controller
          nativeAd.registerView(
          forInteraction: adUIView,
          mediaView: adCoverMediaView,
          iconView: adIconImageView, viewController: viewController,
          clickableViews: [adCallToActionButton, adCoverMediaView]
        )
          
        // 4. Render the ad content onto the view
        adTitleLabel.text = nativeAd.advertiserName
        adBodyLabel.text = nativeAd.bodyText
  //      adSocialContextLabel.text = nativeAd.socialContext
        sponsoredLabel.text = nativeAd.sponsoredTranslation
        adCallToActionButton.setTitle(nativeAd.callToAction, for: .normal)
//        adOptionsView.nativeAd = nativeAd
        
      }
    
    
}
