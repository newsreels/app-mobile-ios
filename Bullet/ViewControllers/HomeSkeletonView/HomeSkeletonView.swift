//
//  HomeSkeletonView.swift
//  Bullet
//
//  Created by Faris Muhammed on 22/06/21.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit
import Skeleton

class HomeSkeletonView: UIView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewTopBar: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var view: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func viewFromNib() -> UIView {
        let bundle = Bundle(for: type(of:self))
        let nib = UINib(nibName: "HomeSkeletonView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.backgroundColor = .clear
        return view
    }
    
    func commonInit() {
        
        view = viewFromNib()
        addSubview(view)
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        
        registerCell()
        
        view.backgroundColor = .clear
        
        self.backgroundColor = .clear
        self.view.backgroundColor = .clear
        
        viewTopBar.theme_backgroundColor = GlobalPicker.tabBarTintColor
    }
    
    
    
    func showSkeletonLoader() {
        
        
        DispatchQueue.main.async {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            
            self.tableView.reloadData()
            self.collectionView.reloadData()
//            let animation = GradientDirection.leftRight.slidingAnimation()
    //        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftToRight)
//            self.tableView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient.init(baseColor: MyThemes.current == .light ? GlobalPicker.skeletonColorLightMode : GlobalPicker.skeletonColorDarkMode), animation: animation, transition: .crossDissolve(0.25))
            
            
//            self.collectionView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient.init(baseColor: MyThemes.current == .light ? GlobalPicker.skeletonColorLightMode : GlobalPicker.skeletonColorDarkMode), animation: animation, transition: .crossDissolve(0.25))
            
//            self.tableView.showSkeleton(usingColor: MyThemes.current == .light ? GlobalPicker.skeletonColorLightMode : GlobalPicker.skeletonColorDarkMode)
//            self.collectionView.showSkeleton(usingColor: MyThemes.current == .light ? GlobalPicker.skeletonColorLightMode : GlobalPicker.skeletonColorDarkMode)
        }
        
    }
    
    func hideSkeletonLoader() {
        
        DispatchQueue.main.async {
//            self.tableView.hideSkeleton()
            
//            self.collectionView.hideSkeleton()
            
            self.tableView.delegate = nil
            self.tableView.dataSource = nil
            
            self.collectionView.delegate = nil
            self.collectionView.dataSource = nil
            
            self.tableView.reloadData()
            self.collectionView.reloadData()
        }
        
    }
    
    func registerCell() {
        
        tableView.register(UINib(nibName: "HomeSkeltonCardCell", bundle: nil), forCellReuseIdentifier: "HomeSkeltonCardCell")
        tableView.register(UINib(nibName: "HomeSkeltonListCell", bundle: nil), forCellReuseIdentifier: "HomeSkeltonListCell")
        collectionView.register(UINib(nibName: "HomeSkeltonTabCell", bundle: nil), forCellWithReuseIdentifier: "HomeSkeltonTabCell")
        
        
    }
    
//    override func layoutSubviews() {
//        view.layoutSkeletonIfNeeded()
//    }
    
}


extension HomeSkeletonView: UITableViewDelegate, UITableViewDataSource {
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
//
//    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        return 10
//    }
    
//    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
//
//        if indexPath.row == 0 {
//            return "HomeSkeltonCardCell"
//        }
//        return "HomeSkeltonListCell"
//    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeSkeltonCardCell") as! HomeSkeltonCardCell
            cell.gradientLayers.forEach { gradientLayer in
              let baseColor = cell.viewTitle1.backgroundColor!
              gradientLayer.colors = [baseColor.cgColor,
                                      baseColor.brightened(by: 0.93).cgColor,
                                      baseColor.cgColor]
            }
            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeSkeltonListCell") as! HomeSkeltonListCell
        cell.gradientLayers.forEach { gradientLayer in
          let baseColor = cell.viewTitle1.backgroundColor!
          gradientLayer.colors = [baseColor.cgColor,
                                  baseColor.brightened(by: 0.93).cgColor,
                                  baseColor.cgColor]
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if let skeletonCell = cell as? HomeSkeltonCardCell {
            skeletonCell.slide(to: .right)
        }
        
        if let skeletonCell = cell as? HomeSkeltonListCell {
            skeletonCell.slide(to: .right)
        }
        
        
    }
    
    
}


extension HomeSkeletonView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeSkeltonTabCell", for: indexPath) as! HomeSkeltonTabCell
        
        cell.gradientLayers.forEach { gradientLayer in
          let baseColor = cell.viewTitle.backgroundColor!
          gradientLayer.colors = [baseColor.cgColor,
                                  baseColor.brightened(by: 0.93).cgColor,
                                  baseColor.cgColor]
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let skeletonCell = cell as? HomeSkeltonTabCell {
            skeletonCell.slide(to: .right)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: collectionView.frame.size.width/4, height: collectionView.frame.size.height)
        
        return size
    }
    
}
