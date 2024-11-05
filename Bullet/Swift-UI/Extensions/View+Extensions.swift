//
//  View+Extensions.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 8/4/22.
//


import SwiftUI
extension View {
    func navigationBar(title: String) -> some View {
        modifier(NavigationBarModifier(title: title))
    }
    
    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }
    
    func onNotification(_ notificationName: Notification.Name, perform action: @escaping (NotificationCenter.Publisher.Output) -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: notificationName)) { output in
            action(output)
        }
    }
    
}

fileprivate struct ViewDidLoadModifier: ViewModifier {
    @State private var didLoad = false
    private let action: (() -> Void)?

    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action?()
            }
        }
    }
}


fileprivate struct NavigationBarModifier: ViewModifier {
    
    var title: String
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            CustomNavigationView(title: title)
            content.navigationBarHidden(true)
        }
    }

}
