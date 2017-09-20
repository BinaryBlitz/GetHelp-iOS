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
import PKHUD
import Alamofire
import MWPhotoBrowser

class ConversationViewController: UIViewController {

  @IBOutlet weak var chatContentView: UIView!
  @IBOutlet weak var tableView: UITableView?
  @IBOutlet weak var textView: CCGrowingTextView!
  @IBOutlet weak var sendButton: UIButton!
  @IBOutlet weak var attachButton: UIButton!
  @IBOutlet weak var textViewContainerBottomConstraint: NSLayoutConstraint!
  var hudTapGesture: UITapGestureRecognizer!

  var helpRequest: HelpRequest!

  var refreshControl: UIRefreshControl?
  var selectedAssets: [DKAsset]?

  var messages: Results<Message>?
  var images: [String]? {
    return messages?.flatMap { (message) -> String? in
      return message.imageURLString
    }
  }

  var timer: Timer?

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    PKHUD.sharedHUD.contentView.addGestureRecognizer(hudTapGesture)
    timer?.fire()
    refresh(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let realm = try! Realm()
    let orderId = helpRequest.id
    messages = realm.objects(Message.self).filter("orderId == \(orderId)").sorted(byKeyPath: "dateCreated", ascending: false)

    if messages?.count == 0 {
      let id = UserDefaultsHelper.loadObjectForKey(.FirstOperatorMessageId) as? Int
      let message = Message()
      message.id = (id ?? -1) - 1
      message.sender = .Operator
      message.orderId = orderId
      message.content = "Ваш заказ рассматривается. Оператор ответит вам в ближайшее время. Пишите, если у вас есть какие-то вопросы."
      message.dateCreated = helpRequest.createdAt ?? Date()
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
    setUpKeyboard()
    setUpTextView()
    setUpRefreshControl()

    NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)),
            name: NSNotification.Name(rawValue: HelpRequestUpdatedNotification), object: nil)
    hudTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hudTapCancel))

    self.timer = Timer.scheduledTimer(
      timeInterval: 10,
      target: self,
      selector: #selector(refresh(_:)),
      userInfo: nil,
      repeats: true
    )
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    timer?.invalidate()
    PKHUD.sharedHUD.contentView.removeGestureRecognizer(hudTapGesture)
  }

  deinit {
    timer?.invalidate()
  }

  //MARK: - Set up methods

  func setUpTableView() {
    let tableView = UITableView(frame: chatContentView.frame, style: .plain)
    self.tableView = tableView

    tableView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
    tableView.dataSource = self
    tableView.delegate = self
    UIView.addContent(tableView, toView: chatContentView)
    tableView.showsVerticalScrollIndicator = false
    tableView.showsHorizontalScrollIndicator = false
    tableView.tableFooterView = UIView()
    tableView.separatorStyle = .none
    let userCellNib = UINib(nibName: "UserMessageTableViewCell", bundle: nil)
    let userImageCellNib = UINib(nibName: "UserImageMessageTableViewCell", bundle: nil)
    let operatorCellNib = UINib(nibName: "OperatorMessageTableViewCell", bundle: nil)
    let operatorImageCellNib = UINib(nibName: "OperatorImageMessageTableViewCell", bundle: nil)
    tableView.register(userCellNib, forCellReuseIdentifier: "userMessageCell")
    tableView.register(userImageCellNib, forCellReuseIdentifier: "userImageMessageCell")
    tableView.register(operatorCellNib, forCellReuseIdentifier: "operatorMessageCell")
    tableView.register(operatorImageCellNib, forCellReuseIdentifier: "operatorImageMessageCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 100
    scrollToBottom()
  }

  func setUpRefreshControl() {
    refreshControl = UIRefreshControl()
    if let refreshControl = refreshControl,
           let tableView = tableView {

      refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
      tableView.addSubview(refreshControl)
      tableView.sendSubview(toBack: refreshControl)
    }
  }

  func setUpTextView() {
    textView.maxNumberOfLine = 5
    textView.text = ""
    textView.placeholder = "Ваше сообщение"
  }

  func setUpKeyboard() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)),
      name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)),
      name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }

  func scrollToBottom() {
    tableView?.setContentOffset(CGPoint.zero, animated: true)
  }

  //MARK: - Refresh

  func refresh(_ sender: AnyObject) {
    beginRefreshWithcompletion { () -> Void in
      self.refreshControl?.endRefreshing()
      self.tableView?.reloadData()
    }
  }

  func beginRefreshWithcompletion(_ completion: @escaping () -> Void) {
    ServerManager.sharedInstance.fetchAllMessagesForOrder(helpRequest) { success, error in
      if let error = error {
        //TODO: Create alert for error
        print("Error: \(error)")
      }
      completion()
    }
  }

  //MARK: - IBActions

  @IBAction func sendButtonAction(_ sender: AnyObject) {
    guard let textMessage = textView.text, textMessage != "" else {
      return
    }

    _ = ServerManager.sharedInstance.sendMessageWithText(textMessage, toOrder: helpRequest) { success, error in
      if success {
        print("Success!")
        self.tableView!.reloadData()
      }

      if let error = error {
        print("Error: \(error)")
        guard let error = error as? URLError else {
          return
        }

        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
          self.presentAlertWithTitle("Ошибка", andMessage: "Нет подключения к интерету")
        case .cancelled:
          return
        default:
          self.presentAlertWithTitle("Ошбика", andMessage: "Не удалось отправить сообщение. Попробуйте позже.")
        }
      }
    }

    textView.text = ""
  }

  @IBAction func attachButtonAction(_ sender: AnyObject) {
    presentImagePickerController()
  }

  func presentImagePickerController() {
    let imagePickerController = DKImagePickerController()
    imagePickerController.navigationBar.barStyle = UIBarStyle.blackTranslucent
    imagePickerController.maxSelectableCount = 3
    imagePickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
      self.sendAssets(assets)
    }

    present(imagePickerController, animated: true, completion: nil)
  }

  //MARK: - Images magic

  fileprivate var numberOfAssets: Int = 0
  fileprivate var finishedRequests: Int = 0
  fileprivate var imageSendRequests = [Request?]()

  func sendAssets(_ assets: [DKAsset]) {
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
        guard let image = image?.withNormalizedOrientation else { return }

        let request = serverManager.sendMessageWithImage(image, toOrder: self.helpRequest) { [unowned self] success, error in
          self.finishedRequests += 1
          if self.numberOfAssets == self.finishedRequests {
            HUD.flash(.success)
          }

          if success {
            print("Success!")
            self.tableView?.reloadData()
            self.scrollToBottom()
          }

          if let error = error {
            print("Error: \(error)")

            if (error as NSError).description.contains(": 413") {
              self.presentAlertWithTitle("Ошибка", andMessage: "Фотография слишком большая!")
              return
            }

            guard let error = error as? URLError else {
              return
            }

            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
              self.presentAlertWithTitle("Ошибка", andMessage: "Нет подключения к интерету")
            case .cancelled:
              return
            default:
              self.presentAlertWithTitle("Ошбика", andMessage: "Не удалось отправить фотографию. Попробуйте позже.")
            }
          }
        }

        self.imageSendRequests.append(request)
      }
    }

    HUD.show(.labeledProgress(title: "Отправка фотографий", subtitle: "Нажмите для отмены"))
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hudTapCancel))
    PKHUD.sharedHUD.contentView.addGestureRecognizer(tapGesture)
  }

  func hudTapCancel() {
    HUD.flash(.labeledError(title: "Отправка фотографий отменена", subtitle: nil))
    self.imageSendRequests.forEach { request in
      request?.cancel()
    }
  }

}

//MARK: UITableViewDataSource

extension ConversationViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let messages = messages else {
      return 0
    }

    tableView.isHidden = messages.count == 0

    return messages.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let message = messages?[indexPath.row] else {
      return UITableViewCell()
    }

    let cellIdentifier: String
    var color: UIColor? = nil

    switch message.sender {
    case .Operator:
      color = helpRequest.type.presenter.color
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

    guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) else {
      return UITableViewCell()
    }

    if let configurableCell = cell as? ConfigurableMessageCell {
      configurableCell.configure(MessagePresenter(message: message, color: color))
    }

    return cell
  }
}

//MARK: - UITableViewDelegate

extension ConversationViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let message = messages?[indexPath.row],
        let imageURLString = message.imageURLString,
        let images = self.images,
        let indexOfSelectedImage = images.index(of: imageURLString)
    else {
      dismissKeyboard(self)
      return
    }

    let browser = MWPhotoBrowser(delegate: self)
    browser?.setCurrentPhotoIndex(UInt(indexOfSelectedImage))
    navigationController?.pushViewController(browser!, animated: true)
  }
}

extension ConversationViewController: MWPhotoBrowserDelegate {

  func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
    return UInt(images?.count ?? 0)
  }

  func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {

    guard let imageURLString = images?[Int(index)], let url = URL(string: imageURLString) else {
      return nil
    }

    return MWPhoto(url: url)
  }
}

//MARK: - Keyboard events

extension ConversationViewController {

  func keyboardWillShow(_ notification: Notification) {
    guard let userInfo = notification.userInfo else { return }

    let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
    let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue ?? 0
    let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey]
    let animationCurveRaw = (animationCurveRawNSN as AnyObject).uintValue ?? UIViewAnimationOptions().rawValue
    let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
    textViewContainerBottomConstraint.constant = endFrame?.size.height ?? 0
    UIView.animate(withDuration: duration, delay: 0,
      options: animationCurve,
      animations: {
        self.view.layoutIfNeeded()
      },
      completion: { (_) -> Void in
        self.scrollToBottom()
    })
  }

  func keyboardWillHide(_ notification: Notification) {
    guard let userInfo = notification.userInfo else { return }

    let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue ?? 0
    let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey]
    let animationCurveRaw = (animationCurveRawNSN as AnyObject).uintValue ?? UIViewAnimationOptions().rawValue
    let animationCurve = UIViewAnimationOptions(rawValue: animationCurveRaw)
    textViewContainerBottomConstraint.constant = 0
    UIView.animate(withDuration: duration, delay: 0, options: animationCurve,
      animations: {
        self.view.layoutIfNeeded()
      },
      completion: nil
    )
  }

  func dismissKeyboard(_ sender: AnyObject) {
    view.endEditing(true)
  }
}
