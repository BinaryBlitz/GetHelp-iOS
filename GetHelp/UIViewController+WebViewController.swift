//
//  UIViewController+WebViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 03/01/2016.
//  Copyright © 2016 BinaryBlitz. All rights reserved.
//

import SafariServices

extension UIViewController {
  
  func presentWebViewControllerWithURL(url: NSURL) {
    if #available(iOS 9.0, *) {
      let safariController = SFSafariViewController(URL: url)
      self.presentViewController(safariController, animated: true, completion: nil)
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