//
//  ConversationViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 04/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import RealmSwift

class ConversationViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var textView: CCGrowingTextView!
  @IBOutlet weak var sendButton: UIButton!
  @IBOutlet weak var attachButton: UIButton!
  @IBOutlet weak var textViewContainerBottomConstraint: NSLayoutConstraint!
  var badgeView: JSBadgeView?
  
  var helpRequest: HelpRequest!
  var messages: List<Message>?
  
  var refreshControl: UIRefreshControl?
  
  override func viewDidLoad() {
    super.viewDidLoad()

//    messages = helpRequest.messages
    // set up test messages
    let message1 = Message()
    message1.content = "Ping"
    message1.sender = "operator"

    let message2 = Message()
    message2.content = "Pong"
    message2.sender = "user"

    messages = List<Message>()
    messages!.append(message1)
    messages!.append(message2)

    setUpButtons()
    setUpKeyboard()
    setUpTextView()
    setUpTableView()
    setUpRefreshControl()
  }
  
  func setUpTableView() {
    tableView.tableFooterView = UIView()
    tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
  }
  
  func setUpRefreshControl() {
    refreshControl = UIRefreshControl()
    refreshControl?.triggerVerticalOffset = 100
    refreshControl?.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
    tableView.bottomRefreshControl = refreshControl
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
    let numberOfRows = tableView.numberOfRowsInSection(1)
    let indexPath = NSIndexPath(forRow: numberOfRows - 1, inSection: 0)
    tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
  }
  
  //MARK: - Refresh
  
  func refresh(sender: AnyObject) {
    beginRefreshWithComplition { () -> Void in
      self.tableView.reloadData()
      self.refreshControl?.endRefreshing()
    }
  }
  
  func beginRefreshWithComplition(complition: () -> Void) {
    //TODO: Reresh request
    complition()
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

//MARK: UITableViewDataSource

extension ConversationViewController: UITableViewDataSource {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let messages = messages else {
      return 0
    }
    
    tableView.hidden = messages.count == 0

    return messages.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    guard let message = messages?[indexPath.row],
              sender = message.senderEnum
    else {
      return UITableViewCell()
    }

    let cellIdentifier: String
    
    switch sender {
    case .Operator:
      cellIdentifier = "operatorMessageCell"
    case .User:
      cellIdentifier = "userMessageCell"
    }

    guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) else {
      return UITableViewCell()
    }

    cell.textLabel?.text = message.content
    cell.layer.cornerRadius = 10
    
    return cell
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
