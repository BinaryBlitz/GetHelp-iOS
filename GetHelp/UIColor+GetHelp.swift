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
    return UIColor(r: 250, g: 201, b: 95)
  }
  
  static func redAccentColor() -> UIColor {
    return UIColor(r: 222, g: 102, b: 91)
  }
  
  static func yellowAccentColor() -> UIColor {
    return UIColor(r: 250, g: 201, b: 95)
  }
}
