//
//  UIImage+Extensions.swift
//  SimplePhotoTemplate
//
//  Created by Shawn Wu on 1/19/20.
//  Copyright © 2020 Shawn Wu. All rights reserved.
//

import UIKit

extension UIImage {
    var squared: UIImage {
        let x: CGFloat
        let y: CGFloat
        if size.height >= size.width {
            x = 0
            y = abs(size.height - size.width) / 2
        } else {
            x = abs(size.width - size.height) / 2
            y = 0
            
        }
        let cropRect = CGRect(x: x,
                              y: y,
                              width: min(size.width, size.height),
                              height: min(size.width, size.height))
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = self.cgImage?.cropping(to:cropRect) else { return self }
        
        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef, scale: 1.0, orientation: imageOrientation)
        return croppedImage
    }
    
    func downsample(maxWidthOrHeight: CGFloat) -> UIImage {
        let newWidth: CGFloat
        let newHeight: CGFloat
        if size.width >= size.height {
            newWidth = maxWidthOrHeight
            newHeight = (size.height * newWidth) / size.width
        } else {
            newHeight = maxWidthOrHeight
            newWidth = (size.width * newHeight) / size.height
        }
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: newWidth, height: newHeight))
        return renderer.image { context in
            self.draw(in: context.format.bounds)
        }
    }
}
