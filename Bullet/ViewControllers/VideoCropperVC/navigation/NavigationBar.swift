import Foundation
import UIKit


protocol NavigationBarDelegate: class {
    func didTapNextButton()
    func didTapGallery()
    func didTapCancel()
}

final class NavigationBar: UIView {
    
    private static let NIB_NAME = "NavigationBar"
    
    @IBOutlet private var view: UIView!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet weak var imgdownArrow: UIImageView!
    @IBOutlet weak var lblNext: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var viewNextBusiness: UIView!
    @IBOutlet weak var imgBack: UIImageView!
    
    weak var delegate: NavigationBarDelegate?
    
    override func awakeFromNib() {
        initWithNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initWithNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initWithNib()
    }
    
    private func initWithNib() {
        Bundle.main.loadNibNamed(NavigationBar.NIB_NAME, owner: self, options: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        setupLayout()
        
        imgdownArrow.theme_tintColor = GlobalPicker.downArrowTintColor
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        titleLabel.theme_textColor = GlobalPicker.downArrowTintColor
        
        lblNext.text = NSLocalizedString("NEXT", comment: "")
        lblNext.addTextSpacing(spacing: 2)
        viewNextBusiness.theme_backgroundColor = GlobalPicker.themeCommonColor
        
        hideLoader()
        imgBack.theme_image = GlobalPicker.imgBack
        
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate(
            [
                view.topAnchor.constraint(equalTo: topAnchor),
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
            ]
        )
    }
    
    func showLoader() {
        loader.startAnimating()
        isUserInteractionEnabled = false
    }
    
    func hideLoader() {
        loader.stopAnimating()
        isUserInteractionEnabled = true
    }
    
    @IBAction func didTapNextButton(_ sender: Any) {
        self.delegate?.didTapNextButton()
    }
    
    @IBAction func didTapGallery(_ sender: Any) {
        self.delegate?.didTapGallery()
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.delegate?.didTapCancel()
    }
}
