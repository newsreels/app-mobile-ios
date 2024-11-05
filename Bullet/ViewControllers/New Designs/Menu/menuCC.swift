//
//  menuCC.swift
//  Bullet
//
//  Created by Faris Muhammed on 26/04/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol menuCCDelegate: AnyObject {
    func didTapItem(cell: menuCC)
}

class menuCC: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var underLineView: UIView!
    @IBOutlet weak var gradView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var gradImageView: UIImageView!
    
    weak var delegate: menuCCDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        underLineView.backgroundColor = Constant.appColor.borderGray
        
    }

    override func layoutSubviews() {
        
        gradView.layer.cornerRadius = gradView.frame.size.height/2
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func didTapItem(_ sender: Any) {
        
        self.delegate?.didTapItem(cell: self)
    }
    
    
    func setupCell(model: MenuModel) {
        
        titleLabel.text = model.name
        iconImageView.image = UIImage(named: model.icon ?? "")
        
        if model.type == .info {
            
            let grad = SharedManager.shared.getGradient(viewGradient: gradView, colours: [Constant.appColor.lightRed, Constant.appColor.lightBlue], locations: nil, startPoint: CGPoint(x: 0.0, y: 0.5), endPoint: CGPoint(x: 1.0, y: 0.5))
            gradImageView.image = SharedManager.shared.getImageFrom(gradientLayer: grad)
            gradView.isHidden = false
            infoLabel.text = model.info ?? ""
            
        }
        else {
            gradImageView.image = nil
            gradView.isHidden = true
            infoLabel.text = ""
        }
        
    }
}
