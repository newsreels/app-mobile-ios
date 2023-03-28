//
//  PanGesture.swift
//  Bullet
//
//  Created by Mahesh on 31/01/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

enum PanVerticalDirection {
    case either
    case up
    case down
}

enum PanHorizontalDirection {
    case either
    case left
    case right
}

enum PanDirection {
    case vertical(PanVerticalDirection)
    case horizontal(PanHorizontalDirection)
}

class PanDirectionGestureRecognizer: UIPanGestureRecognizer {

    let direction: PanDirection

    init(direction: PanDirection, target: AnyObject, action: Selector) {
        self.direction = direction
        super.init(target: target, action: action)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        if state == .began {
            let vel = velocity(in: view)
            switch direction {

            // expecting horizontal but moving vertical, cancel
            case .horizontal(_) where abs(vel.y) > abs(vel.x):
                state = .cancelled

            // expecting vertical but moving horizontal, cancel
            case .vertical(_) where abs(vel.x) > abs(vel.y):
                state = .cancelled

            // expecting horizontal and moving horizontal
            case .horizontal(let hDirection):
                switch hDirection {

                    // expecting left but moving right, cancel
                    case .left where vel.x > 0: state = .cancelled

                    // expecting right but moving left, cancel
                    case .right where vel.x < 0: state = .cancelled
                    default: break
                }

            // expecting vertical and moving vertical
            case .vertical(let vDirection):
                switch vDirection {
                    // expecting up but moving down, cancel
                    case .up where vel.y > 0: state = .cancelled

                    // expecting down but moving up, cancel
                    case .down where vel.y < 0: state = .cancelled
                    default: break
                }
            }
        }
    }
}
