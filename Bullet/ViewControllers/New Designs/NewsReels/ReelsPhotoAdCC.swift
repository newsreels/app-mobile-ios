//
//  ReelsPhotoAdCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 29/06/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import FBAudienceNetwork
import GoogleMobileAds

class ReelsPhotoAdCC: UICollectionViewCell {

    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var viewUnifiedNativeAd: GADUnifiedNativeAdView!

    
    
    @IBOutlet weak var adUIView: UIView!
    @IBOutlet weak var adCoverMediaView: FBMediaView!
    @IBOutlet weak var adIconImageView: FBMediaView!
    @IBOutlet weak var adCallToActionButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var adLoader: GADAdLoader? = nil
    var fbnNativeAd: FBNativeAd? = nil
    var googleNativeAd: GADUnifiedNativeAd?
    var viewController: UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.textColor = .white
        adCallToActionButton.theme_backgroundColor = GlobalPicker.themeCommonColor
        
        adCoverMediaView.applyNaturalWidth()
        adCoverMediaView.applyNaturalHeight()
        
    }

    override func prepareForReuse() {
        
        fbnNativeAd = nil
        googleNativeAd = nil
        
    }
    
    func fetchAds(viewController: UIViewController) {
        
        
        self.viewController = viewController
        if SharedManager.shared.adsAvailable && SharedManager.shared.adUnitReelID != "" {
            if SharedManager.shared.adType.uppercased() == "FACEBOOK" {
                
                if fbnNativeAd == nil {
                    fbnNativeAd = FBNativeAd(placementID: SharedManager.shared.adUnitReelID)
                    fbnNativeAd?.delegate = self
                    #if DEBUG
                    FBAdSettings.testAdType = .vid_HD_16_9_46s_App_Install
                    #else
                    #endif
                    fbnNativeAd?.loadAd()
                    print("ad requested")
                    
                } else {
                    self.loadFacebookAd(nativeAd: fbnNativeAd)
                }
                
            } else {
                
                if adLoader == nil {
                    adLoader = GADAdLoader(adUnitID: SharedManager.shared.adUnitReelID, rootViewController: viewController,
                                           adTypes: [ .unifiedNative ], options: nil)
                    adLoader?.delegate = self
                    adLoader?.load(GADRequest())
                } else {
                    self.loadGoogleAd(nativeAd: googleNativeAd)
                }
            }
        }
        
        
    }
    
    func loadGoogleAd(nativeAd: GADUnifiedNativeAd?) {
        
        guard let nativeAd = nativeAd else { return }
        
        viewUnifiedNativeAd.isHidden = false
        adUIView.isHidden = true
        //print("Ad loader came with results")
        print("Received native ad: \(nativeAd)")
        viewUnifiedNativeAd.nativeAd = nativeAd

        viewUnifiedNativeAd.mediaView?.mediaContent = nativeAd.mediaContent
        viewUnifiedNativeAd.mediaView?.contentMode = .scaleAspectFit
        
        // Associate the ad view with the ad object.
        // This is required to make the ad clickable.
        (viewUnifiedNativeAd.headlineView as? UILabel)?.textColor = UIColor.white//GlobalPicker.textBWColor
        (viewUnifiedNativeAd.headlineView as? UILabel)?.text = nativeAd.headline
        viewUnifiedNativeAd.headlineView?.isHidden = nativeAd.headline == nil

        (viewUnifiedNativeAd.bodyView as? UILabel)?.textColor = UIColor.white//GlobalPicker.textBWColor
        (viewUnifiedNativeAd.bodyView as? UILabel)?.text = nativeAd.body
        viewUnifiedNativeAd.bodyView?.isHidden = nativeAd.body == nil

        //                        (adView.callToActionView as? UIButton)?.theme_backgroundColor = GlobalPicker.adsButtonBGColor
        (viewUnifiedNativeAd.callToActionView as? UIButton)?.setTitleColor(.white, for: .normal)
        //  (adView.callToActionView as? UIButton)?.theme_setTitleColor(UIColor.white, forState: .normal)
        (viewUnifiedNativeAd.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        (viewUnifiedNativeAd.callToActionView as? UIButton)?.theme_backgroundColor = GlobalPicker.themeCommonColor
        (viewUnifiedNativeAd.callToActionView as? UIButton)?.layer.cornerRadius = 5
        viewUnifiedNativeAd.callToActionView?.isHidden = nativeAd.callToAction == nil

        (viewUnifiedNativeAd.iconView as? UIImageView)?.image = nativeAd.icon?.image
        (viewUnifiedNativeAd.iconView as? UIImageView)?.layer.cornerRadius = 20
        (viewUnifiedNativeAd.iconView as? UIImageView)?.clipsToBounds = true
        viewUnifiedNativeAd.iconView?.isHidden = nativeAd.icon == nil

        (viewUnifiedNativeAd.starRatingView as? UIImageView)?.image = imageOfStars(from:nativeAd.starRating)
        viewUnifiedNativeAd.starRatingView?.isHidden = nativeAd.starRating == nil

        //                        (adView.storeView as? UILabel)?.theme_textColor = GlobalPicker.textColor
        //                        (adView.storeView as? UILabel)?.text = nativeAd.store
        //                        adView.storeView?.isHidden = nativeAd.store == nil

        //                        (adView.priceView as? UILabel)?.theme_textColor = GlobalPicker.textColor
        //                        (adView.priceView as? UILabel)?.text = nativeAd.price
        //                        adView.priceView?.isHidden = nativeAd.price == nil

        (viewUnifiedNativeAd.advertiserView as? UILabel)?.textColor = UIColor.white//GlobalPicker.textBWColor
        (viewUnifiedNativeAd.advertiserView as? UILabel)?.text = nativeAd.advertiser
        viewUnifiedNativeAd.advertiserView?.isHidden = nativeAd.advertiser == nil

        // In order for the SDK to process touch events properly, user interaction should be disabled.
        viewUnifiedNativeAd.callToActionView?.isUserInteractionEnabled = false
        
        //            }
        
        //        }
    }
    
    
    func loadFacebookAd(nativeAd: FBNativeAd?) {
        
        guard let nativeAd = nativeAd else { return }
        
        viewUnifiedNativeAd.isHidden = true
        adUIView.isHidden = false
        
        adCoverMediaView.delegate = self
        
        // 3. Register what views will be tappable and what the delegate is to notify when a registered view is tapped
        // Here only the call-to-action button and the media view are tappable, and the delegate is the view controller
          nativeAd.registerView(
          forInteraction: adUIView,
          mediaView: adCoverMediaView,
          iconView: adIconImageView, viewController: viewController,
          clickableViews: [adCallToActionButton, adCoverMediaView]
        )
        
        
        // 4. Render the ad content onto the view
        titleLabel.text = nativeAd.advertiserName
//        adBodyLabel.text = nativeAd.bodyText
  //      adSocialContextLabel.text = nativeAd.socialContext
//        sponsoredLabel.text = nativeAd.sponsoredTranslation
        adCallToActionButton.setTitle(nativeAd.callToAction, for: .normal)
//        adOptionsView.nativeAd = nativeAd
        
      }
    
    /// Returns a `UIImage` representing the number of stars from the given star rating; returns `nil`
    /// if the star rating is less than 3.5 stars.
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
      guard let rating = starRating?.doubleValue else {
        return nil
      }
      if rating >= 5 {
        return UIImage(named: "stars_5")
      } else if rating >= 4.5 {
        return UIImage(named: "stars_4_5")
      } else if rating >= 4 {
        return UIImage(named: "stars_4")
      } else if rating >= 3.5 {
        return UIImage(named: "stars_3_5")
      } else {
        return nil
      }
    }
    
}

// MARK: - Ads
// Google Ads
extension ReelsPhotoAdCC: GADUnifiedNativeAdLoaderDelegate {
    
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        
        self.googleNativeAd = nil
        print("\(adLoader) failed with error: \(error.localizedDescription)")
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        
        //print("Ad loader came with results")
        print("Received native ad: \(nativeAd)")
        self.googleNativeAd = nativeAd
        
        
        self.loadGoogleAd(nativeAd: self.googleNativeAd!)
        
    }
    
}

// Facebook Ads
extension ReelsPhotoAdCC: FBNativeAdDelegate {
    
    
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        
        // 1. If there is an existing valid native ad, unregister the view
        if let previousNativeAd = self.fbnNativeAd, previousNativeAd.isAdValid {
            previousNativeAd.unregisterView()
        }
        
        // 2. Retain a reference to the native ad object
        self.fbnNativeAd = nativeAd
        
        self.loadFacebookAd(nativeAd: nativeAd)
        
    }
    
    
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
        
        self.fbnNativeAd = nil
        print("error", error.localizedDescription)
    }
    
    
    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
        print("nativeAdDidClick")
    }
    
}



extension ReelsPhotoAdCC: FBMediaViewDelegate {
    
    
    func mediaViewDidLoad(_ mediaView: FBMediaView) {
        
        print("mediaViewDidLoad")
    }
    
    func mediaViewVideoDidPlay(_ mediaView: FBMediaView) {
        
        print("mediaViewVideoDidPlay")
    }
    
    func mediaViewVideoDidPause(_ mediaView: FBMediaView) {
        
        print("mediaViewVideoDidPlay")
    }
    
    func mediaViewVideoDidComplete(_ mediaView: FBMediaView) {
        
        print("mediaViewVideoDidComplete")
    }
    
    func nativeAdDidDownloadMedia(_ nativeAd: FBNativeAd) {
        
        print("nativeAdDidDownloadMedia")
    }
    
    func mediaViewWillEnterFullscreen(_ mediaView: FBMediaView) {
        
        print("mediaViewWillEnterFullscreen")
    }
    
    func mediaViewDidExitFullscreen(_ mediaView: FBMediaView) {
        
        print("mediaViewDidExitFullscreen")
    }
    
    func mediaView(_ mediaView: FBMediaView, videoVolumeDidChange volume: Float) {
        
        print("videoVolumeDidChange")
    }
}
