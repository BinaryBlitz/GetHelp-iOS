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

  override func viewDidLoad() {
    super.viewDidLoad()
    
//    segmentedControl.selectSegmentAt(conversationIndex)
  }
  
  @IBAction func segmentedControlValueChangedAction(sender: AnyObject) {
    guard let segmentedControl = sender as? UISegmentedControl else {
      return
    }
    
    switch segmentedControl.selectedSegmentIndex {
    case infoIndex:
      requestInfoView.hidden = false
    case conversationIndex:
      requestInfoView.hidden = true
    default:
      return
    }
  }
}

extension UISegmentedControl {
  func selectSegmentAt(index: Int) {
    selectedSegmentIndex = index
    sendActionsForControlEvents(.ValueChanged)
  }
}
