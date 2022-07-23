//
//  GreetingViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 13/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class GreetingViewController: UIViewController, LightContentViewController {

  @IBOutlet weak var signUpButton: UIButton!
  @IBOutlet weak var userAgreement: TTTAttributedLabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    userAgreement.attributedText = NSAttributedString(string: "Нажимая кнопку «Начать», вы принимаете\nпользовательское соглашение", attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.7)])
    userAgreement.enabledTextCheckingTypes = NSTextCheckingAllTypes
    userAgreement.delegate = self
    let linkRange = (userAgreement.text! as NSString).range(of: "пользовательское соглашение")
    let urlString = "http://getthelp.ru/docs/Пользовательское соглашение.docx"
    if let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: encodedURLString) {

      var linkAttributes: [AnyHashable: Any] = [:]
      linkAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue
      linkAttributes[NSForegroundColorAttributeName] = UIColor.white
      linkAttributes[NSBackgroundColorAttributeName] = UIColor.clear
      self.userAgreement.linkAttributes = linkAttributes
      
      userAgreement.addLink(to: url, with: linkRange)
      self.setNeedsStatusBarAppearanceUpdate()
    }
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}

extension GreetingViewController: TTTAttributedLabelDelegate {
  func attributedLabel(_ label: TTTAttributedLabel, didSelectLinkWith url: URL) {
    self.presentWebViewControllerWith(url)
  }
}
