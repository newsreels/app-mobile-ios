//
//  DefaultPageControl.swift
//  Bullet
//
//  Created by Khadim Hussain on 06/07/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit

class DefaultPageControl: UIPageControl {
    
    override var currentPage: Int {
        didSet {
            updateDots()
        }
    }
    
    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        super.sendAction(action, to: target, for: event)
        updateDots()
    }
    
    private func updateDots() {
       
//        var currentDot = UIView()
//        for views in subviews {
//
//            currentDot = views[currentPage]
//        }
        let currentDot = subviews[currentPage]
        let largeScaling = CGAffineTransform(scaleX: 0.9, y: 0.9)
        let smallScaling = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        subviews.forEach {
            // Apply the large scale of newly selected dot.
            // Restore the small scale of previously selected dot
            $0.transform = $0 == currentDot ? largeScaling : smallScaling
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        // We rewrite all the constraints
        rewriteConstraints()
    }
    
    private func rewriteConstraints() {
        let systemDotSize: CGFloat = 6.0
        let systemDotDistance: CGFloat = 10.0
        
        let halfCount = CGFloat(subviews.count) / 2
        subviews.enumerated().forEach {
            let dot = $0.element
            dot.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.deactivate(dot.constraints)
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: systemDotSize),
                dot.heightAnchor.constraint(equalToConstant: systemDotSize),
                dot.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
                dot.centerXAnchor.constraint(equalTo: centerXAnchor, constant: systemDotDistance * (CGFloat($0.offset) - halfCount))
            ])
        }
    }
}
