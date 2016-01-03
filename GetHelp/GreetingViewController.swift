//
//  GreetingViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 13/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class GreetingViewController: UIViewController {

  @IBOutlet weak var signUpButton: UIButton!
  @IBOutlet weak var userAgreement: TTTAttributedLabel!
  
  var delegate: LoginNavigationDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    signUpButton.backgroundColor = UIColor.orangeSecondaryColor()
    signUpButton.tintColor = UIColor.whiteColor()
    signUpButton.layer.cornerRadius = 4
    
    userAgreement.enabledTextCheckingTypes = NSTextCheckingAllTypes
    userAgreement.delegate = self
    let linkRange = (userAgreement.text! as NSString).rangeOfString("пользовательское соглашение")
    userAgreement.addLinkToURL(NSURL(string: "http://google.com/"), withRange: linkRange)
  }
  
  @IBAction func signUpButtonAction(sender: AnyObject) {
    delegate?.moveForward(nil)
  }
}

extension GreetingViewController: TTTAttributedLabelDelegate {
  func attributedLabel(label: TTTAttributedLabel, didSelectLinkWithURL url: NSURL) {
    self.presentWebViewControllerWithURL(url)
  }
}

extension GreetingViewController: ContainerPresentable {
  var viewController: UIViewController {
    return self
  }
  
  func updateNavigationDelegate(delegate: LoginNavigationDelegate) {
    self.delegate = delegate
  }
  
  func setData(data: AnyObject?) {
    // stuff
  }
}