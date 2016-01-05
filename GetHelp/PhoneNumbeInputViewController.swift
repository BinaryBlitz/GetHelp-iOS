//
//  PhoneNumbeInputViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 13/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import Alamofire

class PhoneTokenPair {
  var phoneNumber: String
  var token: String
  
  init(phoneNumber: String, token: String) {
    self.phoneNumber = phoneNumber
    self.token = token
  }
}

class PhoneNumbeInputViewController: UIViewController {
  
  @IBOutlet weak var okButton: UIButton!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var phoneNumberTextField: REFormattedNumberField!
  
  var delegate: LoginNavigationDelegate?
  var loginRequest: Request?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setUpButtons()
    view.backgroundColor = UIColor.clearColor()
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
    phoneNumberTextField.format = "+X (XXX) XXX-XX-XX"
    phoneNumberTextField.placeholder = "+7 (123) 456-78-90"
  }
  
  override func viewWillAppear(animated: Bool) {
    phoneNumberTextField.becomeFirstResponder()
  }
  
  //MARK: - Set up methods
  
  func setUpButtons() {
    okButton.backgroundColor = UIColor.orangeSecondaryColor()
    backButton.backgroundColor = UIColor.orangeSecondaryColor()
    
    okButton.tintColor = UIColor.whiteColor()
    backButton.tintColor = UIColor.whiteColor()
    
    okButton.layer.cornerRadius = 4
    backButton.layer.cornerRadius = 4
  }
  
  //MARK: - IBActions

  @IBAction func okButtonAction(sender: AnyObject) {
    
    if let request = loginRequest {
      request.cancel()
    }
    
    guard let phoneNumber = phoneNumberTextField.text else {
      phoneNumberTextField.shakeWithDuration(0.05)
      phoneNumberTextField.becomeFirstResponder()
      return
    }
    
    let numberLength = phoneNumber.characters.count ?? 0
    if numberLength != "+7 (123) 456-78-90".characters.count {
      phoneNumberTextField.shakeWithDuration(0.07)
      phoneNumberTextField.becomeFirstResponder()
      return
    }
    
    registerForPushNotifications()
    
    let rawPhoneNumber = formatPhoneNumberToRaw(phoneNumber)
    okButton.userInteractionEnabled = false
    let request = ServerManager.sharedInstance.createVerificationTokenFor(rawPhoneNumber) { [weak self] (token, error) -> Void in
      print(token)
      self?.okButton.userInteractionEnabled = true
      if let token = token {
        self?.delegate?.moveForward(PhoneTokenPair(phoneNumber: rawPhoneNumber, token: token))
      } else if let error = error {
        print("Error: \(error)")
        let alert = UIAlertController(title: "Ошибка!", message: "Произошла ошибка! Проверьте ваше подключение к интернету и попробуйте позже", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .Default, handler: nil))
        self?.presentViewController(alert, animated: true, completion: nil)
      }
    }
    
    loginRequest = request
  }
  
  @IBAction func backButtonAction(sender: AnyObject) {
    delegate?.moveBackward(nil)
  }
  
  //MARK: - Keyboard stuff
  
  func dismissKeyboard(sender: AnyObject) {
    view.endEditing(true)
  }
  
  //MARK: - Support methods
  
  func formatPhoneNumberToRaw(phoneNumber: String) -> String {
    var rawPhoneNumber = phoneNumber
    rawPhoneNumber = rawPhoneNumber.stringByReplacingOccurrencesOfString(" ", withString: "")
    rawPhoneNumber = rawPhoneNumber.stringByReplacingOccurrencesOfString("(", withString: "")
    rawPhoneNumber = rawPhoneNumber.stringByReplacingOccurrencesOfString(")", withString: "")
    rawPhoneNumber = rawPhoneNumber.stringByReplacingOccurrencesOfString("-", withString: "")
    
    return rawPhoneNumber
  }
  
  func registerForPushNotifications() {
    UIApplication.sharedApplication()
      .registerUserNotificationSettings(
        UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
    )
    
    UIApplication.sharedApplication().registerForRemoteNotifications()
  }
}

//MARK: - ContainerPresentable

extension PhoneNumbeInputViewController: ContainerPresentable {
  
  var viewController: UIViewController {
    return self
  }
  
  func updateNavigationDelegate(delegate: LoginNavigationDelegate) {
    self.delegate = delegate
  }
  
  func setData(data: AnyObject?) {
    // stuff
  }
}
