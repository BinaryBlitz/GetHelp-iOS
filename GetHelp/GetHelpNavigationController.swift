//
//  GetHelpNavigationController.swift
//  GetHelp
//
//  Created by Алексей on 10.09.17.
//  Copyright © 2017 BinaryBlitz. All rights reserved.
//

import Foundation
import UIKit

protocol DefaultBarStyleViewController { }
protocol TransparentNavigationViewController { }

class GetHelpNavigationController: UINavigationController, UINavigationControllerDelegate {

  let defaultBarTintColor = UIColor.clear

  override func loadView() {
    super.loadView()
    delegate = self
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationBar.shadowImage = UIImage()
    navigationBar.isTranslucent = true
    view.backgroundColor = .clear
    navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationBar.tintColor = UIColor.white
    navigationBar.titleTextAttributes =
      [NSFontAttributeName: UIFont.systemFont(ofSize: 17), NSForegroundColorAttributeName: UIColor.white]
    setNeedsStatusBarAppearanceUpdate()
  }

  func navigationController(_ navigationController: UINavigationController,
                            willShow viewController: UIViewController, animated: Bool) {
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

}
