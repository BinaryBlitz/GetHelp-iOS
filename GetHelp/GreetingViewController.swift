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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    signUpButton.backgroundColor = UIColor.orangeSecondaryColor()
    signUpButton.tintColor = UIColor.whiteColor()
    signUpButton.layer.cornerRadius = 4
  }
}