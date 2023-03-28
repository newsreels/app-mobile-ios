//
//  CardIcon.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/5/22.
//

import SwiftUI
import WebKit

enum CardIconType {
    case local(Image)
    case url(String)
}

struct CardIcon: View {
    let icon: CardIconType
    var backgroundColor: Color = .clear
    var body: some View {
        overlayDisplay()
    }

    @ViewBuilder
    func overlayDisplay() -> some View {
        switch icon {
        case .local(let image):
            Circle()
                .fill(backgroundColor)
                .frame(width: 36, height: 36)
                .overlay(image.foregroundColor(.white).frame(width: 20, height: 20))
        case .url(let url):
            if url.suffix(3) == "svg" {
                if let imageURL = URL(string: url) {
//                    WebView(url: imageURL)
//                        .frame(width: 36, height: 36)
                    Circle()
                        .fill(Color.CardRed)
                        .frame(width: 36, height: 36)
                } else {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 36, height: 36)
                        .cornerRadius(18)
                }
            } else {
                AppURLImage(url)
                    .frame(width: 36, height: 36)
            }
        }
    }
}

struct CardIcon_Previews: PreviewProvider {
    static var previews: some View {
        CardIcon(icon: .local(Image(systemName: "globe.americas.fill")), backgroundColor: .CardRed)
            .previewLayout(.sizeThatFits)
    }
}

struct WebView: UIViewRepresentable {

    var url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()
        return webview
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
