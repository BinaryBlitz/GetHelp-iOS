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
import SwiftSpinner
import Alamofire
import MWPhotoBrowser

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

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    timer?.fire()
    refresh(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let realm = try! Realm()
    let orderId = helpRequest.id
    messages = realm.objects(Message).filter("orderId == \(orderId)").sorted("dateCreated", ascending: false)
    
    if messages?.count == 0 {
      let id = UserDefaultsHelper.loadObjectForKey(.FirstOperatorMessageId) as? Int
      let message = Message()
      message.id = (id ?? -1) - 1
      message.sender = .Operator
      message.orderId = orderId
      message.content = "Ваш заказ рассматривается. Оператор ответит вам в ближайшее время. Пишите, если у вас есть какие-то вопросы."
      message.dateCreated = helpRequest.createdAt ?? NSDate()
      do {
        let realm = try Realm()
        try realm.write {
          realm.add(message)
        }
        
        UserDefaultsHelper.save(message.id, forKey: .FirstOperatorMessageId)
      } catch let error {
          print("Error: \(error)")
      }
    }
    
    setUpTableView()
    setUpButtons()
    setUpKeyboard()
    setUpTextView()
    setUpRefreshControl()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh:",
            name: HelpRequestUpdatedNotification, object: nil)
    
    self.timer = NSTimer.scheduledTimerWithTimeInterval(
      10,
      target: self,
      selector: "refresh:",
      userInfo: nil,
      repeats: true
    )
  }
  
  override func viewDidDisappear(animated: Bool) {
    timer?.invalidate()
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
    tableView.showsVerticalScrollIndicator = false
    tableView.showsHorizontalScrollIndicator = false
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
    beginRefreshWithcompletion { () -> Void in
      self.refreshControl?.endRefreshing()
      self.tableView?.reloadData()
    }
  }
  
  func beginRefreshWithcompletion(completion: () -> Void) {
    ServerManager.sharedInstance.fetchAllMessagesForOrder(helpRequest) { success, error in
      if let error = error {
        //TODO: Create alert for error
        print("Error: \(error)")
      }
      completion()
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
        guard let error = error as? NSURLError else {
          return
        }

        switch error {
        case .NotConnectedToInternet, .NetworkConnectionLost:
          self.presentAlertWithTitle("Ошибка", andMessage: "Нет подключения к интерету")
        case .Cancelled:
          return
        default:
          self.presentAlertWithTitle("Ошбика", andMessage: "Не удалось отправить сообщение. Попробуйте позже.")
        }
      }
    }
    
    textView.text = ""
  }
  
  @IBAction func attachButtonAction(sender: AnyObject) {
    presentImagePickerController()
  }

  func presentImagePickerController() {
    let imagePickerController = DKImagePickerController()
    imagePickerController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
    imagePickerController.maxSelectableCount = 3
    imagePickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
      self.sendAssets(assets)
    }
    
    presentViewController(imagePickerController, animated: true, completion: nil)
  }
  
  //MARK: - Images magic
  
  private var numberOfAssets: Int = 0
  private var finishedRequests: Int = 0
  private var imageSendRequests = [Request?]()
  
  func sendAssets(assets: [DKAsset]) {
    let serverManager = ServerManager.sharedInstance
    numberOfAssets = 0
    finishedRequests = 0
    imageSendRequests = []
    
    if assets.count == 0 {
      return
    }
    
    numberOfAssets = assets.count
    assets.forEach { asset in
      asset.fetchOriginalImageWithCompleteBlock { image, info in
        guard let originalImage = image else {
          return
        }
        
        guard let image = UIImage.resizeImage(originalImage, withScalingFactor: 0.67) else {
          return
        }
        
        let request = serverManager.sendMessageWithImage(image, toOrder: self.helpRequest) { [unowned self] success, error in
          self.finishedRequests += 1
          if self.numberOfAssets == self.finishedRequests {
            SwiftSpinner.hide()
          }
          
          if success {
            print("Success!")
            self.tableView?.reloadData()
            self.scrollToBottom()
          }
          
          if let error = error {
            print("Error: \(error)")
            
            if (error as NSError).description.containsString(": 413") {
              self.presentAlertWithTitle("Ошибка", andMessage: "Фотография слишком большая!")
              return
            }
            
            guard let error = error as? NSURLError else {
              return
            }

            switch error {
            case .NotConnectedToInternet, .NetworkConnectionLost:
              self.presentAlertWithTitle("Ошибка", andMessage: "Нет подключения к интерету")
            case .Cancelled:
              return
            default:
              self.presentAlertWithTitle("Ошбика", andMessage: "Не удалось отправить фотографию. Попробуйте позже.")
            }
          }
        }
        
        self.imageSendRequests.append(request)
      }
    }
    
    SwiftSpinner.show("Отправка фотографий").addTapHandler( {
        SwiftSpinner.hide()
        self.imageSendRequests.forEach { request in
          request?.cancel()
        }
    }, subtitle: "Нажмите для отмены")
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
