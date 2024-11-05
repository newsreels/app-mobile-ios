//
//  CardTabBar.swift
//  PTR
//
//  Created by Hussein AlRyalat on 8/30/19.
//  Copyright © 2019 SketchMe. All rights reserved.
//

import UIKit

protocol CardTabBarDelegate: class {
    func cardTabBar(_ sender: PTCardTabBar, didSelectItemAt index: Int)
}

open class PTCardTabBar: UIView {
    
    weak var delegate: CardTabBarDelegate?
    
    var items: [UITabBarItem] = [] {
        didSet {
            reloadViews()
        }
    }
    
    override open func tintColorDidChange() {
        super.tintColorDidChange()
        reloadApperance()
    }
    
    func reloadApperance(){
        
        buttons().forEach { button in
            button.selectedColor = tintColor
        }
    }
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
//        stackView.alignment = .center
        stackView.alignment = .fill
        stackView.spacing = 5
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        stackView.arrangedSubviews.forEach {
            if let button = $0 as? UIControl {
                button.removeTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
            }
        }
    }
    
    private func setup(){
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        //self.theme_backgroundColor = GlobalPicker.customTabbarBGColor
//        self.backgroundColor = .black
        self.backgroundColor = .white

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 6, height: 6)
        self.layer.shadowRadius = 6
        self.layer.shadowOpacity = 0.15
                
        tintColorDidChange()
    }
    
    func add(item: UITabBarItem, index: Int) {
        self.items.append(item)
        self.addButton(with: item.image!, index: index)
    }
    
    func remove(item: UITabBarItem) {
        if let index = self.items.firstIndex(of: item) {
            self.items.remove(at: index)
            let view = self.stackView.arrangedSubviews[index]
            self.stackView.removeArrangedSubview(view)
        }
    }
    
    private func addButton(with image: UIImage, index: Int){
        let button = PTBarButton(image: image, index: index)
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.selectedColor = tintColor
        
        button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
//        button.backgroundColor = self.anotherGetRandomColor()
        self.stackView.addArrangedSubview(button)
    }
    
    func select(at index: Int, notifyDelegate: Bool = true){
        for (bIndex, view) in stackView.arrangedSubviews.enumerated() {
            if let button = view as? UIButton {
                button.theme_tintColor = bIndex == index ? GlobalPicker.btnSelectedTabbarTintColor : GlobalPicker.btnUnselectedTabbarTintColor
            }
        }
        
        if notifyDelegate {
            self.delegate?.cardTabBar(self, didSelectItemAt: index)
        }
    }
    
    
    func reloadViews(){
        
        for button in (stackView.arrangedSubviews.compactMap { $0 as? PTBarButton }) {
            stackView.removeArrangedSubview(button)
            button.removeFromSuperview()
            button.removeTarget(self, action: nil, for: .touchUpInside)
        }
        
        for (index,item) in items.enumerated() {
            if let image = item.image {
                addButton(with: image, index: index)
            } else {
                addButton(with: UIImage(), index: index)
            }
        }
        
        //select(at: 0)
    }
    
    private func buttons() -> [PTBarButton] {
        return stackView.arrangedSubviews.compactMap { $0 as? PTBarButton }
    }
    
    func select(at index: Int){
        /* move the indicator view */
        SharedManager.shared.buttonTabSelected = index
        
        for (bIndex, button) in buttons().enumerated() {
            button.selectedColor = tintColor
            
            
            button.isSelected = bIndex == index
            
            if bIndex == index {
                
            }
        }
        
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
        
        
        self.delegate?.cardTabBar(self, didSelectItemAt: index)
    }
    
    
    @objc func buttonTapped(sender: PTBarButton){
        if let index = stackView.arrangedSubviews.firstIndex(of: sender){
            select(at: index)
        }
    }
    
//    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let position = touches.first?.location(in: self) else {
//            super.touchesEnded(touches, with: event)
//            return
//        }
//
//        let buttons = self.stackView.arrangedSubviews.compactMap { $0 as? PTBarButton }.filter { !$0.isHidden }
//        let distances = buttons.map { $0.center.distance(to: position) }
//
//        let buttonsDistances = zip(buttons, distances)
//
//        if let closestButton = buttonsDistances.min(by: { $0.1 < $1.1 }) {
//            buttonTapped(sender: closestButton.0)
//        }
//    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        let padding: CGFloat = 20//self.frame.width * 0.85
        stackView.frame = bounds.inset(by: UIEdgeInsets(top: 10, left: padding, bottom: 0, right: padding))
        //layer.cornerRadius = bounds.height / 2
        //roundCorners([.topLeft, .topRight], bounds.height / 2)
    }
}
