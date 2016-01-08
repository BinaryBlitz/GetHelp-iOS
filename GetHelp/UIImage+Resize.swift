//
//  UIImage+Resize.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 08/01/2016.
//  Copyright © 2016 BinaryBlitz. All rights reserved.
//

extension UIImage {
  
  /// Load and resize an image using `CGContextDrawImage(...)`.
  static func resizeImage(image: UIImage, withScalingFactor scalingFactor: Double) -> UIImage? {
    let cgImage = image.CGImage
    
    let width = Double(CGImageGetWidth(cgImage)) * scalingFactor
    let height = Double(CGImageGetHeight(cgImage)) * scalingFactor
    let bitsPerComponent = CGImageGetBitsPerComponent(cgImage)
    let bytesPerRow = CGImageGetBytesPerRow(cgImage)
    let colorSpace = CGImageGetColorSpace(cgImage)
    let bitmapInfo = CGImageGetBitmapInfo(cgImage)
    
    let context = CGBitmapContextCreate(nil, Int(width), Int(height), bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
    
    CGContextSetInterpolationQuality(context, .High)
    
    CGContextDrawImage(context, CGRect(origin: CGPointZero, size: CGSize(width: CGFloat(width), height: CGFloat(height))), cgImage)
    
    let scaledImage = CGBitmapContextCreateImage(context).flatMap { return UIImage(CGImage: $0) }
    return scaledImage
  }
}
