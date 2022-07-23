//
//  PhoneNumbeInputViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 13/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications

class PhoneTokenPair {
  var phoneNumber: String
  var token: String

  init(phoneNumber: String, token: String) {
    self.phoneNumber = phoneNumber
    self.token = token
  }
}

class PhoneNumbeInputViewController: UIViewController, LightContentViewController {

  @IBOutlet weak var okButton: UIButton!
  @IBOutlet weak var phoneNumberTextField: REFormattedNumberField!
  @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
  
  var loginRequest: Request?

  var observers: [Any] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logoGethelpNavbar1"))
    setUpButtons()
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))
    phoneNumberTextField.format = "+X (XXX) XXX-XX-XX"
    phoneNumberTextField.placeholder = "+7 (123) 456-78-90"
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.observers = bottomLayoutConstraint.addObserversUpdateWithKeyboard(view: view)
    phoneNumberTextField.becomeFirstResponder()
  }


  override func viewWillDisappear(_ animated: Bool) {
    view.endEditing(true)
    self.observers.forEach { NotificationCenter.default.removeObserver($0) }
    self.observers = []
  }

  //MARK: - Set up methods

  func setUpButtons() {

  }

  //MARK: - IBActions

  @IBAction func okButtonAction(_ sender: AnyObject) {

    if let request = loginRequest {
      request.cancel()
    }

    guard let phoneNumber = phoneNumberTextField.text else {
      phoneNumberTextField.shakeWithDuration(0.05)
      phoneNumberTextField.becomeFirstResponder()
      return
    }

    let numberLength = phoneNumber.characters.count
    if numberLength != "+7 (123) 456-78-90".characters.count {
      phoneNumberTextField.shakeWithDuration(0.07)
      phoneNumberTextField.becomeFirstResponder()
      return
    }

    registerForPushNotifications()

    let rawPhoneNumber = formatPhoneNumberToRaw(phoneNumber)
    okButton.isUserInteractionEnabled = false
    let request = ServerManager.sharedInstance.createVerificationTokenFor(rawPhoneNumber) { [weak self] (token, error) -> Void in
      print(token ?? "No token")
      self?.okButton.isUserInteractionEnabled = true
      if let token = token {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let codeCheckViewController = loginStoryboard.instantiateViewController(withIdentifier: "CodeViewController") as! LogInCodeCheckViewController
        codeCheckViewController.token = token
        codeCheckViewController.rawPhoneNumber = rawPhoneNumber
        codeCheckViewController.displayPhoneNumber = phoneNumber
        self?.navigationController?.pushViewController(codeCheckViewController, animated: true)
      } else if let error = error {
        guard let error = error as? URLError else {
          return
        }

        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
          self?.presentAlertWithTitle("Ошибка", andMessage: "Нет подключения к интерету")
        case URLError.cancelled:
          return
        default:
          self?.presentAlertWithTitle("Ошбика", andMessage: "Что-то пошло не так. Попробуйте позже.")
        }
      }
    }

    loginRequest = request
  }

  //MARK: - Keyboard stuff

  func dismissKeyboard(_ sender: AnyObject) {
    view.endEditing(true)
  }

  //MARK: - Support methods

  func formatPhoneNumberToRaw(_ phoneNumber: String) -> String {
    var rawPhoneNumber = phoneNumber
    rawPhoneNumber = rawPhoneNumber.replacingOccurrences(of: " ", with: "")
    rawPhoneNumber = rawPhoneNumber.replacingOccurrences(of: "(", with: "")
    rawPhoneNumber = rawPhoneNumber.replacingOccurrences(of: ")", with: "")
    rawPhoneNumber = rawPhoneNumber.replacingOccurrences(of: "-", with: "")

    return rawPhoneNumber
  }

  func registerForPushNotifications() {
    UIApplication.shared
      .registerUserNotificationSettings(
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
    )
    UIApplication.shared.registerForRemoteNotifications()
/*
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { granted, error in
      })
      UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    } else {
    }
*/

  }
}
