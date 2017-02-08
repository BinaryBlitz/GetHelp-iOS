//
//  RequestDetailsViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 04/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class RequestDetailsViewController: UIViewController {

  private let infoIndex = 0
  private let conversationIndex = 1

  @IBOutlet weak var requestInfoView: UIView!
  @IBOutlet weak var conversationView: UIView!
  @IBOutlet weak var segmentedControl: UISegmentedControl!

  var helpRequest: HelpRequest!

  override func viewDidLoad() {
    super.viewDidLoad()

    segmentedControl.selectSegmentAt(conversationIndex)
  }

  override func viewWillAppear(animated: Bool) {
    self.tabBarController?.tabBar.hidden = true
  }

  @IBAction func segmentedControlValueChangedAction(sender: AnyObject) {
    guard let segmentedControl = sender as? UISegmentedControl else {
      return
    }

    //hide keyboard
    view.endEditing(true)

    switch segmentedControl.selectedSegmentIndex {
    case infoIndex:
      requestInfoView.hidden = false
      conversationView.hidden = true
    case conversationIndex:
      requestInfoView.hidden = true
      conversationView.hidden = false
    default:
      return
    }
  }

  //MARK: - Navigation

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let infoViewController = segue.destinationViewController as? RequestInfoTableViewController {
      infoViewController.helpRequest = helpRequest
    } else if let conversationViewController = segue.destinationViewController as? ConversationViewController {
      conversationViewController.helpRequest = helpRequest
    }
  }

}

extension UISegmentedControl {
  func selectSegmentAt(index: Int) {
    selectedSegmentIndex = index
    sendActionsForControlEvents(.ValueChanged)
  }
}
