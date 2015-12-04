//
//  ConversationViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 04/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController {

  @IBOutlet weak var textView: CCGrowingTextView!
  @IBOutlet weak var sendButton: UIButton!
  @IBOutlet weak var attachButton: UIButton!
  @IBOutlet weak var textViewContainerBottomConstraint: NSLayoutConstraint!
  var badgeView: JSBadgeView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUpButtons()
    setUpKeyboard()
    setUpTextView()
  }
  
  func setUpTextView() {
    textView.layer.cornerRadius = 7
    textView.maxNumberOfLine = 5
    textView.placeholder = "Введите сообщение"
  }
  
  func setUpKeyboard() {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.addObserver(self, selector: "keyboardWillShow:",
      name: UIKeyboardWillShowNotification, object: nil)
    notificationCenter.addObserver(self, selector: "keyboardWillHide:",
      name: UIKeyboardWillHideNotification, object: nil)
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
  }
  
  func setUpButtons() {
    sendButton.tintColor = UIColor.orangeSecondaryColor()
    let attachIcon = UIImage(named: "Camera")?.imageWithRenderingMode(.AlwaysTemplate)
    attachButton.setBackgroundImage(attachIcon, forState: .Normal)
    attachButton.tintColor = UIColor.orangeSecondaryColor()
    badgeView = JSBadgeView(parentView: attachButton, alignment: .TopRight)
    badgeView?.badgeTextColor = UIColor.whiteColor()
    badgeView?.badgeBackgroundColor = UIColor.greenAccentColor()
  }
  
  func scrollToBottom() {
//    let numberOfRows = tableView.numberOfRowsInSection(1)
//    let indexPath = NSIndexPath(forRow: numberOfRows - 1, inSection: 1)
//    tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
  }
  
  //MARK: - IBActions

  @IBAction func sendButtonAction(sender: AnyObject) {
  }
  
  @IBAction func attachButtonAction(sender: AnyObject) {
    if badgeView?.badgeText == "2" {
      badgeView?.badgeText = nil
    } else {
      badgeView?.badgeText = "2"
    }
  }
}

//MARK: - Keyboard events

extension ConversationViewController {
  
  func keyboardWillShow(notification: NSNotification) {
    guard let userInfo = notification.userInfo else {
      return
    }
    
    let endFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
    let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue ?? 0
    let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey]
    let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
    let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
    textViewContainerBottomConstraint.constant = endFrame?.size.height ?? 0
    UIView.animateWithDuration(duration, delay: 0,
      options: animationCurve,
      animations: {
        self.view.layoutIfNeeded()
      },
      completion: { (_) -> Void in
        self.scrollToBottom()
    })
  }
  
  func keyboardWillHide(notification: NSNotification) {
    guard let userInfo = notification.userInfo else {
      return
    }
    
    let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue ?? 0
    let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey]
    let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
    let animationCurve = UIViewAnimationOptions(rawValue: animationCurveRaw)
    textViewContainerBottomConstraint.constant = 0
    UIView.animateWithDuration(duration, delay: 0, options: animationCurve,
      animations: {
        self.view.layoutIfNeeded()
      },
      completion: nil
    )
  }
  
  func dismissKeyboard(sender: AnyObject) {
    view.endEditing(true)
  }
}
