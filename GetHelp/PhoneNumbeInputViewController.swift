//
//  PhoneNumbeInputViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 13/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class PhoneNumbeInputViewController: UIViewController {

  @IBOutlet weak var phoneNumberTextField: REFormattedNumberField!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    phoneNumberTextField.format = "+X (XXX) XXX-XX-XX"
  }
}
