//
//  BlockingLoader.swift
//  Bullet
//
//  Created by Faris Muhammed on 10/02/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import NVActivityIndicatorView
import UIKit

final class BlockingActivityIndicator: UIView {
  private let activityIndicator: NVActivityIndicatorView

  override init(frame: CGRect) {
    self.activityIndicator = NVActivityIndicatorView(
      frame: CGRect(
        origin: .zero,
        size: CGSize(width: 35, height: 35)//NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE
      )
    )
    activityIndicator.type = .circleStrokeSpin
    activityIndicator.startAnimating()
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    super.init(frame: frame)
      backgroundColor = UIColor.black.withAlphaComponent(0.4)
    addSubview(activityIndicator)
    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension UIWindow {
  func startBlockingActivityIndicator() {
    guard !subviews.contains(where: { $0 is BlockingActivityIndicator }) else {
      return
    }

      DispatchQueue.main.async {
          let activityIndicator = BlockingActivityIndicator()
          activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
          activityIndicator.frame = self.bounds
            activityIndicator.tag = 999
          UIView.transition(
            with: self,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
              self.addSubview(activityIndicator)
            }
          )
      }
    
  }
    
    func hideBlockingActivityIndicator(isAnimated: Bool) {
        DispatchQueue.main.async {
            
            if isAnimated {
                UIView.transition(
                    with: self,
                    duration: 0.3,
                    options: .transitionCrossDissolve,
                    animations: {
                        let view  = self.viewWithTag(999)
                        view?.removeFromSuperview()
                    }
                )
            }
            else {
                let view  = self.viewWithTag(999)
                view?.removeFromSuperview()
            }
            
        }
    }
}

extension UIView {
    
    func showLoader(size: CGSize = .zero, color: UIColor = .white, padding: CGFloat? = nil, userInteractionEnabled: Bool = false, backgroundColorNeeded: Bool = false, isShowingFullScreenLoader: Bool = false) {
        
        DispatchQueue.main.async {
            
            var sizeValue = size == .zero ? CGSize(width: self.frame.size.height, height: self.frame.size.height) : size
            if isShowingFullScreenLoader {
                sizeValue = CGSize(width: 50, height: 50)
            }
            
            let loaderView = UIView()
            loaderView.backgroundColor = backgroundColorNeeded ? UIColor.black.withAlphaComponent(0.3) : .clear
            loaderView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            self.addSubview(loaderView)
            
            
            let activityIndicator = NVActivityIndicatorView(frame: CGRect(origin: .zero,size: sizeValue), padding: padding ?? 8)
            activityIndicator.color = color
            activityIndicator.type = .circleStrokeSpin
            activityIndicator.startAnimating()
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            loaderView.tag = 9999
            loaderView.addSubview(activityIndicator)
            
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor),
            ])
            
            if ((self as? UIButton) != nil) {
                (self as? UIButton)?.titleLabel?.removeFromSuperview()
            }
            
            
            self.isUserInteractionEnabled = userInteractionEnabled
        }
        
    }
    
    func hideLoaderView() {
        
        DispatchQueue.main.async {
            if let button = (self as? UIButton) {
                (self as? UIButton)?.addSubview(button.titleLabel ?? UILabel())
            }
            
            self.isUserInteractionEnabled = true
            if let view = self.viewWithTag(9999) {
                for ind in view.subviews {
                    if let ind = ind as? NVActivityIndicatorView {
                        ind.stopAnimating()
                    }
                }
                view.removeFromSuperview()
            }
        }
        
    }
    
    
    
}


extension UIViewController {
    
    func showLoaderInVC(size: CGSize = .zero, color: UIColor = .white, padding: CGFloat? = nil, userInteractionEnabled: Bool = false, backgroundColorNeeded: Bool = true) {
        
        DispatchQueue.main.async {
            
            self.removeLoader()
            var sizeValue = size == .zero ? CGSize(width: self.view.frame.size.height, height: self.view.frame.size.height) : size
            // VC
            sizeValue = CGSize(width: 50, height: 50)
            
            let loaderView = UIView()
            loaderView.backgroundColor = backgroundColorNeeded ? UIColor.black.withAlphaComponent(0.3) : .clear
            loaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.view.addSubview(loaderView)
            
            
            let activityIndicator = NVActivityIndicatorView(frame: CGRect(origin: .zero,size: sizeValue), padding: padding ?? 8)
            activityIndicator.color = color
            activityIndicator.type = .circleStrokeSpin
            activityIndicator.startAnimating()
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            loaderView.tag = 9999
            loaderView.addSubview(activityIndicator)
            
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
            ])
            
            
            self.view.bringSubviewToFront(loaderView)
            
            self.view.isUserInteractionEnabled = userInteractionEnabled
        }
        
    }
    
    func hideLoaderVC() {
        
        DispatchQueue.main.async {
            self.removeLoader()
        }
        
    }
    
    func removeLoader() {
        
        self.view.isUserInteractionEnabled = true
        if let view = self.view.viewWithTag(9999) {
            for ind in view.subviews {
                if let ind = ind as? NVActivityIndicatorView {
                    ind.stopAnimating()
                }
            }
            view.removeFromSuperview()
        }
        
    }
    
    
}
