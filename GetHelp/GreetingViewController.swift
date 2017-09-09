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
    signUpButton.tintColor = UIColor.white
    signUpButton.layer.cornerRadius = 4

    userAgreement.enabledTextCheckingTypes = NSTextCheckingAllTypes
    userAgreement.delegate = self
    let linkRange = (userAgreement.text! as NSString).range(of: "пользовательское соглашение")
    let urlString = "http://getthelp.ru/docs/Пользовательское соглашение.docx"
    if let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: encodedURLString) {
      userAgreement.addLink(to: url, with: linkRange)
    }
  }

  @IBAction func signUpButtonAction(_ sender: AnyObject) {
    delegate?.moveForward(nil)
  }
}

extension GreetingViewController: TTTAttributedLabelDelegate {
  func attributedLabel(_ label: TTTAttributedLabel, didSelectLinkWith url: URL) {
    self.presentWebViewControllerWith(url)
  }
}

extension GreetingViewController: ContainerPresentable {
  var viewController: UIViewController {
    return self
  }

  func updateNavigationDelegate(_ delegate: LoginNavigationDelegate) {
    self.delegate = delegate
  }

  func setData(_ data: AnyObject?) {
    // stuff
  }
}
