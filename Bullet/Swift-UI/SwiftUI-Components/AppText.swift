//
//  AppText.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/5/22.
//

import SwiftUI

struct AppText: View {
    
    var text: String
    var attributedString : NSAttributedString?
    var weight: AppFonts = .regular
    var size: CGFloat = 16.0
    var color: Color = .black
    var lineSpacing: CGFloat = 6
    var alignment: TextAlignment
    
    private init(text: String, weight: AppFonts, size: CGFloat, color: Color, lineSpacing: CGFloat, alignment: TextAlignment) {
        self.text = text
        self.weight = weight
        self.size = size
        self.color = color
        self.lineSpacing = lineSpacing
        self.alignment = alignment
    }
    
    init(_ text: String, weight: AppFonts = .regular, size: CGFloat = 16.0, color: Color = .black, isLoading: Binding<Bool> = .constant(false), shimmerWidth: CGFloat = 100, lineSpacing: CGFloat = 6, alignment: TextAlignment = .leading) {
        self.init(text: text, weight: weight, size: size, color: color, lineSpacing: lineSpacing, alignment: alignment)
    }
    

    @ViewBuilder
    var body: some View {
        Text(text).font(.app(size: size, weight: weight)).multilineTextAlignment(alignment).foregroundColor(color).lineSpacing(lineSpacing)
    }
}

extension Font {
    public static func app(size: CGFloat, weight: AppFonts = .regular) -> Font {
        return Font.custom(weight.rawValue, size: size)
    }
}

