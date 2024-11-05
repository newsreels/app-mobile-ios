//
//  GMView.swift
//
//  Created by faris on 22/02/22.
//

import UIKit

class GMView: UIView {
    
    var shapeLayer = CAShapeLayer()
    var layer1 = CAShapeLayer()
    // 色卡1
    var colors1:[CGColor] = [
        UIColor(displayP3Red: 0.969, green: 0.204, blue: 0.345, alpha: 1).cgColor,
        UIColor(displayP3Red: 0.404, green: 0.408, blue: 0.671, alpha: 1).cgColor
    ]
    // 色卡2

    var colors2:[CGColor] = [
        UIColor(displayP3Red: 0.969, green: 0.204, blue: 0.345, alpha: 1).cgColor,
        UIColor(displayP3Red: 0.404, green: 0.408, blue: 0.671, alpha: 1).cgColor
    ]
         /*
    var colors3:[CGColor] = [
        UIColor(displayP3Red: 0.969, green: 0.204, blue: 0.345, alpha: 1).cgColor,
        UIColor(displayP3Red: 0.744, green: 0.793, blue: 0.846, alpha: 1).cgColor,
        UIColor(displayP3Red: 0.404, green: 0.408, blue: 0.671, alpha: 1).cgColor
    ]*/
    
    var strokeEndFloat:CGFloat = 1 {
        didSet {
            layer1.strokeEnd = strokeEndFloat
        }
    }
    @IBInspectable var lineWidth: CGFloat = 7 {
        willSet
        {
        }
        didSet
        {
            self.layer.removeAllAnimations()
            self.layer.sublayers?.removeAll()
            setUI()
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        backgroundColor = UIColor.clear
        
        setUI()
    }
    
    func setUI() {
        
        shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.bounds
        self.layer.addSublayer(shapeLayer)
        
        // 创建梯形layer
        let leftLayer = CAGradientLayer()
        leftLayer.frame  = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.width/2)
        leftLayer.colors = colors1
        leftLayer.startPoint = CGPoint(x: 0, y: 0.5)
        leftLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        shapeLayer.addSublayer(leftLayer)
        
        
        let rightLayer = CAGradientLayer()
        rightLayer.frame  = CGRect(x: 0, y: self.frame.size.width/2, width: self.frame.size.width, height: self.frame.size.width/2)
        rightLayer.colors = colors2
        rightLayer.startPoint = CGPoint(x: 0.5, y: 0)
        rightLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        shapeLayer.addSublayer(rightLayer)
        
        /*
        let centerLayer = CAGradientLayer()
        centerLayer.frame  = CGRect(x: 0, y: self.frame.size.width/2, width: self.frame.size.width, height: self.frame.size.width/2)
        centerLayer.colors = colors3
        centerLayer.startPoint = CGPoint(x: 0, y: 0.5)
        centerLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        shapeLayer.addSublayer(centerLayer)
        */
        
        // 创建一个圆形layer
        layer1 = CAShapeLayer()
        layer1.frame = self.bounds
        layer1.path = UIBezierPath(arcCenter: CGPoint(x: self.frame.size.width/2, y: self.frame.size.width/2), radius: self.frame.size.width/2 - 10, startAngle: CGFloat(Double.pi/30), endAngle: 2 * CGFloat(Double.pi) - CGFloat(Double.pi/30), clockwise: true).cgPath
        layer1.lineWidth    = lineWidth
        layer1.lineCap      = CAShapeLayerLineCap.round
        layer1.lineJoin     = CAShapeLayerLineJoin.round
        layer1.strokeColor  = UIColor.black.cgColor
        layer1.fillColor    = UIColor.clear.cgColor
        
        // 根据laery1 的layer形状在 shaperLayer 中截取出来一个layer
        shapeLayer.mask = layer1
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue   =  2 * Double.pi
        animation.duration = 1.25
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        self.layer.add(animation, forKey: "")
    }
    
    func startLoading() {
//        stopAnimations()
        /*
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue   =  2 * Double.pi
        animation.duration = 2
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        self.layer.add(animation, forKey: "")
        */
    }
    
    
    func stopAnimations() {
//        self.layer.removeAllAnimations()
    }
    
}
