//
//  LogInCodeCheckViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 13/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import Alamofire

class LogInCodeCheckViewController: UIViewController, LightContentViewController {

  var loginRequest: Request?

  @IBOutlet weak var sendAgainButton: UIButton!
  @IBOutlet weak var codeTextField: REFormattedNumberField!
  @IBOutlet weak var codeSentLabel: UILabel!
  @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!

  var observers: [Any] = []

  var rawPhoneNumber: String!
  var displayPhoneNumber: String!
  var token: String!

  func resetButton() {
    sendAgainButton.isEnabled = false
    DispatchQueue.main.asyncAfter(deadline: .now() + 60.0, execute: { [weak self] in
      self?.sendAgainButton.isEnabled = true
    })
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    resetButton()
    codeTextField.format = "X  X  X  X"
    navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logoGethelpNavbar1"))
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:))))

    codeSentLabel.text = "На номер \(displayPhoneNumber!) был отправлен код"
    codeTextField.addTarget(self, action: #selector(self.codeChanged), for: .editingChanged)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.observers = bottomLayoutConstraint.addObserversUpdateWithKeyboard(view: view)
    codeTextField.becomeFirstResponder()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    codeTextField.text = ""
    view.endEditing(true)
    self.observers.forEach { NotificationCenter.default.removeObserver($0) }
    self.observers = []
  }

  func codeChanged() {
    let code = codeTextField.unformattedText.onlyDigits
    guard loginRequest == nil && code.characters.count == 4 else {
      return
    }

    view.endEditing(true)
    view.isUserInteractionEnabled = false

    loginRequest = ServerManager.sharedInstance.verifyPhoneNumberWith(code, forPhoneNumber: rawPhoneNumber, andToken: token) { [weak self] (error) -> Void in
      self?.loginRequest = nil
      self?.view.isUserInteractionEnabled = true
      if error == nil {
        let token = ServerManager.sharedInstance.apiToken
        UserDefaultsHelper.save(token, forKey: .ApiToken)
        ServerManager.sharedInstance.updateDeviceTokenIfNeeded()

        self?.dismiss(animated: true, completion: nil)
      } else {
        self?.codeTextField.shakeWithDuration(0.07)
        self?.codeTextField.text = ""
        self?.codeTextField.becomeFirstResponder()
      }
    }
  }

  @IBAction func sendAgainButtonAction(_ sender: Any) {

    sendAgainButton.isEnabled = false
    _ = ServerManager.sharedInstance.createVerificationTokenFor(rawPhoneNumber) { [weak self] (token, error) -> Void in
      print(token ?? "No token")
      if let token = token {
        self?.token = token
        self?.resetButton()
        self?.presentAlertWithMessage("Код был отправлен повторно")
      } else if let error = error {
        self?.sendAgainButton.isEnabled = true
        guard let error = error as? URLError else {
          self?.presentAlertWithMessage("Ошибка!")
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

  }
  

  //MARK: - Keyboard stuff

  func dismissKeyboard(_ sender: AnyObject) {
    view.endEditing(true)
  }
}
