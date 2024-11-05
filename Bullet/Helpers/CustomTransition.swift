//
//  CustomTransition.swift
//
//

import UIKit

class CustomTransition: NSObject {
    
    var duration = 0.4
            
    var presenting = true
    var originFrame = CGRect.zero

}

extension CustomTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let recipeView = presenting ? transitionContext.view(forKey: .to)! : transitionContext.view(forKey: .from)!

        let initialFrame = presenting ? originFrame : recipeView.frame
        let finalFrame = presenting ? recipeView.frame : originFrame

        let xScaleFactor = presenting ? initialFrame.width / finalFrame.width : finalFrame.width / initialFrame.width
        let yScaleFactor = presenting ? initialFrame.height / finalFrame.height : finalFrame.height / initialFrame.height

        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)

        if presenting {
          recipeView.transform = scaleTransform
          recipeView.center = CGPoint(
            x: initialFrame.midX,
            y: initialFrame.midY)
          recipeView.clipsToBounds = true
        }

        recipeView.layer.cornerRadius = presenting ? 20.0 : 0.0
        recipeView.layer.masksToBounds = true

        containerView.addSubview(recipeView)
        containerView.bringSubviewToFront(recipeView)

        UIView.animate(withDuration: duration, animations: {
            recipeView.transform = self.presenting ? .identity : scaleTransform
            recipeView.layer.cornerRadius = !self.presenting ? 20.0 : 0.0
            recipeView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)

        }, completion: { (success: Bool) in
            transitionContext.completeTransition(success)
        })
    }

}

public class VerticalAlignLabel: UILabel {
    
    enum VerticalAlignment {
        case top
        case middle
        case bottom
    }

    var verticalAlignment : VerticalAlignment = .top {
        didSet {
            setNeedsDisplay()
        }
    }

    override public func textRect(forBounds bounds: CGRect, limitedToNumberOfLines: Int) -> CGRect {
        let rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: limitedToNumberOfLines)

        if UIView.userInterfaceLayoutDirection(for: .unspecified) == .rightToLeft {
            switch verticalAlignment {
            case .top:
                return CGRect(x: self.bounds.size.width - rect.size.width, y: bounds.origin.y, width: rect.size.width, height: rect.size.height)
            case .middle:
                return CGRect(x: self.bounds.size.width - rect.size.width, y: bounds.origin.y + (bounds.size.height - rect.size.height) / 2, width: rect.size.width, height: rect.size.height)
            case .bottom:
                return CGRect(x: self.bounds.size.width - rect.size.width, y: bounds.origin.y + (bounds.size.height - rect.size.height), width: rect.size.width, height: rect.size.height)
            }
        } else {
            switch verticalAlignment {
            case .top:
                return CGRect(x: bounds.origin.x, y: bounds.origin.y, width: rect.size.width, height: rect.size.height)
            case .middle:
                return CGRect(x: bounds.origin.x, y: bounds.origin.y + (bounds.size.height - rect.size.height) / 2, width: rect.size.width, height: rect.size.height)
            case .bottom:
                return CGRect(x: bounds.origin.x, y: bounds.origin.y + (bounds.size.height - rect.size.height), width: rect.size.width, height: rect.size.height)
            }
        }
    }

    override public func drawText(in rect: CGRect) {
        let r = self.textRect(forBounds: rect, limitedToNumberOfLines: self.numberOfLines)
        super.drawText(in: r)
    }
}



