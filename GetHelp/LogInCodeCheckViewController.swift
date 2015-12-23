//
//  LogInCodeCheckViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 13/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class LogInCodeCheckViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func okButtonAction(sender: AnyObject) {
    let mainStroryboard = UIStoryboard(name: "Main", bundle: nil)
    if let initialController = mainStroryboard.instantiateInitialViewController() {
      UIApplication.sharedApplication().statusBarHidden = false
      presentViewController(initialController, animated: true, completion: nil)
    }
  }
}
