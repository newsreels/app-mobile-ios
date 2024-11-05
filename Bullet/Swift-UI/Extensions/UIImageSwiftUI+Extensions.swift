//
//  UIImage+Extensions.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/10/22.
//

import Foundation
import UIKit

extension UIImage {
    
    var jpeg: Data? { jpegData(compressionQuality: 1) }  // QUALITY min = 0 / max = 1
    var png: Data? { pngData() }
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!

        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!

        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)

        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
    func compressToMaximumIfOver1MB() -> Data? {
        if let originalData = jpegData(compressionQuality: 1) {
            let imageData = NSData(data: originalData)
            let imageSizeInKB = Double(imageData.count)/1000
            if imageSizeInKB > 1000 { // If over 1MB compress
                if let scaledDownImageData = jpegData(compressionQuality: 0.1) {
                    return scaledDownImageData
                }
            }
        }
        return nil
    }
}

