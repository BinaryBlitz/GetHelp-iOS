//
//  GoButton.swift
//  GetHelp
//
//  Created by Алексей on 10.09.17.
//  Copyright © 2017 BinaryBlitz. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class GoButton: UIButton {
  let animationDuration = 0.2

  @IBInspectable var defaultBackgroundColor: UIColor = UIColor.orangeSecondaryColor()

  override var isEnabled: Bool {
    didSet {
      if !isEnabled {
        alpha = 0.6
      } else {
        alpha = 1
      }
    }
  }

  override var isHighlighted: Bool {
    didSet {
      if isHighlighted {
        self.backgroundColor = self.defaultBackgroundColor.darker()
      } else {
        UIView.animate(withDuration: animationDuration, animations: {
          self.backgroundColor = self.defaultBackgroundColor
        })
      }
    }
  }
  
}
