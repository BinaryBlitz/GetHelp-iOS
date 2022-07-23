extension UIImage {

  // Rewrite the image using the existing EXIF orientation data
  var withNormalizedOrientation: UIImage {
    if self.imageOrientation == UIImageOrientation.up { return self }

    UIGraphicsBeginImageContextWithOptions(size, false, scale)

    draw(in: CGRect(origin: CGPoint.zero, size: size))
    let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return normalizedImage!
  }

}
