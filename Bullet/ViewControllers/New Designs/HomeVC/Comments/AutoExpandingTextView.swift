//
//  AutoExpandingTextView.swift
//  Bullet
//
//  Created by Faris Muhammed on 07/04/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import Foundation
import UIKit

class AutoExpandingTextView: UITextView {

    private var heightConstr: NSLayoutConstraint!

    var maxHeight: CGFloat = 300 {
        didSet {
            heightConstr?.constant = maxHeight
        }
    }

    private var observer: NSObjectProtocol?

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        heightConstr = heightAnchor.constraint(equalToConstant: maxHeight)

        observer = NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.adjustSize()
        }
    }
    
    
    func adjustSize() {
        self.heightConstr.isActive = self.contentSize.height > self.maxHeight
        self.isScrollEnabled = self.contentSize.height > self.maxHeight
        self.invalidateIntrinsicContentSize()

    }
    
}
