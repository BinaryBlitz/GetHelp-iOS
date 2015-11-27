//
//  CreateNewRequestViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 25/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import RealmSwift

class CreateNewRequestViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  //MARK: - IBActions
  
  @IBAction func normalRequestButtonAction(sender: AnyObject) {
    let realm = try! Realm()

    let request = HelpRequest()
    request.subject = "Матан"
    try! realm.write {
      realm.add(request)
    }

    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func expressRequestButtonAction(sender: AnyObject) {
  }
  
  @IBAction func cancelButtonAction(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
