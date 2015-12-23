//
//  GreetingViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 13/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class GreetingViewController: UIViewController {

  @IBOutlet weak var signUpButton: UIButton!
  @IBOutlet weak var userAgreement: TTTAttributedLabel!
  
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
}

extension GreetingViewController: TTTAttributedLabelDelegate {
  func attributedLabel(label: TTTAttributedLabel, didSelectLinkWithURL url: NSURL) {
    print("yo")
    if #available(iOS 9.0, *) {
      let safariController = SFSafariViewController(URL: url)
      presentViewController(safariController, animated: true, completion: nil)
    } else {
      
    }
  }
}