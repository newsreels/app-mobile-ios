//
//  newsCC.swift
//  Bullets_Widgets
//
//  Created by Khadim Hussain on 04/08/2020.
//  Copyright © 2020 Khadim Hussain. All rights reserved.
//

import UIKit

class newsCC: UITableViewCell {


    @IBOutlet weak var lblNews : UILabel!
    @IBOutlet weak var lblTime : UILabel!
    @IBOutlet weak var lblSource : UILabel!
    @IBOutlet weak var lblNewsNumber : UILabel!
    @IBOutlet weak var imgNewsIcon : UIImageView!
    @IBOutlet weak var imgSource : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
