//
//  SegmentedProgressBar.swift
//  SegmentedProgressBar
//
//  Created by Dylan Marriott on 04.03.17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//

import Foundation
import UIKit

protocol SegmentedProgressBarDelegate: AnyObject {
    func segmentedProgressBarChangedIndex(index: Int)
    func segmentedProgressBarFinished()
}

class SegmentedProgressBar: UIView {
    
    weak var delegate: SegmentedProgressBarDelegate?
    
//    var topColor = MyThemes.current == .dark ? "#E01335".hexStringToUIColor() : "#FA0815".hexStringToUIColor() {
//           didSet {
//               self.updateColors()
//           }
//       }
//       var bottomColor = MyThemes.current == .dark ? UIColor.white.withAlphaComponent(0.30) : "#E7E7E7".hexStringToUIColor() {
//           didSet {
//               self.updateColors()
//           }
//       }
    var padding: CGFloat = 6.0
    private var verticelSegmentHeight = 32
    private var horizontalSegmentWidth = 42
    private var segmentWidth = 6
    
    
    var isPaused: Bool = false {
        didSet {
            if isPaused {
                for segment in segments {
                    let layer = segment.topSegmentView.layer
                    let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
                    layer.speed = 0.0
                    layer.timeOffset = pausedTime
                }
            } else {
                let segment = segments[currentAnimationIndex]
                let layer = segment.topSegmentView.layer
                let pausedTime = layer.timeOffset
                layer.speed = 1.0
                layer.timeOffset = 0.0
                layer.beginTime = 0.0
                let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
                layer.beginTime = timeSincePause
            }
        }
    }
    
    private var segments = [Segment]()
    var duration: TimeInterval
    var isAudioExist = true
    private var hasDoneLayout = false // hacky way to prevent layouting again
    var currentAnimationIndex = 0
    
    init(numberOfSegments: Int, duration: TimeInterval = 5.0) {
        self.duration = duration
        super.init(frame: CGRect.zero)
        for _ in 0..<numberOfSegments {
            let segment = Segment()
            addSubview(segment.bottomSegmentView)
            addSubview(segment.topSegmentView)
            segments.append(segment)
        }
        self.updateColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if hasDoneLayout {
            return
        }
        
//        if SharedManager.shared.articleSearchModeType == "LIST" {
            
            // let width = (frame.width - (padding * CGFloat(segments.count - 1)) ) / CGFloat(segments.count)
            for (index, segment) in segments.enumerated() {
                
                if currentAnimationIndex == index {
                    
                    let segFrame = CGRect(x: CGFloat(index) * (CGFloat(horizontalSegmentWidth) + padding), y: 0, width: CGFloat(horizontalSegmentWidth), height: frame.height)
                    segment.bottomSegmentView.frame = segFrame
                    segment.topSegmentView.frame = segFrame
                    segment.topSegmentView.frame.size.width = 0
                    
                    let cr = frame.height / 2
                    segment.bottomSegmentView.layer.cornerRadius = cr
                    segment.topSegmentView.layer.cornerRadius = cr
                }
                else {
                    
                    let xAxis = CGFloat(index) * (CGFloat(self.segmentWidth) + padding) + CGFloat(horizontalSegmentWidth - segmentWidth)
                    
                    let segFrame = CGRect(x: xAxis, y: 0, width: CGFloat(self.segmentWidth), height: frame.height)
                    segment.bottomSegmentView.frame = segFrame
                    segment.topSegmentView.frame = segFrame
                    segment.topSegmentView.frame.size.width = 0
                    
                    let cr = frame.height / 2
                    segment.bottomSegmentView.layer.cornerRadius = cr
                    segment.topSegmentView.layer.cornerRadius = cr
                }
            }
//        }
//        else {
//
//            // let width = (frame.width - (padding * CGFloat(segments.count - 1)) ) / CGFloat(segments.count)
//            for (index, segment) in segments.enumerated() {
//
//                if currentAnimationIndex == index {
//
//                    let segFrame = CGRect(x: CGFloat(index) * (CGFloat(horizontalSegmentWidth) + padding), y: 0, width: CGFloat(horizontalSegmentWidth), height: frame.height)
//                    segment.bottomSegmentView.frame = segFrame
//                    segment.topSegmentView.frame = segFrame
//                    segment.topSegmentView.frame.size.width = 0
//
//                    let cr = frame.height / 2
//                    segment.bottomSegmentView.layer.cornerRadius = cr
//                    segment.topSegmentView.layer.cornerRadius = cr
//                }
//                else {
//
//                    let xAxis = CGFloat(index) * (CGFloat(self.segmentWidth) + padding) + CGFloat(horizontalSegmentWidth - segmentWidth)
//
//                    let segFrame = CGRect(x: xAxis, y: 0, width: CGFloat(self.segmentWidth), height: frame.height)
//                    segment.bottomSegmentView.frame = segFrame
//                    segment.topSegmentView.frame = segFrame
//                    segment.topSegmentView.frame.size.width = 0
//
//                    let cr = frame.height / 2
//                    segment.bottomSegmentView.layer.cornerRadius = cr
//                    segment.topSegmentView.layer.cornerRadius = cr
//                }
//            }
//        }
        hasDoneLayout = true
    }
    
    //<--- Background task Restart
    func commonInitNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didBecomeActive() {
        next()
    }
    //--->
    
    func startAnimationList(atIndex: Int) {
        layoutSubviews()
        animateCard(animationIndex: atIndex)
    }
    
    func startAnimationCard(atIndex: Int) {
        
        layoutSubviews()
        animateCard(animationIndex: atIndex)
    }
    
    private func animateCard(animationIndex: Int) {
        
        print("duration....\(animationIndex)", duration)
        
        let nextSegment = segments[animationIndex]
        currentAnimationIndex = animationIndex
        self.isPaused = false // no idea why we have to do this here, but it fixes everything :D
        
        for (index, segment) in self.segments.enumerated() {
            
            if self.currentAnimationIndex == index {
                
                let duration = SharedManager.shared.bulletsAutoPlay == false ? 0 : 0.2
                UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
                    
                    let xAxis = CGFloat(index) * (CGFloat(self.segmentWidth) + self.padding)
                    nextSegment.bottomSegmentView.setX(x: xAxis)
                    nextSegment.topSegmentView.setX(x: xAxis)
                    nextSegment.bottomSegmentView.frame.size.width = CGFloat(self.horizontalSegmentWidth)

                    nextSegment.topSegmentView.layoutIfNeeded()
                    nextSegment.bottomSegmentView.layoutIfNeeded()
                })
                
                //check for Bullet auto play ON/OFF, if its OFF then stop to move next bullet
                if (SharedManager.shared.bulletsAutoPlay == false) {
                    
                    nextSegment.topSegmentView.frame.size.width = CGFloat(self.horizontalSegmentWidth)
                }
                else {
                   
                    UIView.animate(withDuration: self.duration, delay: 0.0, options: .curveLinear, animations: {
                        
                        nextSegment.topSegmentView.frame.size.width = CGFloat(self.horizontalSegmentWidth)
                        
                    }) { (finished) in
                        if !finished {
                            return
                        }
                        
                        if SharedManager.shared.bulletsAutoPlay == false { return }
                        
                        //check for headline only
                        if SharedManager.shared.showHeadingsOnly == "HEADLINES_ONLY" && SharedManager.shared.isUserinteractWithHeadlinesOnly == false {
                            //self.delegate?.segmentedProgressBarFinished()
                            return
                        }
                        self.next()
                    }
                }
            }
            else {
                
                if index == 0 {
                    
                    segment.bottomSegmentView.setX(x: 0)
                    segment.topSegmentView.setX(x: 0)
                }
                else {
                    
                    if index > self.currentAnimationIndex {
                        
                        let xAxis = (CGFloat(index) * (CGFloat(self.segmentWidth) + padding)) + CGFloat(self.horizontalSegmentWidth - self.segmentWidth)
                        segment.bottomSegmentView.setX(x: xAxis)
                        segment.topSegmentView.setX(x: xAxis)
                    }
                    else {
                        
                        let xAxis = (CGFloat(index) * (CGFloat(self.segmentWidth) + padding))
                        segment.bottomSegmentView.setX(x: xAxis)
                        segment.topSegmentView.setX(x: xAxis)
                    }
                }
                
                segment.bottomSegmentView.frame.size.width = CGFloat(self.segmentWidth)
                if currentAnimationIndex > index {
                    
                    segment.topSegmentView.frame.size.width = CGFloat(self.segmentWidth)
                }
                else {
                    
                    segment.topSegmentView.frame.size.width = 0
                }
                
                segment.topSegmentView.layoutIfNeeded()
                segment.bottomSegmentView.layoutIfNeeded()
            }
        }
    }
    
    func updateColors() {
        for segment in segments {
            
//            segment.topSegmentView.backgroundColor = topColor
//            segment.bottomSegmentView.backgroundColor = bottomColor
            segment.topSegmentView.backgroundColor = MyThemes.current == .dark ? "#E01335".hexStringToUIColor() : "#FA0815".hexStringToUIColor()
            segment.bottomSegmentView.backgroundColor = "#C4C8CF".hexStringToUIColor()
            //MyThemes.current == .dark ? UIColor.white.withAlphaComponent(0.30) : "#E7E7E7".hexStringToUIColor()
        }
    }
    
    func clearColors() {
        
        for segment in segments {
            
            segment.topSegmentView.backgroundColor = .clear
            segment.bottomSegmentView.backgroundColor = .clear
        }
    }
    
    private func next() {
        
        let newIndex = self.currentAnimationIndex + 1
        if newIndex < self.segments.count {
            
            self.delegate?.segmentedProgressBarChangedIndex(index: newIndex)
            
//            if SharedManager.shared.articleSearchModeType == "LIST" {
//
//                self.animateList(animationIndex: newIndex)
//            } else {
                self.animateCard(animationIndex: newIndex)
//            }
            
            
        } else {
            //self.delegate?.segmentedProgressBarFinished()
        }
    }
    
    func skip() {
        
        let currentSegment = segments[currentAnimationIndex]
//        if SharedManager.shared.articleSearchModeType == "LIST" {
            currentSegment.topSegmentView.frame.size.width = currentSegment.bottomSegmentView.frame.width
//        }
//        else {
//            currentSegment.topSegmentView.frame.size.width = currentSegment.bottomSegmentView.frame.width
//        }
        currentSegment.topSegmentView.layer.removeAllAnimations()
        self.next()
    }
    
    func rewind() {
        
        let currentSegment = segments[currentAnimationIndex]
        currentSegment.topSegmentView.layer.removeAllAnimations()
//        if SharedManager.shared.articleSearchModeType == "LIST" {
            
            currentSegment.topSegmentView.frame.size.width = 0
//        }
//        else {
//
//            currentSegment.topSegmentView.frame.size.width = 0
//        }
        let newIndex = max(currentAnimationIndex - 1, 0)
        let prevSegment = segments[newIndex]
//        if SharedManager.shared.articleSearchModeType == "LIST" {
            
            prevSegment.topSegmentView.frame.size.width = 0
//        }
//        else {
//
//            prevSegment.topSegmentView.frame.size.width = 0
//        }
        
        self.delegate?.segmentedProgressBarChangedIndex(index: newIndex)
//        if SharedManager.shared.articleSearchModeType == "LIST" {
//
//            self.animateList(animationIndex: newIndex)
//        }
//        else {
            
            self.animateCard(animationIndex: newIndex)
//        }
    }
    
    func resetCurrentIndex() {
        
        let currentSegment = segments[currentAnimationIndex]
        currentSegment.topSegmentView.layer.removeAllAnimations()
        currentSegment.topSegmentView.frame.size.width = 0
        let newIndex = max(currentAnimationIndex, 0)
        let prevSegment = segments[newIndex]
        prevSegment.topSegmentView.frame.size.width = 0
        self.animateCard(animationIndex: newIndex)
    }
    
    func resetListCurrentIndex() {
        
        let currentSegment = segments[currentAnimationIndex]
        currentSegment.topSegmentView.layer.removeAllAnimations()
        currentSegment.topSegmentView.frame.size.width = 0
        let newIndex = max(currentAnimationIndex, 0)
        let prevSegment = segments[newIndex]
        prevSegment.topSegmentView.frame.size.width = 0
        self.animateCard(animationIndex: newIndex)
    }
    
    func cancel() {
        
        currentAnimationIndex = 0
        for segment in segments {
            segment.topSegmentView.layer.removeAllAnimations()
            segment.bottomSegmentView.layer.removeAllAnimations()
        }
    }
}

fileprivate class Segment {
    let bottomSegmentView = UIView()
    let topSegmentView = UIView()
    init() {
    }
}


extension UIView {
    /**
     Set x Position
     
     :param: x CGFloat
     by DaRk-_-D0G
     */
    func setX(x:CGFloat) {
        var frame:CGRect = self.frame
        frame.origin.x = x
        self.frame = frame
    }
    /**
     Set y Position
     
     :param: y CGFloat
     by DaRk-_-D0G
     */
    func setY(y:CGFloat) {
        var frame:CGRect = self.frame
        frame.origin.y = y
        self.frame = frame
    }
    /**
     Set Width
     
     :param: width CGFloat
     by DaRk-_-D0G
     */
    func setWidth(width:CGFloat) {
        var frame:CGRect = self.frame
        frame.size.width = width
        self.frame = frame
    }
    /**
     Set Height
     
     :param: height CGFloat
     by DaRk-_-D0G
     */
    func setHeight(height:CGFloat) {
        var frame:CGRect = self.frame
        frame.size.height = height
        self.frame = frame
    }
}
