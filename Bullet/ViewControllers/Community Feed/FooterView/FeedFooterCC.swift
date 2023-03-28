//
//  FeedFooterCC.swift
//  Bullet
//
//  Created by Mahesh on 13/07/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class FeedFooterCC: UITableViewCell {

    var didTapGoTopPressedBlock: (() -> Void)?

    @IBOutlet weak var viewGoTop: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblGotTop: UILabel!
    @IBOutlet weak var btnGotTop: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblTitle.theme_textColor = GlobalPicker.textBWColor
        viewGoTop.cornerRadius = viewGoTop.frame.height / 2
        
        lblTitle.text = NSLocalizedString("You're all caught up", comment: "")
        lblSubTitle.text = NSLocalizedString("You've seen all new posts", comment: "")
        lblGotTop.text = NSLocalizedString("Go to top", comment: "")

    }
    
    @IBAction private func didTapGo(_ button: UIButton) {
        didTapGoTopPressedBlock?()
    }
}
