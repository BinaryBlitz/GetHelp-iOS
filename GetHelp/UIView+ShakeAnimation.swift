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
  
  func shakeWithDuration(duration: Double) {
    let shakes = 10
    let direction = 1
    
    runShakeAnimationWith(shakes, inDirection: direction, withDuraction: duration)
  }
  
  private func runShakeAnimationWith(shakes: Int, inDirection direction: Int, withDuraction duration: Double) {
    UIView.animateWithDuration(duration, animations: { () -> Void in
      self.transform = CGAffineTransformMakeTranslation(CGFloat(5 * direction), CGFloat(0))
    }, completion: { (finished) -> Void in
      if shakes == 0 {
        self.transform = CGAffineTransformIdentity
        return
      }
      
      self.runShakeAnimationWith(shakes - 1, inDirection: -direction, withDuraction: duration)
    })
  }
}