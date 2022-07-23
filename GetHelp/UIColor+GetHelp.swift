//
//  UIColor+GetHelp.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 28/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

extension UIColor {
  convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1) {
    self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
  }

  static func orangeSecondaryColor() -> UIColor {
    return UIColor(r: 243, g: 108, b: 18)
  }

  static func greenAccentColor() -> UIColor {
    return UIColor(r: 146, g: 199, b: 103)
  }

  static func redAccentColor() -> UIColor {
    return UIColor(r: 222, g: 102, b: 91)
  }

  static func yellowAccentColor() -> UIColor {
    return UIColor(r: 250, g: 201, b: 95)
  }

  static func blueAccentColor() -> UIColor {
    return UIColor(r: 95, g: 190, b: 212)
  }

  static func newMessageIndicatorColor() -> UIColor {
    return UIColor(r: 46, g: 170, b: 60)
  }

  class var lightPeach40: UIColor {
    return UIColor(red: 253.0 / 255.0, green: 215.0 / 255.0, blue: 205.0 / 255.0, alpha: 0.4)
  }

  class var perrywinkle: UIColor {
    return UIColor(red: 142.0 / 255.0, green: 142.0 / 255.0, blue: 228.0 / 255.0, alpha: 1.0)
  }

  class var tealishTwo: UIColor {
    return UIColor(red: 47.0 / 255.0, green: 197.0 / 255.0, blue: 194.0 / 255.0, alpha: 1.0)
  }

  func lighter(percentage: CGFloat = 0.1) -> UIColor {
    return self.colorWithBrightness(factor: 1 + abs(percentage))
  }

  func darker(percentage: CGFloat = 0.1) -> UIColor {
    return self.colorWithBrightness(factor: 1 - abs(percentage))
  }

  func colorWithBrightness(factor: CGFloat) -> UIColor {
    var hue: CGFloat = 0
    var saturation: CGFloat = 0
    var brightness: CGFloat = 0
    var alpha: CGFloat = 0

    if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
      return UIColor(hue: hue, saturation: saturation, brightness: brightness * factor, alpha: alpha)
    } else {
      return self
    }
  }
}
