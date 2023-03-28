//
//  TableViewCell.swift
//  NewsReels
//
//  Created by jhude lapuz on 6/1/22.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var imageTitle: UIImageView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var lineView: UIView!
    
    var playActionBlock: (() -> Void)? = nil
    var moreActionBlock: (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lineView.layer.borderWidth = 0.5
        lineView.layer.borderColor = UIColor(hexString: "DDDDDD").cgColor
        
        photoView.layer.cornerRadius = 6
        playButton.layer.cornerRadius = 12
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        playActionBlock?()
    }
    
    @IBAction func moreButton(_ sender: Any) {
        moreActionBlock?()
    }
    
    static let identifier = "MenuTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "MenuTableViewCell", bundle: nil)
    }
}
