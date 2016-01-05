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

  @IBOutlet weak var chatContentView: UIView!
  @IBOutlet weak var tableView: UITableView?
  @IBOutlet weak var textView: CCGrowingTextView!
  @IBOutlet weak var sendButton: UIButton!
  @IBOutlet weak var attachButton: UIButton!
  @IBOutlet weak var textViewContainerBottomConstraint: NSLayoutConstraint!
  
  var helpRequest: HelpRequest!

  var refreshControl: UIRefreshControl?
  var selectedAssets: [DKAsset]?
  
  var messages: Results<Message>?
  var images: [String]? {
    return messages?.flatMap { (message) -> String? in
      return message.imageURLString
    }
  }
  
  var timer: NSTimer?

  private var imagePickerController: DKImagePickerController?

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    refresh(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let realm = try! Realm()
    let orderId = helpRequest.id
    messages = realm.objects(Message).filter("orderId == \(orderId)").sorted("dateCreated", ascending: false)

    setUpTableView()
    setUpButtons()
    setUpKeyboard()
    setUpTextView()
    setUpRefreshControl()
    
    self.timer = NSTimer.scheduledTimerWithTimeInterval(
      10,
      target: self,
      selector: "refresh:",
      userInfo: nil,
      repeats: true
    )
  }
  
  deinit {
    timer?.invalidate()
  }
  
  //MARK: - Set up methods
  
  func setUpTableView() {
    let tableView = UITableView(frame: chatContentView.frame, style: .Plain)
    self.tableView = tableView
    
    tableView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
    tableView.dataSource = self
    tableView.delegate = self
    UIView.addContent(tableView, toView: chatContentView)
    tableView.tableFooterView = UIView()
    tableView.separatorStyle = .None
    let userCellNib = UINib(nibName: "UserMessageTableViewCell", bundle: nil)
    let userImageCellNib = UINib(nibName: "UserImageMessageTableViewCell", bundle: nil)
    let operatorCellNib = UINib(nibName: "OperatorMessageTableViewCell", bundle: nil)
    let operatorImageCellNib = UINib(nibName: "OperatorImageMessageTableViewCell", bundle: nil)
    tableView.registerNib(userCellNib, forCellReuseIdentifier: "userMessageCell")
    tableView.registerNib(userImageCellNib, forCellReuseIdentifier: "userImageMessageCell")
    tableView.registerNib(operatorCellNib, forCellReuseIdentifier: "operatorMessageCell")
    tableView.registerNib(operatorImageCellNib, forCellReuseIdentifier: "operatorImageMessageCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 100
    scrollToBottom()
  }
  
  func setUpRefreshControl() {
    refreshControl = UIRefreshControl()
    if let refreshControl = refreshControl,
           tableView = tableView {
            
      refreshControl.triggerVerticalOffset = 15
      refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
      tableView.addSubview(refreshControl)
      tableView.sendSubviewToBack(refreshControl)
    }
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
  }
  
  func setUpButtons() {
    sendButton.tintColor = UIColor.orangeSecondaryColor()
    let attachIcon = UIImage(named: "Camera")?.imageWithRenderingMode(.AlwaysTemplate)
    attachButton.setBackgroundImage(attachIcon, forState: .Normal)
    attachButton.tintColor = UIColor.orangeSecondaryColor()
  }
  
  func scrollToBottom() {
    tableView?.setContentOffset(CGPointZero, animated: true)
  }
  
  //MARK: - Refresh
  
  func refresh(sender: AnyObject) {
    beginRefreshWithComplition { () -> Void in
      self.refreshControl?.endRefreshing()
      self.tableView?.reloadData()
    }
  }
  
  func beginRefreshWithComplition(complition: () -> Void) {
    ServerManager.sharedInstance.fetchAllMessagesForOrder(helpRequest) { success, error in
      if let error = error {
        //TODO: Create alert for error
        print("Error: \(error)")
      }
      complition()
    }
  }

  //MARK: - IBActions

  @IBAction func sendButtonAction(sender: AnyObject) {
    guard let textMessage = textView.text where textMessage != "" else {
      return
    }

    ServerManager.sharedInstance.sendMessageWithText(textMessage, toOrder: helpRequest) { success, error in
      if success {
        print("Success!")
        self.tableView!.reloadData()
      }
      
      if let error = error {
        print("Error: \(error)")
      }
    }
    
    textView.text = ""
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
        assets.forEach { (asset) -> () in
          asset.fetchOriginalImageWithCompleteBlock { (image) -> Void in
            guard let image = image else {
              print("fail!")
              return
            }
            ServerManager.sharedInstance.sendMessageWithImage(image, toOrder: self.helpRequest, complition: { (success, error) -> Void in
              if success {
                print("Success!")
                self.tableView?.reloadData()
                self.scrollToBottom()
              }
              
              if let error = error {
                print("Error: \(error)")
              }
            })
          }
        }
      }
      imagePickerController?.maxSelectableCount = 5
      presentViewController(imagePickerController!, animated: true, completion: nil)
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
    guard let message = messages?[indexPath.row] else {
      return UITableViewCell()
    }
    
    let cellIdentifier: String
    
    switch message.sender {
    case .Operator:
      if message.imageURLString != nil {
        cellIdentifier = "operatorImageMessageCell"
      } else {
        cellIdentifier = "operatorMessageCell"
      }
    case .User:
      if message.imageURLString != nil {
        cellIdentifier = "userImageMessageCell"
      } else {
        cellIdentifier = "userMessageCell"
      }
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

//MARK: - UITableViewDelegate 

extension ConversationViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let message = messages?[indexPath.row],
        imageURLString = message.imageURLString,
        images = self.images,
        indexOfSelectedImage = images.indexOf(imageURLString)
    else {
      dismissKeyboard(self)
      return
    }
    
    let browser = MWPhotoBrowser(delegate: self)
    browser.setCurrentPhotoIndex(UInt(indexOfSelectedImage))
    navigationController?.pushViewController(browser, animated: true)
  }
}

extension ConversationViewController: MWPhotoBrowserDelegate {
  
  func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
    return UInt(images?.count ?? 0)
  }
  
  func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
    let imagePath = images?[Int(index)] ?? ""
    let fullURLString = ServerManager.sharedInstance.baseURL + imagePath
    
    guard let url = NSURL(string: fullURLString) else {
      return nil
    }
    
    return MWPhoto(URL: url)
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
