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
    return UIColor(r: 232, g: 77, b: 27)
  }
  
  static func greenAccentColor() -> UIColor {
    return UIColor(r: 228, g: 30, b: 30)
  }
  
  static func redAccentColor() -> UIColor {
    return UIColor(r: 59, g: 155, b: 54)
  }
}
