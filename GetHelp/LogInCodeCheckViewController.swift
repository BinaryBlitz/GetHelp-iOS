//
//  LogInCodeCheckViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 13/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class LogInCodeCheckViewController: UIViewController {

  @IBOutlet weak var okButton: UIButton!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var codeTextField: UITextField!
  
  var phoneNumber: String!
  var token: String!
  
  var delegate: LoginNavigationDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUpButtons()
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
  }
  
  override func viewWillAppear(animated: Bool) {
    codeTextField.becomeFirstResponder()
  }
 
  override func viewWillDisappear(animated: Bool) {
    codeTextField.text = ""
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
  
  @IBAction func backButtonAction(sender: AnyObject) {
    delegate?.moveBackward(nil)
  }
  
  @IBAction func okButtonAction(sender: AnyObject) {
    guard let code = codeTextField.text else {
      return
    }
    
    ServerManager.sharedInstance.verifyPhoneNumberWith(code, forPhoneNumber: phoneNumber, andToken: token) { (error) -> Void in
      
      if error == nil {
        let token = ServerManager.sharedInstance.apiToken
        UserDefaultsHelper.save(token, forKey: .ApiToken)
        ServerManager.sharedInstance.updateDeviceTokenIfNeeded()
        
        self.dismissViewControllerAnimated(true, completion: nil)
      } else {
        self.codeTextField.shakeWithDuration(0.07)
        self.codeTextField.text = ""
        self.codeTextField.becomeFirstResponder()
      }
    }
  }
  
  //MARK: - Keyboard stuff
  
  func dismissKeyboard(sender: AnyObject) {
    view.endEditing(true)
  }
}

//MARK: - ContainerPresentable

extension LogInCodeCheckViewController: ContainerPresentable {
  var viewController: UIViewController {
    return self
  }
  
  func updateNavigationDelegate(delegate: LoginNavigationDelegate) {
    self.delegate = delegate
  }
  
  func setData(data: AnyObject?) {
    if let pair = data as? PhoneTokenPair {
      self.phoneNumber = pair.phoneNumber
      self.token =  pair.token
    }
  }
}
