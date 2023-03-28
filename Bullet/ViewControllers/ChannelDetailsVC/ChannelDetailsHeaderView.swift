
import UIKit
import ActiveLabel

class ChannelDetailsHeaderView: UIView {
    
    @IBOutlet weak var viewRounded: UIView!
    @IBOutlet weak var viewBG: UIView!
//    @IBOutlet weak var imgCover: UIImageView!
//    @IBOutlet weak var viewProfileBG: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgVerified: UIImageView!
    @IBOutlet weak var lblDescription: ActiveLabel!

    
    @IBOutlet weak var lblusername: UILabel!
    @IBOutlet weak var lblChannelName: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblPost: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var lblReels: UILabel!
    
    @IBOutlet weak var btnModTools: UIButton!
    @IBOutlet weak var btnFollow: UIButton!
//    @IBOutlet weak var btnProfile: UIButton!
//    @IBOutlet weak var btnCover: UIButton!
    
//    @IBOutlet weak var viewPhotoBG: UIView!
//    @IBOutlet weak var viewCoverPhotoBG: UIView!
    
//    @IBOutlet weak var viewModeTools: UIView!
//    @IBOutlet weak var lblModeTools: UILabel!
//    @IBOutlet weak var imgTools: UIImageView!
    
//    @IBOutlet weak var viewFollow: UIView!
//    @IBOutlet weak var lblFollow: UILabel!
    
//    @IBOutlet weak var btnFollowers: UIButton!
//    @IBOutlet weak var btnPosts: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        //backgroundColor = .cyan
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        
        viewRounded.roundCorners(corners: [.topLeft,.topRight], radius: 14)
        btnFollow.layer.shadowColor = UIColor.black.cgColor
        btnFollow.layer.shadowOffset = CGSize(width: 0.0, height: 5)
        btnFollow.layer.shadowOpacity = 0.1
        btnFollow.layer.shadowRadius = 10
        btnFollow.layer.masksToBounds = false
        btnFollow.layer.cornerRadius = 12

    }
}
