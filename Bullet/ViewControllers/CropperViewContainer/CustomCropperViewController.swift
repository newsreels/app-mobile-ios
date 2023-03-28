//
//  CustomCropperViewController.swift
//
//  Created by Chen Qizhi on 2019/10/25.
//

import QCropper

class CustomCropperViewController: CropperViewController {

    lazy var customOverlay: CustomOverlayCrop = {
        let co = CustomOverlayCrop(frame: self.view.bounds)
        co.gridLinesCount = 0

        return co
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isCropBoxPanEnabled = false
        topBar.isHidden = true
        angleRuler.isHidden = true
        aspectRatioPicker.isHidden = true
        toolbar.isHidden = true
        
    }

    override func resetToDefaultLayout() {
        super.resetToDefaultLayout()

        aspectRatioLocked = true
        setAspectRatioValue(1.2)
    }
    
    
    func changeAspectRatio(value: CGFloat) {
        setAspectRatioValue(value)
    }
    
    func rotate() {
        
        rotate90degrees(clockwise: false)
    }
 
    func flipImage(isHorizontatal: Bool) {
        
        
        flip(directionHorizontal: isHorizontatal)
    }
    
    func cropImage() -> UIImage? {
        
        let state = saveState()
        let image = originalImage.cropped(withCropperState: state)
        return image
    }
}
