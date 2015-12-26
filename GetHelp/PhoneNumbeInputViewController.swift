//
//  PhoneNumbeInputViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 13/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class PhoneNumbeInputViewController: UIViewController {
  
  @IBOutlet weak var okButton: UIButton!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var phoneNumberTextField: REFormattedNumberField!
  
  var delegate: LoginNavigationDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setUpButtons()
    view.backgroundColor = UIColor.clearColor()
    phoneNumberTextField.format = "+X (XXX) XXX-XX-XX"
  }
  
  func setUpButtons() {
    okButton.backgroundColor = UIColor.orangeSecondaryColor()
    backButton.backgroundColor = UIColor.orangeSecondaryColor()
    
    okButton.tintColor = UIColor.whiteColor()
    backButton.tintColor = UIColor.whiteColor()
    
    okButton.layer.cornerRadius = 4
    backButton.layer.cornerRadius = 4
  }

  @IBAction func okButtonAction(sender: AnyObject) {
    delegate?.moveForward()
  }
  
  @IBAction func backButtonAction(sender: AnyObject) {
    delegate?.moveBackward()
  }
}

extension PhoneNumbeInputViewController: ContainerPresentable {
  var viewController: UIViewController {
    return self
  }
  
  func updateNavigationDelegate(delegate: LoginNavigationDelegate) {
    self.delegate = delegate
  }
}