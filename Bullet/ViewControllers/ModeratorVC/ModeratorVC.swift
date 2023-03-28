//
//  ModeratorVC.swift
//  Bullet
//
//  Created by Mahesh on 17/06/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import SwiftTheme

class ModeratorVC: UIViewController {

    @IBOutlet weak var viewNav: UIView!
    @IBOutlet weak var lblTitleNav: UILabel!
    
    @IBOutlet weak var viewGeneral: UIView!
    @IBOutlet weak var lblGeneral: UILabel!
    
    @IBOutlet weak var viewSchedulePost: UIView!
    @IBOutlet weak var lblSchedulePost: UILabel!
    
    @IBOutlet weak var viewDraft: UIView!
    @IBOutlet weak var lblDraft: UILabel!
    
    @IBOutlet weak var viewSetting: UIView!
    @IBOutlet weak var lblSetting: UILabel!
    
    @IBOutlet weak var viewCoverPhoto: UIView!
    @IBOutlet weak var lblCoverPhoto: UILabel!
    
    @IBOutlet weak var viewDesc: UIView!
    @IBOutlet weak var lblDesc: UILabel!

    @IBOutlet var lblCollection: [UILabel]!
    @IBOutlet var imgCollectionArrow: [UIImageView]!
    @IBOutlet var viewBGCollection: [UIView]!
        
    var channelInfo: ChannelInfo?
    var isFromMode = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setLocalizableString()
        self.designView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        imgCollectionArrow.forEach { (imageView) in
            DispatchQueue.main.async {
                if SharedManager.shared.isSelectedLanguageRTL() {
                    imageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                } else {
                    imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
                imageView.layoutIfNeeded()
            }
        }
    }
    
    func setLocalizableString() {
        
        lblTitleNav.text = NSLocalizedString("Moderator Tools", comment: "")
        
        lblGeneral.text = NSLocalizedString("GENERAL", comment: "")
        lblSchedulePost.text = NSLocalizedString("SCHEDULE POST", comment: "").uppercased()
        lblDraft.text = NSLocalizedString("DRAFTS", comment: "")
        lblSetting.text = NSLocalizedString("Settings", comment: "").uppercased()
        lblCoverPhoto.text = NSLocalizedString("channel and cover photo", comment: "").uppercased()
        lblDesc.text = NSLocalizedString("Description", comment: "").uppercased()
    }
    
    func designView() {
        
        self.view.theme_backgroundColor = GlobalPicker.backgroundColorHomeCell
        lblTitleNav.theme_textColor = GlobalPicker.textColor
        
        viewNav.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        
        viewBGCollection.forEach { view in
            view.theme_backgroundColor = GlobalPicker.bgBlackWhiteColor
        }
        
        lblCollection.forEach { lbl in
            lbl.theme_textColor = GlobalPicker.textColor
            lbl.addTextSpacing(spacing: 2.0)
        }
        
        let lightImage = UIImage(named: "tbFrowordArrow")?.sd_tintedImage(with: Constant.appColor.blue)
        let darkImage = UIImage(named: "tbFrowordArrow")?.sd_tintedImage(with: Constant.appColor.purple)
        let colorImage = ThemeImagePicker(images: lightImage!,darkImage!)
        
        imgCollectionArrow.forEach { (imageView) in
            imageView.theme_image = colorImage
        }
    }

    //MARK:- BUTTON ACTION
    @IBAction func didTapBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapChannelOption(_ sender: UIButton) {
        
        if sender.tag == 1 {
            
            //Schedule post
            let vc = SchedulePostListVC.instantiate(fromAppStoryboard: .Schedule)
            vc.selectedChannel = self.channelInfo
            vc.isFromModerator = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender.tag == 2 {
            
            //Draft
            let vc = SchedulePostListVC.instantiate(fromAppStoryboard: .Schedule)
            vc.isDraftList = true
            vc.selectedChannel = self.channelInfo
            vc.isFromModerator = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender.tag == 3 {
            
            //Channel Photo & cover image
            let vc = ChannelCoverPhotoVC.instantiate(fromAppStoryboard: .Schedule)
            vc.channelInfo = self.channelInfo
            vc.isFromModerator = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sender.tag == 4 {
            
            //Description
            let vc = ChannelDescriptionVC.instantiate(fromAppStoryboard: .Channel)
            vc.isFromMode = true
            vc.channelId = self.channelInfo?.id ?? ""
            vc.channelDescription = self.channelInfo?.channelDescription ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
