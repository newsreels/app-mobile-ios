//
//  TopicSelectionCell.swift
//  Bullet
//
//  Created by Mahesh on 19/05/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

let COLLECTION_CELL_HEIGHT: CGFloat                 = 145

//protocol TopicCellDelegate: class {
//
//    func didTapCellUnsubscribeAction(_ buttton: UIButton)
//}

class ChannelCell: UICollectionViewCell {
    
//    weak var delegate: TopicCellDelegate?

    @IBOutlet weak var imgDot: UIImageView!
    //@IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnDot: UIButton!
    @IBOutlet weak var imgPlus: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgView.roundCorners(.allCorners, radius: imgView.bounds.size.height / 2)
        
    }
    
//    @IBAction func didTapDotAction(_ sender: UIButton) {
//
//        self.delegate?.didTapCellUnsubscribeAction(sender)
//    }
    
}



class SuggestedChannelCell: UICollectionViewCell {
 
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var viewLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblName.theme_textColor = GlobalPicker.textColor
        viewLine.theme_backgroundColor = GlobalPicker.viewSeperatorListColor
    }

}




