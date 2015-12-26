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
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
    phoneNumberTextField.format = "+X (XXX) XXX-XX-XX"
  }
  
  //MARK: - Set up methods
  
  func setUpButtons() {
    okButton.backgroundColor = UIColor.orangeSecondaryColor()
    backButton.backgroundColor = UIColor.orangeSecondaryColor()
    
    okButton.tintColor = UIColor.whiteColor()
    backButton.tintColor = UIColor.whiteColor()
    
    okButton.layer.cornerRadius = 4
    backButton.layer.cornerRadius = 4
  }
  
  //MARK: - IBActions

  @IBAction func okButtonAction(sender: AnyObject) {
    delegate?.moveForward()
  }
  
  @IBAction func backButtonAction(sender: AnyObject) {
    delegate?.moveBackward()
  }
  
  //MARK: - Keyboard stuff
  
  func dismissKeyboard(sender: AnyObject) {
    view.endEditing(true)
  }
}

//MARK: - ContainerPresentable

extension PhoneNumbeInputViewController: ContainerPresentable {
  var viewController: UIViewController {
    return self
  }
  
  func updateNavigationDelegate(delegate: LoginNavigationDelegate) {
    self.delegate = delegate
  }
}
