extension UIImage {

  // Rewrite the image using the existing EXIF orientation data
  var withNormalizedOrientation: UIImage {
    if self.imageOrientation == UIImageOrientation.Up { return self }

    UIGraphicsBeginImageContextWithOptions(size, false, scale)

    drawInRect(CGRect(origin: CGPointZero, size: size))
    let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return normalizedImage!
  }

}
