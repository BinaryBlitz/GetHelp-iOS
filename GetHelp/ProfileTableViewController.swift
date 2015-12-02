//
//  ProfileTableViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 02/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

  }
  
  //MARK: - IBActions
  
  @IBAction func closeButtonAction(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
