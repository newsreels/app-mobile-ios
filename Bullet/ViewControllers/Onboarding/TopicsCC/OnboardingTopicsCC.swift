//
//  OnboardingTopicsCC.swift
//  Bullet
//
//  Created by Khadim Hussain on 18/08/2021.
//  Copyright © 2021 Ziro Ride LLC. All rights reserved.
//

import UIKit

protocol OnboardingTopicsCCDelegate: AnyObject {
    func didTapAddButton(cell: OnboardingTopicsCC)
}

class OnboardingTopicsCC: UICollectionViewCell {

    @IBOutlet weak var imgTopic: UIImageView!
    @IBOutlet weak var imgFav: UIImageView!
    @IBOutlet weak var lblTopic: UILabel!
    @IBOutlet weak var viewBG: UIView!
    
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    weak var delegate: OnboardingTopicsCCDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        activityLoader.stopAnimating()
        viewBG.layer.cornerRadius = 8
    }

    func setupTopicCell(topic:TopicData, isFavorite: Bool) {

        imgFav.image = isFavorite ? UIImage(named: "tickUnselected") : UIImage(named: "plus")
        if let color = topic.color, !color.isEmpty || color != "" {
            
            viewBG.backgroundColor =  topic.color?.hexStringToUIColor()
        }
        else {
            viewBG.backgroundColor = "#283991".hexStringToUIColor()
        }

        lblTopic.text = topic.name?.capitalized ?? ""
 
        DispatchQueue.global(qos: .background).async {
            print("Run on background thread")
            
            self.imgTopic.sd_setImage(with: URL(string: topic.image ?? ""), placeholderImage: nil, completed: { (image, error, cacheType, imageURL) in
          
                if image != nil {
                    
                    let cropImage = self.cropImage(sourceImage: image!)
                    let imageWithRadius = cropImage.withRoundedCorners(radius:6)
                    let rotatedImage = imageWithRadius?.rotated(by: Measurement(value: 16.0, unit: .degrees))
                    
                    DispatchQueue.main.async {
                        print("We finished that.")
                        // only back on the main thread, may you access UI:
                        self.imgTopic.image = rotatedImage
                        self.imgTopic.clipsToBounds = true
                        self.imgTopic.layer.masksToBounds = true
                    }
                }
            })
        }
    }
    

    func updateFavoriteStatus(isFavorite: Bool) {
        
        if isFavorite {
            
            imgFav.image = UIImage(named: "tickSelected")
            viewBG.backgroundColor = "#429945".hexStringToUIColor()
        }
        else {
        
            imgFav.image = UIImage(named: "plus")
            viewBG.backgroundColor = "#283991".hexStringToUIColor()
        }
    }

    func cropImage(sourceImage:UIImage) -> UIImage {


        // The shortest side
        let sideLength = min(
            sourceImage.size.width,
            sourceImage.size.height
        )

        // Determines the x,y coordinate of a centered
        // sideLength by sideLength square
        let sourceSize = sourceImage.size
        let xOffset = (sourceSize.width - sideLength) / 2.0
        let yOffset = (sourceSize.height - sideLength) / 2.0

        // The cropRect is the rect of the image to keep,
        // in this case centered
        let cropRect = CGRect(
            x: xOffset,
            y: yOffset,
            width: sideLength,
            height: sideLength
        ).integral

        // Center crop the image
        let sourceCGImage = sourceImage.cgImage!
        let croppedCGImage = sourceCGImage.cropping(
            to: cropRect
        )!
        let croppedUIImage:UIImage = UIImage.init(cgImage: croppedCGImage)
        
        return croppedUIImage
    }
    
    
    func setUpReelsTopicsCells(topic: TopicData?) {
        
        lblTopic.text = topic?.name?.uppercased() ?? ""
        lblTopic.addTextSpacing(spacing: 2.2)
        if let color = topic?.color, !color.isEmpty || color != "" {
            
            viewBG.backgroundColor =  topic?.color?.hexStringToUIColor()
        }
        else {
            viewBG.backgroundColor = "#283991".hexStringToUIColor()
        }
        self.imgTopic.image = nil
        
        self.imgTopic.sd_setImage(with: URL(string: topic?.image ?? ""), placeholderImage: nil, completed: { (image, error, cacheType, imageURL) in
      
            if image != nil {
                
                let cropImage = self.cropImage(sourceImage: image!)
                let imageWithRadius = cropImage.withRoundedCorners(radius: 6)
                let rotatedImage = imageWithRadius?.rotated(by: Measurement(value: 16.0, unit: .degrees))
                
                DispatchQueue.main.async {
                    print("We finished that.")
                    // only back on the main thread, may you access UI:
                    self.imgTopic.image = rotatedImage
                    self.imgTopic.clipsToBounds = true
                    self.imgTopic.layer.masksToBounds = true
                }
            }
        })
        
        if (topic?.favorite ?? false) {
            
            imgFav.image = UIImage(named: "tickUnselected")
        }
        else {
            imgFav.image = UIImage(named: "plus")
        }
        
    }
    
    @IBAction func didTapAddButton(_ sender: Any) {
        
        self.delegate?.didTapAddButton(cell: self)
    }
    
    
    
}

extension UIImage {
    struct RotationOptionsImage: OptionSet {
        let rawValue: Int

        static let flipOnVerticalAxis = RotationOptionsImage(rawValue: 1)
        static let flipOnHorizontalAxis = RotationOptionsImage(rawValue: 2)
    }

    func rotated(by rotationAngle: Measurement<UnitAngle>, options: RotationOptionsImage = []) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }

        let rotationInRadians = CGFloat(rotationAngle.converted(to: .radians).value)
        let transform = CGAffineTransform(rotationAngle: rotationInRadians)
        var rect = CGRect(origin: .zero, size: self.size).applying(transform)
        rect.origin = .zero

        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { renderContext in
            renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
            renderContext.cgContext.rotate(by: rotationInRadians)

            let x = options.contains(.flipOnVerticalAxis) ? -1.0 : 1.0
            let y = options.contains(.flipOnHorizontalAxis) ? 1.0 : -1.0
            renderContext.cgContext.scaleBy(x: CGFloat(x), y: CGFloat(y))

            let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
            renderContext.cgContext.draw(cgImage, in: drawRect)
        }
    }
}

extension UIImage {
       // image with rounded corners
       public func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
           let maxRadius = min(size.width, size.height) / 2
           let cornerRadius: CGFloat
           if let radius = radius, radius > 0 && radius <= maxRadius {
               cornerRadius = radius
           } else {
               cornerRadius = radius ?? 6
           }
           UIGraphicsBeginImageContextWithOptions(size, false, scale)
           let rect = CGRect(origin: .zero, size: size)
           UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
           draw(in: rect)
           let image = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()
           return image
       }
   }
