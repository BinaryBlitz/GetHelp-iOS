//
//  UIViewController+WebViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 03/01/2016.
//  Copyright © 2016 BinaryBlitz. All rights reserved.
//

import SafariServices

extension UIViewController {

  func presentWebViewControllerWith(_ url: URL, entersReaderIfAvailable reader: Bool = false) {
    if #available(iOS 9.0, *) {
      let safariController = SFSafariViewController(url: url, entersReaderIfAvailable: reader)
      self.present(safariController, animated: true) {
        // disable swipe back action
        for view in safariController.view.subviews {
          if let recognisers = view.gestureRecognizers {
            for gestureRecogniser in recognisers where gestureRecogniser is UIScreenEdgePanGestureRecognizer {
              gestureRecogniser.isEnabled = false
            }
          }
        }
      }
    } else {
      let webViewController = SVModalWebViewController(url: url)
      webViewController?.navigationBar.barStyle = UIBarStyle.blackOpaque
      webViewController?.navigationBar.tintColor = UIColor.lightGray
      webViewController?.navigationBar.barTintColor = UIColor.lightGray
      webViewController?.barsTintColor = UIColor.white
      self.present(webViewController!, animated: true, completion: nil)
    }
  }
}
