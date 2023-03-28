//
//  RegionsCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 18/08/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

let SIZE_EXTRA_TEXT: CGFloat               = 50
let COLLECTION_HEIGHT_PLACES: CGFloat      = 40
let CELL_MAX_WIDTH: CGFloat                = 40
let CELL_SPACING: CGFloat                  = 5  //CHECK IN XIB WHICH IS BASDED ON LEADING AND TRAILING


import UIKit

class RegionsCC: UICollectionViewCell {

    @IBOutlet weak var lblRegion: UILabel!
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgFav: UIImageView!
    @IBOutlet weak var trailingSpace: NSLayoutConstraint!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        activityLoader.stopAnimating()
        lblRegion.theme_textColor = GlobalPicker.textColor
        activityLoader.color = MyThemes.current == .dark ? .white : .black
    }

    func setupRegionnCell(region: Location,isFav: Bool) {

        lblRegion.text = region.name?.capitalized ?? ""
        imgFav.image = isFav ? UIImage(named: "tickUnselected") : UIImage(named: "plus")
        viewBG.roundUnSelectedViewWithBorder(view: viewBG)
    }
    
    func setupRegionnCellWithOutBorder(region: Location,isFav: Bool) {

        lblRegion.text = region.name?.capitalized ?? ""
        if isFav {
            imgFav.theme_image = GlobalPicker.selectedTickMarkImage
        }
        else {
            imgFav.theme_image = GlobalPicker.unSelectedTickMarkImage
        }
    }
}


class PlacesCC: UICollectionViewCell {
    
    @IBOutlet weak var lblRegion: UILabel!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var lblR1: UILabel!
    @IBOutlet weak var imgFav: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
