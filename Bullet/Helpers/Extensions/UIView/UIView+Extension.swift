//
//  UIView+Extension.swift
//  Bullet
//
//  Created by Khadim Hussain on 18/08/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AVFoundation

extension UIView {
    func cardView() -> Void {
        self.layer.cornerRadius = 12
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.5
    }
    
    func roundSelectedViewWithBorder(view:UIView, radius: CGFloat = 8, borderWidth: CGFloat = 2.0) {
        
        view.layer.cornerRadius = radius
        view.borderWidth = borderWidth
        view.borderColor = .customViewRedColor
        view.layer.masksToBounds = true
    }
    
    func roundUnSelectedViewWithBorder(view:UIView, radius: CGFloat = 8, borderWidth: CGFloat = 1.0) {
        
        view.layer.cornerRadius = view.layer.frame.size.height / 2
        view.borderWidth = borderWidth
        view.borderColor = .customViewGreyColor
        view.layer.masksToBounds = true
    }
    
    /* The color of the shadow. Defaults to opaque black. Colors created
     * from patterns are currently NOT supported. Animatable. */
    @IBInspectable var shaddowColor: UIColor? {
        set {
            layer.shadowColor = newValue!.cgColor
        }
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor:color)
            }
            else {
                return nil
            }
        }
    }
    
    /* The opacity of the shadow. Defaults to 0. Specifying a value outside the
     * [0,1] range will give undefined results. Animatable. */
    /*
    @IBInspectable var shadowOpacity: Float {
        set {
            layer.shadowOpacity = newValue
        }
        get {
            return layer.shadowOpacity
        }
    }
    
    /* The shadow offset. Defaults to (0, -3). Animatable. */
    @IBInspectable var shadowOffset: CGPoint {
        set {
            layer.shadowOffset = CGSize(width: newValue.x, height: newValue.y)
        }
        get {
            return CGPoint(x: layer.shadowOffset.width, y:layer.shadowOffset.height)
        }
    }
    */
    /* The blur radius used to create the shadow. Defaults to 3. Animatable. */
    /*
    @IBInspectable var shadowRadius: CGFloat {
        set {
            layer.shadowRadius = newValue
        }
        get {
            return layer.shadowRadius
        }
    }*/
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor:color)
            }
            else {
                return nil
            }
        }
    }
    @IBInspectable var borderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    func roundCorners(_ corner: UIRectCorner,_ radii: CGFloat) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.layer.bounds
        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corner, cornerRadii: CGSize(width: radii, height: radii)).cgPath
        
        self.layer.mask = maskLayer
        layer.masksToBounds = true
    }
    
    // This round corners ftn is for UIView half circular
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        //UIBezierPath(semiCircleMidpoint: CGPoint.zero, radius: 100, facingDirection: .UpFacing)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 5
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func addBorder(){
        layer.borderWidth = 1
        layer.borderColor = UIColor(displayP3Red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).cgColor
    }
    
    
    // Add Full rounded Shadow on UIView
    func addRoundedShadowCell() {
        
        self.layer.shadowColor = UIColor(displayP3Red: 4.0/255.0, green: 4.0/255.0, blue: 4.0/255.0, alpha: 0.1).cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.7
        self.layer.masksToBounds = false
        
        //        self.layer.masksToBounds = false
        //        self.layer.cornerRadius = 12
        //        self.layer.shadowColor = UIColor(displayP3Red: 4.0/255.0, green: 4.0/255.0, blue: 4.0/255.0, alpha: 0.1).cgColor
        //        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        //        self.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        //        self.layer.shadowOpacity = 0.7
        //        self.layer.shadowRadius = 2
    }
    
    // Add Shadow on bottom and right side of UIView
    func addBottomRightShadow() {
        
        self.layer.shadowColor = UIColor(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.1).cgColor
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 5.0
        self.layer.masksToBounds = false
    }
    
    // Add Shadow on rounded UIView
    func addRoundedShadow(_ opacity: Float = 0.8) {
        
        self.layer.shadowColor = UIColor(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.1).cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = 5.0
        self.layer.masksToBounds = false
    }
    
    func addRoundedShadowPref() {
        
        self.layer.shadowColor = UIColor(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.3).cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 5.0
        self.layer.masksToBounds = false
    }
    
    func addRoundedShadowWithColor(color:UIColor, shadowOpacity:Float = 0.4, shadowRadius: CGFloat = 4) {
        
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.masksToBounds = false
    }
    
    // Appstore like shadow
    func addBottomShadowForDiscoverPage(_ opacity: Float = 0.5) {
        
        //        self.layer.shadowColor = UIColor(displayP3Red: 4.0/255.0, green: 4.0/255.0, blue: 4.0/255.0, alpha: 0.1).cgColor
        //        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        //        self.layer.shadowRadius = 7.0
        //        self.layer.shadowOpacity = opacity
        //        self.layer.masksToBounds = false
        self.layer.cornerRadius = 10.0
        self.layer.theme_shadowColor = GlobalPicker.shadowColorDiscover
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.5
    }
    
    // Add Shadow on Bottom of UIView
    func addBottomShadow(_ opacity: Float = 0.7) {
        
        self.layer.shadowColor = UIColor(displayP3Red: 4.0/255.0, green: 4.0/255.0, blue: 4.0/255.0, alpha: 0.1).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowRadius = 3.0
        self.layer.shadowOpacity = opacity
        self.layer.masksToBounds = false
    }
    
    // Add Shadow on Top of rounded UIView
    func addTopShadow() {
        
        self.layer.shadowColor = UIColor(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.1).cgColor
        self.layer.cornerRadius = 20
        self.layer.shadowOffset = CGSize(width: 0 , height:0)
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.7
        self.layer.masksToBounds = false
    }
    
    func animationZoom(scaleX: CGFloat, y: CGFloat) {
        self.transform = CGAffineTransform(scaleX: scaleX, y: y)
    }
    
    func animationRoted(angle : CGFloat) {
        self.transform = self.transform.rotated(by: angle)
    }
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.3) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        self.layer.add(animation, forKey: nil)
    }
    
    func addShadow(cornerRadius : CGFloat, fillColor : UIColor) {
        
        var shadowLayer: CAShapeLayer!
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = fillColor.cgColor
            
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            shadowLayer.shadowOpacity = 0.2
            shadowLayer.shadowRadius = 3
            
            self.layer.insertSublayer(shadowLayer, at: 0)
        }
    }
    
    func addShadowCustom(cornerRadius : CGFloat, shadowColor : UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1), shadowRadius: CGFloat, shadowOpacity: Float, shadowOffset: CGSize = CGSize(width: 0, height: 2)) {
        
        var shadowLayer: CALayer!
        
        if shadowLayer == nil {
            
            shadowLayer = CALayer()

            let shadowPath0 = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius)
            
            shadowLayer.shadowPath = shadowPath0.cgPath

            shadowLayer.shadowColor = shadowColor.cgColor

            shadowLayer.shadowOpacity = shadowOpacity

            shadowLayer.shadowRadius = shadowRadius

            shadowLayer.shadowOffset = shadowOffset

//            shadowLayer.bounds = self.bounds
//
//            shadowLayer.position = self.center

            self.layer.insertSublayer(shadowLayer, at: 0)
            
        }
        
    }
    
    
    func addShadowNew(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity

        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
    
    
    func addDashedBorder(_ color: UIColor) {
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [6,3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
    
    func searchVisualEffectsSubview() -> UIVisualEffectView? {
        
        if let visualEffectView = self as? UIVisualEffectView {
            return visualEffectView
        }
        else {
            
            for subview in subviews {
                if let found = subview.searchVisualEffectsSubview() {
                    return found
                }
            }
        }
        
        return nil
    }
    
    /** Loads instance from nib with the same name. */
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }

    
    func fadeIn(_ duration: TimeInterval = 0.25, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.25
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 0.25, delay: TimeInterval = 1.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.1
        }, completion: completion)
    }

    
    func addDashedBorder(_ cornerRadi: CGFloat = 8) {
        
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.name = "DashBorder"
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.width/2, y: bounds.height/2)
        shapeLayer.fillColor = nil
        shapeLayer.theme_strokeColor = GlobalPicker.borderColor
        shapeLayer.lineWidth = 1.5
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round // Updated in swift 4.2
        shapeLayer.lineDashPattern = [6,6]
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadi).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }

    func roundViewCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.name = "gradient"
        self.layer.insertSublayer(gradient, at:0)
    }

    func addGradientBackground(firstColor: UIColor, secondColor: UIColor){
        clipsToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        print(gradientLayer.frame)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func removeGradient() {
        
        if (self.layer.sublayers?.count ?? 0) > 0 {
            self.layer.sublayers?.forEach {
                if $0.name == "gradient" {
                    $0.removeFromSuperlayer()
                }
            }
        }
        
        
    }

    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    func addTopShadowWithColor(color:UIColor) {
        
        self.layer.shadowColor = color.cgColor
        self.layer.cornerRadius = 20
        self.layer.shadowOffset = CGSize(width: 0 , height:0)
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.4
        self.layer.masksToBounds = false
    }
}

//We will get image from UIView
extension UIView {
    func scale(by scale: CGFloat) {
        self.contentScaleFactor = scale
        for subview in self.subviews {
            subview.scale(by: scale)
        }
    }

    func getImage(scale: CGFloat? = nil) -> UIImage {
        let newScale = scale ?? UIScreen.main.scale
        self.scale(by: newScale)

        let format = UIGraphicsImageRendererFormat()
        format.scale = newScale

        let renderer = UIGraphicsImageRenderer(size: self.bounds.size, format: format)

        let image = renderer.image { rendererContext in
            self.layer.render(in: rendererContext.cgContext)
        }
        return image
    }
    
    func addShadowView() {
        //Remove previous shadow views
        superview?.viewWithTag(119900)?.removeFromSuperview()

        //Create new shadow view with frame
        let shadowView = UIView(frame: frame)
        shadowView.tag = 119900
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 3)
        shadowView.layer.masksToBounds = false

        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        shadowView.layer.rasterizationScale = UIScreen.main.scale
        shadowView.layer.shouldRasterize = true

        superview?.insertSubview(shadowView, belowSubview: self)
    }
    
}

extension Bundle {

    static func loadView<T>(fromNib name: String, withType type: T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }
        fatalError("Could not load view with type " + String(describing: type))
    }
}


extension UIView {
    func gradient(colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.transform = CATransform3DMakeRotation(270 / 180 * CGFloat.pi, 0, 0, 1) // New line
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        gradientLayer.opacity = 1.0
        gradientLayer.name = "gradient"
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UIView {
    var isVisible: Bool {
        get {
            guard let superview = superview else { return false }
            let viewFrame = superview.convert(frame, to: nil)
            let screenBounds = UIScreen.main.bounds
            let intersection = screenBounds.intersection(viewFrame)
            return !intersection.isEmpty && intersection.size.width >= 1 && intersection.size.height >= 1
        }
    }

    func isNotOverlaid() -> Bool {
           var currentView: UIView? = self
           while let view = currentView {
               if let superview = view.superview {
                   let myFrame = superview.convert(view.frame, to: self)
                   if !self.bounds.contains(myFrame) {
                       return false
                   }
                   currentView = superview
               } else {
                   break
               }
           }
           return true
       }
}
