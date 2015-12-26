//
//  LogInCodeCheckViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 13/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class LogInCodeCheckViewController: UIViewController {

  @IBOutlet weak var okButton: UIButton!
  @IBOutlet weak var backButton: UIButton!
  
  var delegate: LoginNavigationDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUpButtons()
  }
  
  func setUpButtons() {
    okButton.backgroundColor = UIColor.orangeSecondaryColor()
    backButton.backgroundColor = UIColor.orangeSecondaryColor()
    
    okButton.tintColor = UIColor.whiteColor()
    backButton.tintColor = UIColor.whiteColor()
    
    okButton.layer.cornerRadius = 4
    backButton.layer.cornerRadius = 4
  }
  
  @IBAction func backButtonAction(sender: AnyObject) {
    delegate?.moveBackward()
  }
  
  @IBAction func okButtonAction(sender: AnyObject) {
//    let mainStroryboard = UIStoryboard(name: "Main", bundle: nil)
//    if let initialController = mainStroryboard.instantiateInitialViewController() {
//      UIApplication.sharedApplication().statusBarHidden = false
//      presentViewController(initialController, animated: true, completion: nil)
//    }
  }
}

extension LogInCodeCheckViewController: ContainerPresentable {
  var viewController: UIViewController {
    return self
  }
  
  func updateNavigationDelegate(delegate: LoginNavigationDelegate) {
    self.delegate = delegate
  }
}
