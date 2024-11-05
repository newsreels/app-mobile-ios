//
//  CropperVC.swift
//  Bullet
//
//  Created by Faris Muhammed on 29/07/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

class CropperVC: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var lblAspectRatio: UILabel!
    @IBOutlet weak var lblRotate: UILabel!
    @IBOutlet weak var lblFlipHorizontal: UILabel!
    @IBOutlet weak var lblFlipVertical: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNext: UILabel!
    @IBOutlet weak var viewNextButton: UIView!
    @IBOutlet weak var imgBack: UIImageView!
    
    var selectedImage = UIImage()
    
    var didSave: ((YPMediaItem) -> Void)?
    var didCancel: (() -> Void)?
    
    var controller: CustomCropperViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setLocalization()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.isHidden = true
        
        addCropVCToContainer()
        
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        lblTitle.theme_textColor = GlobalPicker.downArrowTintColor
        lblAspectRatio.theme_textColor = GlobalPicker.downArrowTintColor
        
        lblRotate.theme_textColor = GlobalPicker.cropTextColor
        lblFlipVertical.theme_textColor = GlobalPicker.cropTextColor
        lblFlipHorizontal.theme_textColor = GlobalPicker.cropTextColor
        
        viewNextButton.theme_backgroundColor = GlobalPicker.themeCommonColor
        
        
        imgBack.theme_image = GlobalPicker.imgBack
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.navigationBar.isHidden = true
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
        navigationController?.navigationBar.isHidden = false
        
    }
    
    
    func setLocalization() {
        
        lblNext.text = NSLocalizedString("NEXT", comment: "")
        lblNext.addTextSpacing(spacing: 2)
        lblTitle.text = NSLocalizedString("Crop", comment: "")
        lblAspectRatio.text = NSLocalizedString("Aspect Ratio", comment: "")
        lblRotate.text = NSLocalizedString("Rotate", comment: "")
        lblFlipVertical.text = NSLocalizedString("Flip Vertical", comment: "")
        lblFlipHorizontal.text = NSLocalizedString("Flip Horizontal", comment: "")
    }
    
    
    func addCropVCToContainer() {
        
        controller = CustomCropperViewController(originalImage: selectedImage)
        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(controller.view)
        
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        controller.didMove(toParent: self)
        
    }
    
    
    // MARK: - Button Actions
    @IBAction func didTapAspectRatio16by9(_ sender: Any) {
        
        controller.changeAspectRatio(value: 16/9)
    }
    @IBAction func didTapAspectRatio9by16(_ sender: Any) {
        controller.changeAspectRatio(value: 9/16)
    }
    
    @IBAction func didTapAspectRatio1by1(_ sender: Any) {
        controller.changeAspectRatio(value: 1)
    }
    
    @IBAction func didTapRotate(_ sender: Any) {
        
        controller.rotate()
    }
    
    @IBAction func didTapFlipVertical(_ sender: Any) {
        controller.flipImage(isHorizontatal: false)
    }
    
    @IBAction func didTapFlipHorizontal(_ sender: Any) {
        controller.flipImage(isHorizontatal: true)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        didCancel?()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        
        guard let didSave = self.didSave else { return print("Don't have saveCallback") }
        
        if let image = controller.cropImage() {
            let result = YPMediaPhoto(image: image)
            didSave(YPMediaItem.photo(p: result))
        } else {
            
            didTapBack(UIButton())
        }
        
        

        
    }
    
}
