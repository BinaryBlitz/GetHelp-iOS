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

    let message3 = Message()
    message3.content = "Очень длинное сообение, чтобы понять как будет смотреться большой текст в карточке сообщения, а ещё посмотреть как это все вместе вообще будет смотреться. Вот."
    message3.sender = "user"
    
    let message4 = Message()
    message4.content = "Ну даже не знаю. Это смотрится странно, нужно поменять тени и цвет у штуку, где нужно вводить текст."
    message4.sender = "operator"

    messages = List<Message>()
    messages?.append(message1)
    messages?.append(message2)
    messages?.append(message3)
    messages?.append(message4)

    setUpButtons()
    setUpKeyboard()
    setUpTextView()
    setUpTableView()
    setUpRefreshControl()
  }
  
  func setUpTableView() {
    tableView.tableFooterView = UIView()
    let userCellNib = UINib(nibName: "UserMessageTableViewCell", bundle: nil)
    let operatorCellNib = UINib(nibName: "OperatorMessageTableViewCell", bundle: nil)
    tableView.registerNib(userCellNib, forCellReuseIdentifier: "userMessageCell")
    tableView.registerNib(operatorCellNib, forCellReuseIdentifier: "operatorMessageCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 100
  }
  
  func setUpRefreshControl() {
    refreshControl = UIRefreshControl()
//    refreshControl?.triggerVerticalOffset = 100
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
    let numberOfRows = tableView.numberOfRowsInSection(0)
    let indexPath = NSIndexPath(forRow: numberOfRows - 1, inSection: 0)
    tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
  }
  
  //MARK: - Refresh
  
  func refresh(sender: AnyObject) {
    beginRefreshWithComplition { () -> Void in
      self.tableView.reloadData()
      self.refreshControl?.endRefreshing()
      self.scrollToBottom()
    }
  }
  
  func beginRefreshWithComplition(complition: () -> Void) {
    //TODO: Reresh request
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
      complition()
    }
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

    if let configurableCell = cell as? ConfigurableMessageCell {
      configurableCell.configure(MessagePresenter(message: message))
    }

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
