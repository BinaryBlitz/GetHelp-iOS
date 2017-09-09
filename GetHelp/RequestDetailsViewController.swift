//
//  RequestDetailsViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 04/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class RequestDetailsViewController: UIViewController {

  fileprivate let infoIndex = 0
  fileprivate let conversationIndex = 1

  @IBOutlet weak var requestInfoView: UIView!
  @IBOutlet weak var conversationView: UIView!
  @IBOutlet weak var segmentedControl: UISegmentedControl!

  var helpRequest: HelpRequest!

  override func viewDidLoad() {
    super.viewDidLoad()

    segmentedControl.selectSegmentAt(conversationIndex)
  }

  override func viewWillAppear(_ animated: Bool) {
    self.tabBarController?.tabBar.isHidden = true
  }

  @IBAction func segmentedControlValueChangedAction(_ sender: AnyObject) {
    guard let segmentedControl = sender as? UISegmentedControl else {
      return
    }

    //hide keyboard
    view.endEditing(true)

    switch segmentedControl.selectedSegmentIndex {
    case infoIndex:
      requestInfoView.isHidden = false
      conversationView.isHidden = true
    case conversationIndex:
      requestInfoView.isHidden = true
      conversationView.isHidden = false
    default:
      return
    }
  }

  //MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let infoViewController = segue.destination as? RequestInfoTableViewController {
      infoViewController.helpRequest = helpRequest
    } else if let conversationViewController = segue.destination as? ConversationViewController {
      conversationViewController.helpRequest = helpRequest
    }
  }

}

extension UISegmentedControl {
  func selectSegmentAt(_ index: Int) {
    selectedSegmentIndex = index
    sendActions(for: .valueChanged)
  }
}
