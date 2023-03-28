//
//  AppButton.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 8/5/22.
//

import Foundation
import SwiftUI

struct AppButton: View {
    
    enum ButtonStylePreset {
        case pinkBG
        case noBGPink
        case black

        fileprivate var config: Configuration {
            switch self {
            case .pinkBG:
                return .init(textColor: .white,
                             fontSize: 16,
                             font: .nunitoBold,
                             bgColor: .AppPinkPrimary,
                             height: 48,
                             hasMaxWidth: true)
            case .noBGPink:
                return .init(textColor: .AppPinkPrimary,
                             fontSize: 16,
                             font: .nunitoBold,
                             bgColor: .clear,
                             height: 48,
                             hasMaxWidth: true)
            case .black:
                return .init(textColor: .black,
                             bgColor: .clear)
                
            }
        }
        fileprivate struct Configuration {
            var title: String?
            var textColor: Color?
            var fontSize: CGFloat?
            var font: AppFonts?
            var bgColor: Color?
            var borderColor: Color?
            var borderThickness: CGFloat?
            var height: CGFloat?
            var shadowRadius: CGFloat?
            var hasMaxWidth: Bool?
            var padding: CGFloat?
            var cornerRadius: CGFloat?
        }

    }

    
    var title: String
    var textColor: Color
    var fontSize: CGFloat
    var lineLimit: Int?
    var font: AppFonts
    var bgColor: Color
    var borderColor: Color?
    var borderThickness: CGFloat?
    var height: CGFloat
    var shadowRadius: CGFloat?
    var hasMaxWidth: Bool
    var padding: CGFloat?
    var cornerRadius: CGFloat

    
    var isLoading: Bool
    
    var action: (()->())
    
    private var border: (color: Color, thickness: CGFloat) {
        if let borderColor = borderColor {
            let thickness = borderThickness ?? 2.0
            return (borderColor, thickness)
        }
        return (Color.clear, 0.0)
    }
    /// - Value priority:
    ///   - value specificed -> preset.configuration -> default values
    init(title: String? = nil,
         preset: ButtonStylePreset? = nil,
         textColor: Color? = nil,
         fontSize: CGFloat? = nil,
         lineLimit: Int? = nil,
         font: AppFonts? = nil,
         bgColor: Color? = nil,
         borderColor: Color? = nil,
         borderThickness: CGFloat? = nil,
         height: CGFloat? = nil,
         shadowRadius: CGFloat? = nil,
         hasMaxWidth: Bool? = nil,
         padding: CGFloat? = nil,
         cornerRadius: CGFloat? = nil,
         isLoading: Bool = false,
         action: @escaping (()->())) {
        
        self.title = title ?? preset?.config.title ?? ""
        self.textColor = textColor ?? preset?.config.textColor ?? .white
        self.fontSize = fontSize ?? preset?.config.fontSize ?? 16.0
        self.lineLimit = lineLimit
        self.font = font ?? preset?.config.font ?? .semiBold
        self.bgColor = bgColor ?? preset?.config.bgColor ?? .clear
        self.borderColor = borderColor ?? preset?.config.borderColor
        self.borderThickness = borderThickness ?? preset?.config.borderThickness
        self.height = height ?? preset?.config.height ?? 40.0
        self.shadowRadius = shadowRadius ?? preset?.config.shadowRadius
        self.hasMaxWidth = hasMaxWidth ?? preset?.config.hasMaxWidth ?? false
        self.isLoading = isLoading
        self.action = action
        self.padding = padding ?? 20
        self.cornerRadius = cornerRadius ?? 8
    }
    
    var body: some View {
        HStack {
            Button(action: {
                if !isLoading {
                    action()
                }
            }, label: {
                HStack {
                    if hasMaxWidth { Spacer() }
                    labelBody // AppText din sana
                    if hasMaxWidth { Spacer() }
                }
                .frame(height: height)
                .padding(.horizontal, padding)
                .background(bgColor)
                .cornerRadius(cornerRadius)
                .foregroundColor(textColor)
                .overlay(RoundedRectangle(cornerRadius: height/2)
                            .stroke(border.color, lineWidth: border.thickness))
            })
        }
        .shadow(color: Color.black.opacity(shadowRadius != nil ? 0.2: 0),
                radius: shadowRadius ?? 0, x: 0, y: 9)
    }
    
    var labelBody: some View {
        ZStack {
            HStack (spacing: title.isEmpty ? 0: nil) {
                Group {
                    Text(title)
                        .font(.app(size: fontSize, weight: font))
                        .foregroundColor(textColor)
                        .lineLimit(lineLimit)
                }.opacity(isLoading ? 0: 1)
            }
            

        }
    }
}
