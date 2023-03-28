//
//  ReelsSubtitle+Extension.swift
//  Bullet
//
//  Created by Khadim Hussain on 28/09/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import AVFoundation
import PlayerKit
import ActiveLabel
import CoreHaptics
import SwiftAutoLayout
import ImageSlideshow

extension ReelsCC {
    
    func setupSubTitleForReels(label: UILabel, containerView:UIView, caption:Captions) {
        
        let aniName = (caption.animation ?? "").isEmpty ? "" : caption.animation ?? ""
        var aniDuration = (caption.animation_duration ?? 0) <= 0 ? 2000 : caption.animation_duration ?? 2000
        aniDuration = aniDuration / 1000 //(ms/1000)milliseconds to seconds

        if let position = caption.position {
                        
            var containerViewTrailing: CGFloat = 0.0
            var containerViewBottom: CGFloat = 0.0
            var containerViewTop: CGFloat = 0.0
            var containerViewLeading: CGFloat = 0.0
            
            let xPosition = (self.viewSubTitle.frame.size.width * CGFloat(position.x ?? 0)) / 100
            let yPosition = (self.viewSubTitle.frame.size.height * CGFloat(position.y ?? 0)) / 100
    
            if let margin = caption.margin {
                
                containerViewTrailing = CGFloat(margin.right ?? 0.0)
                containerViewBottom = CGFloat(margin.bottom ?? 0.0)
                containerViewTop = CGFloat(margin.top ?? 0.0)
                containerViewLeading = CGFloat(margin.left ?? 0.0)
            }
            
            
            if caption.y_direction == "top" {
                
                containerView.constrain(to: viewSubTitle).top(constant: yPosition + containerViewTop)
                containerView.constrain(to: viewSubTitle).bottom(.greaterThanOrEqual, constant: xPosition + containerViewBottom, multiplier: 0.5, priority: .defaultLow, activate: false)
                
                if caption.rotation != 0 {
                    
                    print("side Label-- Top")
                    containerView.constrain(to: viewSubTitle).leading( multiplier: 0.5, priority: .defaultLow, activate: false)
                }
                else {
                    
                    containerView.constrain(to: viewSubTitle).leading(constant: xPosition + containerViewLeading)
                    if let wrapping = caption.wrapping, wrapping == true {
                        
                        containerView.constrain(to: viewSubTitle).trailing(.greaterThanOrEqual, constant: xPosition + containerViewTrailing)
                    }
                    else {
                        
                        containerView.constrain(to: viewSubTitle).trailing(constant: xPosition + containerViewTrailing)
                    }
                }
            }
            else {
                
                containerView.constrain(to: viewSubTitle).bottom(constant: yPosition + containerViewBottom)
                containerView.constrain(to: viewSubTitle).top(.greaterThanOrEqual, constant: xPosition + containerViewTop, multiplier: 0.5, priority: .defaultLow, activate: false)
                
                if caption.rotation != 0 {
                    
                    print("side Label-- Bottom")
                    containerView.constrain(to: viewSubTitle).leading( multiplier: 0.5, priority: .defaultLow, activate: false)
           
                } else {
                    
                    
                    containerView.constrain(to: viewSubTitle).leading(constant: xPosition + containerViewLeading)
                    if let wrapping = caption.wrapping, wrapping == true {
                        
                        containerView.constrain(to: viewSubTitle).trailing(.greaterThanOrEqual, constant: xPosition + containerViewTrailing)
                        
                    }
                    else {
                        
                        containerView.constrain(to: viewSubTitle).trailing(constant: xPosition + containerViewTrailing)
                    }
                }
            }
            if let padding = caption.padding {
              
                label.constrain(to: containerView).leading(constant: CGFloat(padding.left ?? 0.0))
                label.constrain(to: containerView).trailing(constant: CGFloat(padding.right ?? 0.0))
                label.constrain(to: containerView).top(constant: CGFloat(padding.top ?? 0.0))
                label.constrain(to: containerView).bottom(constant: CGFloat(padding.bottom ?? 0.0))
            }
            
        }
        
        if (caption.sentence ?? "").detectRightToLeft() {
            if caption.alignment == "left" {
                
                label.textAlignment = .right
            }
            else if caption.alignment == "center" {
                
                label.textAlignment = .center
            }
            else {
                
                label.textAlignment = .left
            }
        }
        else {
            if caption.alignment == "left" {
                
                label.textAlignment = .left
            }
            else if caption.alignment == "center" {
                
                label.textAlignment = .center
            }
            else {
                
                label.textAlignment = .right
            }
        }
        
        
       // if caption.rotation != 0 {
        label.numberOfLines = caption.rotation != 0 ? 1 : 0
        label.sizeToFit()
        
        if let bgColor = caption.text_background, bgColor.isEmpty || bgColor == "" {
            
            containerView.backgroundColor = .clear
        }
        else {
            
            containerView.backgroundColor = caption.text_background?.hexStringToUIColor()
        }
     //   containerView.backgroundColor = .red
        containerView.cornerRadius = CGFloat(caption.corner_radius)
        containerView.clipsToBounds = true
        containerView.alpha = 0
        
        if caption.rotation != 0 {
            
            containerView.alpha = 1.0
        }
        else {
            
            if aniName.contains("fade_in") {
                
                UIView.transition(with: containerView, duration: aniDuration, options: .transitionCrossDissolve,
                  animations: {
                    containerView.alpha = 1.0
                  },completion: nil)
            }
            else if aniName.contains("zoom_in") {
                
                containerView.transform = CGAffineTransform.identity.scaledBy(x: 0.2, y: 0.2)
                UIView.animate(withDuration: aniDuration, delay: 0.0, options: .curveEaseIn, animations: {
                        
                    containerView.alpha = 1.0
                    containerView.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1) // Scale your image

                 }) { (finished) in
                     UIView.animate(withDuration: aniDuration, animations: {
                       
                         containerView.transform = CGAffineTransform.identity // undo in 1 seconds
                   })
                }
            }
            else if aniName.contains("curveEase_Out") {
                
                UIView.transition(with: containerView, duration: aniDuration, options: .curveEaseOut,
                  animations: {
                    containerView.alpha = 1.0
                  },completion: nil)
            }
            else if aniName.contains("curve_Linear") {
                
                UIView.transition(with: containerView, duration: aniDuration, options: .curveLinear,
                  animations: {
                    containerView.alpha = 1.0
                  },completion: nil)
            }
            containerView.alpha = 1.0
        }
        
        let isClickable = caption.is_clickable ?? false
        let actionName = caption.action ?? ""

        if isClickable {
            let tapClick = UITapGestureRecognizer(target: self, action: #selector(singleTapClickable(_:)))
            tapClick.numberOfTapsRequired = 1
            tapClick.view?.accessibilityIdentifier = actionName
            containerView.isUserInteractionEnabled = true
            containerView.addGestureRecognizer(tapClick)
        }
    }
    
    @objc func singleTapClickable(_ sender: UITapGestureRecognizer) {
        
        let actionType = sender.view?.accessibilityIdentifier ?? ""
        if !actionType.isEmpty {
            self.delegate?.didTapOpenCaptionType(cell: self, action: actionType)
        }
    }
    
    func updateSubTitlesWithTime(currTime: Double, captions:[Captions]) {
        
//        print("Video add label called")
        //I'm checking all caption with loop. using Index as caption id
        for (index, caption) in captions.enumerated() {
            
            //If we are getting only one caption and that is source name for right side alignment then i'm showing default
        
            if let duration = caption.duration {
                
                var startTime = 0.0
                var endTime = 0.0
                if let timeMS = duration.start {
                    
                    startTime = (timeMS / 1000)
                }
                if let timeMS = duration.end {
                    
                    endTime = (timeMS / 1000)
                }
                
                if SharedManager.shared.isCaptionsEnableReels == false {
                    
                    if viewSubTitle != nil && captionsArr?.count ?? 0 > 0 {
                        
                        for (i, captionRemoved) in captions.enumerated() {
                            
                            if let viewCaption = self.viewSubTitle.viewWithTag(i + 1) {
                                
                                if captionRemoved.forced == false {
                                    
                                    let labels = getLabelsInView(view:viewCaption)
                                    for captionLabel in labels {
                                        
                                        if captionLabel.tag == viewCaption.tag {
                                     
                                            captionLabel.removeFromSuperview()
                                            self.captionsArr?.remove(object: captionLabel)
                                        }
                                    }
                                    
                                    viewCaption.removeFromSuperview()
                                    self.captionsViewArr?.remove(object: viewCaption)
                                    
                                }
                            }
                        }
                    }
                }
                
                //I'm checking the Caption that are in current video time
                if currTime >= startTime && currTime <= endTime {
                    
                    //Here i'm checking on the base captions array count that i have captions or not
                    if let captionsArray = captionsArr, captionsArray.count >= 0 {
                        
                        if captionsArray.contains(where: {$0.tag == index + 1}) {
                            
                            if viewSubTitle != nil, let viewCaption = self.viewSubTitle.viewWithTag(index + 1) {
                                
                                if currTime >= endTime {
                                    
                                    //we need to hide both view and label
                                    let labels = getLabelsInView(view:viewCaption)
                                    for captionLabel in labels {
                                        
                                        if captionLabel.tag == viewCaption.tag {
                                            
                                            captionLabel.removeFromSuperview()
                                            self.captionsArr?.remove(object: captionLabel)
                                        }
                                    }
                                   
                                    viewCaption.removeFromSuperview()
                                    self.captionsViewArr?.remove(object: viewCaption)
                                    
                                }
                                else {
                                    
                                    //If captions time not over then i'm updating text only
                                    if let captionLabel = viewCaption.viewWithTag(viewCaption.tag) as? UILabel {
                                        
                                        self.updateSelectedSubTitleLable(label: captionLabel, caption: caption, containerView: viewCaption)
                                    }
                                    
                                }
                            }
                        }
                        else {
                            
                            //Multi captions
                            // If we have news caption then i'm creating.
                            
                            //If caption is off by user butt still we need to show caption.
                            if SharedManager.shared.isCaptionsEnableReels == false && caption.forced == false {
                         
                            }
                            else {
                                
                                let containerView = UIView()
                                let label = UILabel()
                                
                                self.setupSubTitleForReels(label: label, containerView: containerView, caption: caption)
                                label.tag = index + 1
                                containerView.tag = index + 1
                         
                                self.captionsArr?.append(label)
                                self.captionsViewArr?.append(containerView)
                                self.updateSelectedSubTitleLable(label: label, caption: caption, containerView: containerView)
                            }
                        }
                    }
                    else {
                        
                        
                        //The very 1st caption
                        //If caption is off by user butt still we need to show caption.
                        if SharedManager.shared.isCaptionsEnableReels == false && caption.forced == false {
                            
                            
                        }
                        else {
                            
                            let containerView = UIView()
                            let label = UILabel()
                            
                            self.setupSubTitleForReels(label: label, containerView: containerView, caption: caption)
                            label.tag = index + 1
                            containerView.tag = index + 1
                            
                            self.captionsArr?.removeAll()
                            self.captionsViewArr?.removeAll()
                            
                            self.captionsArr = [UILabel]()
                            self.captionsViewArr = [UIView]()
                            
                            self.captionsArr?.append(label)
                            self.captionsViewArr?.append(containerView)
                            
                            self.updateSelectedSubTitleLable(label: label, caption: caption, containerView: containerView)
                            
                        }
                    }
                }
                else {
                    
                    // For fixing overlapping issues added this
                    // remove labels if still showing after time period
                    self.viewSubTitle.viewWithTag(index + 1)?.removeFromSuperview()
                    
                    if let captionsArr = captionsArr {
                        for label in captionsArr {
                            if label.tag == index + 1 {
                                label.removeFromSuperview()
                                self.captionsArr?.remove(object: label)
                            }
                        }
                    }
                    
                    if let captionsViewArr = captionsViewArr {
                        for viewCaption in captionsViewArr {
                            if viewCaption.tag == index + 1 {
                                viewCaption.removeFromSuperview()
                                self.captionsViewArr?.remove(object: viewCaption)
                            }
                        }
                    }
                    
                    
                }
            }
        }
    }
    
    
    func updateSelectedSubTitleLable(label: UILabel, caption: Captions, containerView: UIView) {
        
        if let words = caption.words {
            
            if words.count == 1 {
                
                let color = words.first?.font?.color ?? ""
                let word = words.first?.word ?? ""
                let size = (words.first?.font?.size ?? 22)  + adjustFontSizeForiPad()
                let shadowColor = words.first?.shadow?.color ?? "#000000"
                let style = SharedManager.shared.getFamilyName(font: words.first?.font)
                

                var highlightColor: UIColor = .clear
                if let color = words.first?.highlight_color, color == "" {
                    
                    highlightColor = UIColor(r: 0, g: 0, b: 0, a: 0)
                }
                else {
                    
                    highlightColor = (words.first?.highlight_color ?? "").hexStringToUIColor()
                }
                
                let shadow = NSShadow()
                shadow.shadowColor = shadowColor.hexStringToUIColor()
                shadow.shadowOffset = CGSize(width: words.first?.shadow?.x ?? 0, height: words.first?.shadow?.y ?? 0)
                shadow.shadowBlurRadius = CGFloat(words.first?.shadow?.radius ?? 0)
//                if words.first?.shadow_color == nil {
//                    shadow.shadowBlurRadius = 0
//                } else {
//                    shadow.shadowBlurRadius = 3
//                }
                

                var myAttribute = [NSAttributedString.Key : Any]()
                if let isUnderLine = words.first?.underline, isUnderLine {
                    
                    myAttribute = [.foregroundColor: color.hexStringToUIColor(),
                                   .font: UIFont(name: style, size: CGFloat(size)) ?? UIFont.boldSystemFont(ofSize: 18),
                                   .underlineStyle:NSUnderlineStyle.single.rawValue,
                                   .backgroundColor:highlightColor,
                                   .strokeColor: shadowColor.hexStringToUIColor(),
                                   .strokeWidth: -1.5,
                                   .shadow: shadow] as [NSAttributedString.Key : Any]
                }
                else {
                    
                    myAttribute = [.foregroundColor: color.hexStringToUIColor(),
                                   .font: UIFont(name: style, size: CGFloat(size)) ?? UIFont.boldSystemFont(ofSize: 18),
                                   .backgroundColor:highlightColor,
                                   .strokeColor: shadowColor.hexStringToUIColor(),
                                   .strokeWidth: -1.5,
                                   .shadow: shadow] as [NSAttributedString.Key : Any]
                }
                
                let myString = NSMutableAttributedString(string: word, attributes: myAttribute)
                
                label.attributedText =  myString
    
                
                if let imageBG = caption.image_background, imageBG != "" && label.text != "" {
                     
                    let image = UIImageView()
                    let width = label.frame.size.width
                    let height = label.frame.size.height
                    image.frame = CGRect(x: 0, y: 0, width: width, height: height)
                    image.constrain(to: containerView).leading(constant: 0.0)
                //    image.constrain(to: containerView).trailing(constant: 0.0)
//                    image.constrain(to: containerView).top(constant: 0.0)
//                    image.constrain(to: containerView).bottom(constant: 0.0)
                    image.contentMode = .scaleToFill
                    image.clipsToBounds = true
                    image.sd_setImage(with: URL(string: imageBG))
                    containerView.bringSubviewToFront(label)
                }
                
                if caption.rotation != 0 {
                    
                    print("side Label single word")
                    
                    self.viewSubTitle.layoutIfNeeded()
                    containerView.layoutIfNeeded()
                    
                    let xPosition = (self.viewSubTitle.frame.size.width * CGFloat(caption.position?.x ?? 0)) / 100
                    let width = (label.frame.size.width / 2)  + (label.frame.size.height / 2)
                    var trailingSpace = self.viewSubTitle.frame.size.width - (xPosition + CGFloat(caption.margin?.left ?? 0.0))
                    trailingSpace = trailingSpace - width

                    let rotation = CGFloat(caption.rotation ?? 90.0)
                    let angle = ((rotation * -1.0) * CGFloat.pi/180.0)
                    containerView.transform = CGAffineTransform(rotationAngle: CGFloat(angle))

                    containerView.constrain(to: viewSubTitle).trailing(constant:(trailingSpace))
                    containerView.constrain(to: viewSubTitle).leading( multiplier: 0.5, priority: .defaultLow, activate: false)
                    
                    self.viewSubTitle.layoutIfNeeded()
                    containerView.layoutIfNeeded()
                    
                }
            }
            else {
                
                var i = 0
                var attrStringArr = [NSMutableAttributedString]()
                
                let delay = words[i].delay ?? 0
                Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { (timer) in
                    
                    //label.text = label.text! + String(words[i].word ?? "") + " "
                    let color = words[i].font?.color ?? "#000000"
                    let shadowColor = words[i].shadow?.color ?? "#000000"
                    let word = words[i].word ?? ""
                    let size = (words[i].font?.size ?? 22) + self.adjustFontSizeForiPad()
                    
                    let style = SharedManager.shared.getFamilyName(font: words[i].font)

                    var highlightColor: UIColor = .clear
                    if let color = words[i].highlight_color, color == "" {
                        
                        highlightColor = UIColor(r: 0, g: 0, b: 0, a: 0)
                    }
                    else {
                        //print("mahesh....", words.first?.word ?? "", words.first?.highlight_color ?? "")
                        highlightColor = (words[i].highlight_color ?? "").hexStringToUIColor()
                    }
                    
                    let shadow = NSShadow()
                    shadow.shadowColor = shadowColor.hexStringToUIColor()
                    shadow.shadowOffset = CGSize(width: words[i].shadow?.x ?? 0, height: words[i].shadow?.y ?? 0)
                    shadow.shadowBlurRadius = CGFloat(words[i].shadow?.radius ?? 0)
//                    if words[i].shadow?.color == nil {
//                        shadow.shadowBlurRadius = 0
//                    }
//                    else {
//                        shadow.shadowBlurRadius = 3
//                    }
//

                    var myAttribute = [NSAttributedString.Key : Any]()
                    if words[i].underline ?? false {
                        
                        myAttribute = [.foregroundColor: color.hexStringToUIColor(),
                                        .font: UIFont(name: style, size: CGFloat(size)) ?? UIFont.boldSystemFont(ofSize: 14),
                                        .underlineStyle: NSUnderlineStyle.single.rawValue,
                                        .backgroundColor: highlightColor,
                                       .strokeColor: shadowColor.hexStringToUIColor(),
                                       .strokeWidth: -1.5,
                                        .shadow: shadow] as [NSAttributedString.Key : Any]
                    }
                    else {
                        
                        myAttribute = [.foregroundColor: color.hexStringToUIColor(),
                                       .font: UIFont(name: style, size: CGFloat(size)) ?? UIFont.boldSystemFont(ofSize: 14),
                                       .backgroundColor: highlightColor,
                                       .strokeColor: shadowColor.hexStringToUIColor(),
                                       .strokeWidth: -1.5,
                                       .shadow: shadow] as [NSAttributedString.Key : Any]
                    }
                    
                    let myString = NSMutableAttributedString(string: word, attributes: myAttribute)

                    label.attributedText = myString
                    attrStringArr.append(myString)

                    let mergeString = NSMutableAttributedString()
                    for attstr in attrStringArr {
                        mergeString.append(attstr)
                    }
                    label.attributedText = mergeString

   
                    if i == words.count - 1 {
                        timer.invalidate()
                    } else {
                        i = i + 1
                    }
                }
            }
            label.isHidden = false
       
            if let imageBG = caption.image_background, imageBG != "" && label.text != "" {
                
                let image = UIImageView()
                let width = label.frame.size.width
                let height = label.frame.size.height
                image.frame = CGRect(x: 0, y: 0, width: width, height: height)
                image.constrain(to: containerView).leading(constant: 0.0)
//                image.constrain(to: containerView).trailing(constant: 0.0)
//                image.constrain(to: containerView).top(constant: 0.0)
//                image.constrain(to: containerView).bottom(constant: 0.0)
                image.contentMode = .scaleToFill
                image.clipsToBounds = true
               // image.image = UIImage(named: "testBG")
                image.sd_setImage(with: URL(string: imageBG))
                containerView.bringSubviewToFront(label)
            }
            if caption.rotation != 0 {

                print("side Label Multi word")

                containerView.layoutIfNeeded()
                let xPosition = (self.viewSubTitle.frame.size.width * CGFloat(caption.position?.x ?? 0)) / 100
                let width = (label.frame.size.width / 2) + (label.frame.size.height / 2)
                var trailingSpace = self.viewSubTitle.frame.size.width - (xPosition + CGFloat(caption.margin?.left ?? 0.0))
                trailingSpace = trailingSpace - width
                
                let rotation = CGFloat(caption.rotation ?? 90.0)
                let angle = ((rotation * -1.0) * CGFloat.pi/180.0)
                containerView.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
                
               // containerView.transform = CGAffineTransform(rotationAngle: .pi/2*3)
                containerView.constrain(to: viewSubTitle).trailing(constant:(trailingSpace))
                containerView.layoutIfNeeded()
                containerView.constrain(to: viewSubTitle).leading( multiplier: 0.5, priority: .defaultLow, activate: false)
            }
        }
    }

    func getLabelsInView(view: UIView) -> [UILabel] {
        var results = [UILabel]()
        for subview in view.subviews as [UIView] {
            if let labelView = subview as? UILabel {
                results += [labelView]
            } else {
                results += getLabelsInView(view: subview)
            }
        }
        return results
    }
    
    
    func adjustFontSizeForiPad()-> Double {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 10
        }
        return 0
    }
    
}

