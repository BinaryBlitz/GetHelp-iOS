//
//  ConversationViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 04/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import RealmSwift
import DKImagePickerController

class ConversationViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var textView: CCGrowingTextView!
  @IBOutlet weak var sendButton: UIButton!
  @IBOutlet weak var attachButton: UIButton!
  @IBOutlet weak var textViewContainerBottomConstraint: NSLayoutConstraint!
  var badgeView: JSBadgeView?
  
  var helpRequest: HelpRequest!

  var refreshControl: UIRefreshControl?
  var selectedAssets: [DKAsset]?

  private var imagePickerController: DKImagePickerController?

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    scrollToBottom()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    if helpRequest.messages.count == 0 {
      appendTestMessages()
    }
    setUpButtons()
    setUpKeyboard()
    setUpTextView()
    setUpTableView()
    setUpRefreshControl()
  }

  func appendTestMessages() {
    let message1 = Message()
    message1.content = "Ваша заявка принята. Оплатите её пожалуйста в личном кабинете"
    message1.sender = .Operator

    let message2 = Message()
    message2.content = "Оплатил. Скоро скину фото заданий."
    message2.sender = .User

    let message3 = Message()
    message3.content = "Вот задание. 3 задачу вообще невозможно решить."
    message3.sender = .User
    message3.images.append(Image())
    message3.images.append(Image())
    
    let message4 = Message()
    message4.content = "Получили, решаем"
    message4.sender = .Operator

    let realm = try! Realm()
    try! realm.write() {
      self.helpRequest.messages.append(message1)
      self.helpRequest.messages.append(message2)
      self.helpRequest.messages.append(message3)
      self.helpRequest.messages.append(message4)
    }
  }
  
  func setUpTableView() {
    tableView.tableFooterView = UIView()
    let userCellNib = UINib(nibName: "UserMessageTableViewCell", bundle: nil)
    let operatorCellNib = UINib(nibName: "OperatorMessageTableViewCell", bundle: nil)
    tableView.registerNib(userCellNib, forCellReuseIdentifier: "userMessageCell")
    tableView.registerNib(operatorCellNib, forCellReuseIdentifier: "operatorMessageCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 100
    scrollToBottom()
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
    if numberOfRows == 0 {
      return
    }

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
    guard textView.text != "" else {
      return
    }
    
    let message = Message()
    message.content = textView.text
    message.dateCreated = NSDate()
    message.sender = .User


    let realm = try! Realm()
    try! realm.write {
      self.helpRequest.messages.append(message)
      self.selectedAssets?.forEach { asset in
        let image = Image()
        message.images.append(image)
        realm.add(image)
      }
      realm.add(message)
    }

    selectedAssets = nil
    imagePickerController = nil
    
    textView.text = ""
    badgeView?.badgeText = nil
    tableView.reloadData()
    scrollToBottom()
  }
  
  @IBAction func attachButtonAction(sender: AnyObject) {
    presentImagePickerController()
  }

  func presentImagePickerController() {
    if let imagePicker = imagePickerController {
      presentViewController(imagePicker, animated: true, completion: nil)
    } else {
      imagePickerController = DKImagePickerController()
      imagePickerController?.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
        self.badgeView?.badgeText = assets.count != 0 ? "\(assets.count)" : nil
        self.selectedAssets = assets
      }
      imagePickerController?.maxSelectableCount = 5
      presentViewController(imagePickerController!, animated: true, completion: nil)
    }
  }
}

//MARK: UITableViewDataSource

extension ConversationViewController: UITableViewDataSource {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let messages = helpRequest.messages
    
    tableView.hidden = messages.count == 0

    return messages.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let messages = helpRequest.messages
    let message = messages[indexPath.row]

    let cellIdentifier: String
    
    switch message.sender {
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
