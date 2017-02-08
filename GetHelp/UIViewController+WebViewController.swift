//
//  UIViewController+WebViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 03/01/2016.
//  Copyright © 2016 BinaryBlitz. All rights reserved.
//

import SafariServices

extension UIViewController {

  func presentWebViewControllerWith(url: NSURL, entersReaderIfAvailable reader: Bool = false) {
    if #available(iOS 9.0, *) {
      let safariController = SFSafariViewController(URL: url, entersReaderIfAvailable: reader)
      self.presentViewController(safariController, animated: true) {
        // disable swipe back action
        for view in safariController.view.subviews {
          if let recognisers = view.gestureRecognizers {
            for gestureRecogniser in recognisers where gestureRecogniser is UIScreenEdgePanGestureRecognizer {
              gestureRecogniser.enabled = false
            }
          }
        }
      }
    } else {
      let webViewController = SVModalWebViewController(URL: url)
      webViewController.navigationBar.barStyle = UIBarStyle.BlackOpaque
      webViewController.navigationBar.tintColor = UIColor.lightGrayColor()
      webViewController.navigationBar.barTintColor = UIColor.lightGrayColor()
      webViewController.barsTintColor = UIColor.whiteColor()
      self.presentViewController(webViewController, animated: true, completion: nil)
    }
  }
}
