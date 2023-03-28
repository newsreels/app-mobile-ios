//
//  switchMenuCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 27/04/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol switchMenuCCDelegate: AnyObject {
    func didTapItem(cell: switchMenuCC, switchStatus: Bool)
}

class switchMenuCC: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var underLineView: UIView!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var switchButton: UISwitch!
    
    
    weak var delegate: switchMenuCCDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        underLineView.backgroundColor = Constant.appColor.borderGray
        
        
        titleLabel.textColor = UIColor.black
        subTitleLabel.textColor = Constant.appColor.mediumGray
        switchButton.onTintColor = Constant.appColor.lightRed
        switchButton.backgroundColor = Constant.appColor.lightGray
        
    }

    
    override func layoutSubviews() {
        
        let minSide = min(switchButton.bounds.size.height, switchButton.bounds.size.width)
        switchButton.layer.cornerRadius = minSide/2
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Actions
    @IBAction func switchValueChanged(_ sender: Any) {
        
        self.delegate?.didTapItem(cell: self, switchStatus: switchButton.isOn)
    }
    
    
    func setupCell(model: MenuModel, isOn: Bool, isExtended: Bool) {
        
        titleLabel.text = model.name
        subTitleLabel.text = model.subtitle
        
        if isExtended {
            titleTopConstraint.constant = 70
        }
        else {
            titleTopConstraint.constant = 15
        }
        
        switchButton.isOn = isOn
    }
    
    
    
}
