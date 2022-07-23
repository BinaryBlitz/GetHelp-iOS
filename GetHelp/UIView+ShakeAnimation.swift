//
//  UIView+ShakeAnimation.swift
//  GettHelp-iOS
//
//  Created by Dan Shevlyuk on 26/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//
import UIKit

extension UIView {

  func shake() {
    let shakes = 10
    let direction = 1

    runShakeAnimationWith(shakes, inDirection: direction, withDuraction: 0.05)
  }

  func shakeWithDuration(_ duration: Double) {
    let shakes = 10
    let direction = 1

    runShakeAnimationWith(shakes, inDirection: direction, withDuraction: duration)
  }

  fileprivate func runShakeAnimationWith(_ shakes: Int, inDirection direction: Int, withDuraction duration: Double) {
    UIView.animate(withDuration: duration, animations: { () -> Void in
      self.transform = CGAffineTransform(translationX: CGFloat(5 * direction), y: CGFloat(0))
    }, completion: { (finished) -> Void in
      if shakes == 0 {
        self.transform = CGAffineTransform.identity
        return
      }

      self.runShakeAnimationWith(shakes - 1, inDirection: -direction, withDuraction: duration)
    })
  }
}
