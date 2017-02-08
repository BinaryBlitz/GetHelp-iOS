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
    let urlString = "http://getthelp.ru/docs/Пользовательское соглашение.docx"
    if let encodedURLString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()),
          url = NSURL(string: encodedURLString) {
      userAgreement.addLinkToURL(url, withRange: linkRange)
    }
  }

  @IBAction func signUpButtonAction(sender: AnyObject) {
    delegate?.moveForward(nil)
  }
}

extension GreetingViewController: TTTAttributedLabelDelegate {
  func attributedLabel(label: TTTAttributedLabel, didSelectLinkWithURL url: NSURL) {
    self.presentWebViewControllerWith(url)
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
