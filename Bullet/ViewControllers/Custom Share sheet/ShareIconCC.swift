//
//  ShareIconCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 25/07/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit


class ShareIconCC: UICollectionViewCell {

    var didTapIconButton: ((_ cell: UICollectionViewCell) -> Void)?
    
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBAction func didTapIcon(_ sender: Any) {
        
        didTapIconButton?(self)
    }
    
    
    func setUpCell(type: CustomShareVC.ShareItemType) {
        
        imgIcon.image = nil
        lblTitle.text = ""

        if type == .whatsapp {
            imgIcon.image = UIImage(named: "Sharewhatsapp")
            lblTitle.text = "Whatsapp"
        }
        else if type == .whatsappStories {
            imgIcon.image = UIImage(named: "Sharewhatsapp")
            lblTitle.text = "WhatsApp status"
        }
        else if type == .sms {
            imgIcon.image = UIImage(named: "ShareMessage")
            lblTitle.text = "Messages"
        }
        else if type == .stories {
            imgIcon.image = UIImage(named: "instaMenu")
            lblTitle.text = "Stories"
        }
        else if type == .whatsapp_status {
            imgIcon.image = UIImage(named: "Sharewhatsapp")
            lblTitle.text = "Whatsapp status"
        }
        else if type == .twitter {
            imgIcon.image = UIImage(named: "Sharetwitter")
            lblTitle.text = "Twitter"
        }
        else if type == .snapchat {
            imgIcon.image = UIImage(named: "ShareSnapchat")
            lblTitle.text = "Snapchat"
        }
        else if type == .facebook {
            imgIcon.image = UIImage(named: "ShareFacebook")
            lblTitle.text = "Facebook"
        }
        else if type == .instagram {
            imgIcon.image = UIImage(named: "instaMenu")
            lblTitle.text = "Instagram"
        }
        else if type == .others {
            imgIcon.image = UIImage(named: "ShareOthers")
            lblTitle.text = "Others"
        }
        
    }

}
