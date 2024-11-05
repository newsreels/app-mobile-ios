//
//  NavigationController.swift
//  PanModal
//
//  Created by Stephen Sowole on 2/26/19.
//  Copyright © 2019 PanModal. All rights reserved.
//

import UIKit
import PanModal

class PanNavigationViewController: AppNavigationController, PanModalPresentable {

    var isShortFormEnabled = true

//    init() {
//        super.init(nibName: nil, bundle: nil)
//        viewControllers = [ViewMoreReelsVC.instantiate(fromAppStoryboard: .Reels)]
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError()
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationBar.isHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

//    override func popViewController(animated: Bool) -> UIViewController? {
//        let vc = super.popViewController(animated: animated)
//        panModalSetNeedsLayoutUpdate()
//        return vc
//    }

//    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
//        super.pushViewController(viewController, animated: animated)
//        panModalSetNeedsLayoutUpdate()
//    }

    // MARK: - Pan Modal Presentable
    var panScrollable: UIScrollView? {
        return (topViewController as? PanModalPresentable)?.panScrollable
    }

//    var longFormHeight: PanModalHeight {
//        return .maxHeight
//    }

//    var shortFormHeight: PanModalHeight {
//        return longFormHeight
//    }
    
    var showDragIndicator: Bool {
        return false
    }

    var shortFormHeight: PanModalHeight {
        return isShortFormEnabled ? .contentHeight(UIScreen.main.bounds.height * 0.7) : longFormHeight
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeight
    }
    
    var topOffset: CGFloat {
        return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 20
    }

    var anchorModalToLongForm: Bool {
        return true
    }

    func willTransition(to state: PanModalPresentationController.PresentationState) {
        guard isShortFormEnabled, case .longForm = state
            else { return }

        isShortFormEnabled = false
        panModalSetNeedsLayoutUpdate()
    }
    
}

//class NavigationController: UINavigationController, PanModalPresentable {
//
//    private let navGroups = NavUserGroups()
//    var isShortFormEnabled = true
//
//    init() {
//        super.init(nibName: nil, bundle: nil)
//        viewControllers = [navGroups]
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError()
//    }
//
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
//
//    override func popViewController(animated: Bool) -> UIViewController? {
//        let vc = super.popViewController(animated: animated)
//        panModalSetNeedsLayoutUpdate()
//        return vc
//    }
//
//    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
//        super.pushViewController(viewController, animated: animated)
//        panModalSetNeedsLayoutUpdate()
//    }
//
//    // MARK: - Pan Modal Presentable
//
//    var panScrollable: UIScrollView? {
//        return (topViewController as? PanModalPresentable)?.panScrollable
//    }
//
////    var longFormHeight: PanModalHeight {
////        return .maxHeight
////    }
//
////    var shortFormHeight: PanModalHeight {
////        return longFormHeight
////    }
//    var shortFormHeight: PanModalHeight {
//        return isShortFormEnabled ? .contentHeight(300.0) : longFormHeight
//    }
//
//    func willTransition(to state: PanModalPresentationController.PresentationState) {
//        guard isShortFormEnabled, case .longForm = state
//            else { return }
//
//        isShortFormEnabled = false
//        panModalSetNeedsLayoutUpdate()
//    }
//
//}

//private class NavUserGroups: UserGroupViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        title = "iOS Engineers"
//
//        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.navigationBar.titleTextAttributes = [
//            .font: UIFont(name: "Lato-Bold", size: 17)!,
//            .foregroundColor: #colorLiteral(red: 0.7019607843, green: 0.7058823529, blue: 0.7137254902, alpha: 1)
//        ]
//        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.7019607843, green: 0.7058823529, blue: 0.7137254902, alpha: 1)
//        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1294117647, green: 0.1411764706, blue: 0.1568627451, alpha: 1)
//
//        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: .plain, target: nil, action: nil)
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        let presentable = members[indexPath.row]
//        let viewController = ProfileViewController(presentable: presentable)
//
//        navigationController?.pushViewController(viewController, animated: true)
//    }
//}

