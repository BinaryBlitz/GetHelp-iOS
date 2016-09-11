//
//  ServerManager.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 26/11/2015.
//  Copyright (c) 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

/// Provides communication with the application server
class ServerManager {
  
  static var sharedInstance = ServerManager()
  
  //MARK: - Fields
  
  private var manager = Manager.sharedInstance
  let baseURL = "https://getthelp.ru"
  
  var apiToken: String? {
    didSet {
      print("Api token updated: \(apiToken ?? "")")
      UserDefaultsHelper.save(false, forKey: .DeviceTokenUploadStatus)
      ServerManager.sharedInstance.updateDeviceTokenIfNeeded()
    }
  }
  
  var deviceToken: String? {
    didSet {
      print("Device token updated: \(deviceToken ?? "")")
    }
  }
  
  // MARK: - Preperties
  
  var authenticated: Bool {
    return apiToken != nil
  }
  
  // MARK: - Basic private methods
  
  private func request(method: Alamofire.Method, path: String,
      parameters: [String : AnyObject]?,
      encoding: ParameterEncoding) throws -> Request {
    let url = baseURL + path
    var parameters = parameters
    guard let token = apiToken else {
      throw ServerError.Unauthorized
    }

    if parameters != nil {
      parameters!["api_token"] = token
    } else {
      parameters = ["api_token": token]
    }

    return manager.request(method, url, parameters: parameters, encoding: encoding)
  }

  private func get(path: String, params: [String: AnyObject]? = nil) throws -> Request {
    return try request(.GET, path: path, parameters: params, encoding: .URL)
  }

  private func post(path: String, params: [String: AnyObject]? = nil) throws -> Request {
    return try request(.POST, path: path, parameters: params, encoding: .JSON)
  }

  private func patch(path: String, params: [String: AnyObject]? = nil) throws -> Request {
    return try request(.PATCH, path: path, parameters: params, encoding: .JSON)
  }

  // MARK: - Login
  
  func createVerificationTokenFor(phoneNumber: String, completion: ((token: String?, error: ErrorType?) -> Void)? = nil) -> Request {
    let parameters = ["phone_number" : phoneNumber]
    let req = manager.request(.POST, baseURL + "/verification_tokens", parameters: parameters, encoding: .JSON)
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    req.responseJSON { (response) -> Void in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      guard let resultValue = response.result.value else {
        completion?(token: nil, error: ServerError.InvalidData)
        return
      }
      
      let json = JSON(resultValue)
      
      guard let token = json["token"].string else {
        completion?(token: nil, error: ServerError.InvalidData)
        return
      }
      
      completion?(token: token, error: nil)
    }
    
    return req
  }
  
  func verifyPhoneNumberWith(code: String, forPhoneNumber phoneNumber: String,
      andToken token: String, completion: ((error: ErrorType?) -> Void)? = nil) -> Request {
        
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    let parameters = ["phone_number": phoneNumber, "code": code]
    let req = manager.request(.PATCH, baseURL + "/verification_tokens/\(token)", parameters: parameters, encoding: .JSON)
    
    req.validate().responseJSON { response in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      
      switch response.result {
      case .Success(let resultValue):
        let json = JSON(resultValue)
        
        // if api_token nil then create new user
        if let apiToken = json["api_token"].string {
          self.apiToken = apiToken
          UserDefaultsHelper.save(false, forKey: .DeviceTokenUploadStatus)
          completion?(error: nil)
        } else {
          self.createNewUserWith(phoneNumber, andVerificationToken: token) { error in
            completion?(error: error)
          }
        }
      case .Failure(let error):
        print("error: \(error)")
        completion?(error: error)
      }
    }
    
    return req
  }
  
  func createNewUserWith(phoneNumber: String,
                         andVerificationToken token: String,
                         completion: ((error: ErrorType?) -> Void)?) -> Request {
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    let parameters: [String: AnyObject] = [
      "user": [
        "phone_number": phoneNumber,
        "verification_token": token,
        "device_token": ServerManager.sharedInstance.deviceToken ?? NSNull(),
        "platform": "ios"
      ]
    ]
    
    let req = manager.request(.POST, baseURL + "/user", parameters: parameters, encoding: .JSON)
    req.validate().responseJSON { (response) -> Void in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      switch response.result {
      case .Success(let resultValue):
        let json = JSON(resultValue)
        
        if let apiToken = json["api_token"].string {
          self.apiToken = apiToken
          completion?(error: nil)
        } else {
          completion?(error: ServerError.InvalidData)
        }
      case .Failure(let error):
        completion?(error: error)
      }
    }
    
    return req
  }
  
  // MARK: - HelpRequests
  
  func fetchHelpRequests(completion: ((success: Bool, error: ErrorType?) -> Void)? = nil) -> Request? {
    
    do {
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      let request = try get("/orders")
      request.validate().responseJSON { (response) -> Void in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        switch response.result {
        case .Success(let resultValue):
          let json = JSON(resultValue)
          
          do {
            let realm = try Realm()
            try realm.write {
              for (_, orderJSON) in json {
                guard let helpRequest = HelpRequest.createFromJSON(orderJSON) else {
                  continue
                }
                
                realm.add(helpRequest, update: true)
              }
            }
          } catch let error {
            print("Error: \(error)")
          }
          
          completion?(success: true, error: nil)
        case .Failure(let error):
          completion?(success: false, error: error)
        }
      }
      
      return request
    } catch let error {
      completion?(success: false, error: error)
    }
    
    return nil
  }
  
  func createNewHelpRequest(helpRequest: HelpRequest, completion: ((helpRequest: HelpRequest?, error: ErrorType?) -> Void)? = nil) -> Request? {
    
    let order = helpRequest.convertToDict()
    let parameters: [String: AnyObject] = ["order": order]
    
    do {
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      
      let request = try post("/orders", params: parameters)
      request.validate().responseJSON { (response) -> Void in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        switch response.result {
        case .Success(let resultValue):
          let json = JSON(resultValue)
          
          if let helpRequest = HelpRequest.createFromJSON(json) {
            do {
              let realm = try Realm()
              try realm.write { () -> Void in
                realm.add(helpRequest)
              }
              completion?(helpRequest: helpRequest, error: nil)
            } catch let error {
              completion?(helpRequest: nil, error: error)
            }
          } else {
            completion?(helpRequest: nil, error: ServerError.InvalidData)
          }
        case .Failure(let error):
          completion?(helpRequest: nil, error: error)
        }
      }
      
      return request
    } catch let error {
      completion?(helpRequest: nil, error: error)
    }
    
    return nil
  }
  
  //MARK: - Messages
  
  func fetchAllMessagesForOrder(order: HelpRequest, completion: ((success: Bool, error: ErrorType?) -> Void)? = nil) -> Request? {
    
    do {
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      
      let request = try get("/orders/\(order.id)/messages")
      request.validate().responseJSON { (response) -> Void in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        switch response.result {
        case .Success(let resultValue):
          let json = JSON(resultValue)
          
          var messages = [Message]()
          for (_, messageData) in json {
            if let message = Message.createFromJSON(messageData) {
              messages.append(message)
            }
          }
          
          do {
            let realm = try Realm()
            try realm.write {
              realm.add(messages, update: true)
            }
            completion?(success: true, error: nil)
          } catch let error {
            completion?(success: false, error: error)
          }
        case .Failure(let error):
          completion?(success: false, error: error)
        }
      }
      
      return request
    } catch let error {
      completion?(success: false, error: error)
    }
    
    return nil
  }
  
  func sendMessageWithText(content: String, toOrder order: HelpRequest, completion: ((success: Bool, error: ErrorType?) -> Void)? = nil) -> Request? {
    
    do {
      let parameters: [String: AnyObject] = ["message": ["content": content]]
      
      let request = try post("/orders/\(order.id)/messages", params: parameters)
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      request.validate().responseJSON { response in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        switch response.result {
        case .Success(let resultValue):
          let json = JSON(resultValue)
          
          guard let message = Message.createFromJSON(json) else {
            completion?(success: false, error: ServerError.InvalidData)
            return
          }
          
          do {
            let realm = try Realm()
            try realm.write {
              realm.add(message, update: true)
            }
          
            completion?(success: true, error: nil)
          } catch let error {
            completion?(success: false, error: error)
          }
        case .Failure(let error):
          completion?(success: false, error: error)
        }
      }
      
      return request
    } catch let error {
      completion?(success: false, error: error)
    }
    return nil
  }
  
  func sendMessageWithImage(image: UIImage, toOrder order: HelpRequest, completion: ((success: Bool, error: ErrorType?) -> Void)? = nil) -> Request? {
    
    do {
      let imageData = UIImagePNGRepresentation(image)
      let base64ImageString = imageData?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
      let formattedImage = "data:image/gif;base64,\(base64ImageString ?? NSNull())"
      let parameters: [String: AnyObject] = ["message": ["image": formattedImage]]
      
      let request = try post("/orders/\(order.id)/messages", params: parameters)
      request.validate().responseJSON { response in
        switch response.result {
        case .Success(let resultValue):
          let json = JSON(resultValue)
          
          guard let message = Message.createFromJSON(json) else {
            completion?(success: false, error: ServerError.InvalidData)
            return
          }
          
          do {
            let realm = try Realm()
            try realm.write {
              realm.add(message, update: true)
            }
            
            completion?(success: true, error: nil)
          } catch let error {
            completion?(success: false, error: error)
          }
        case .Failure(let error):
          completion?(success: false, error: error)
        }
      }
      
      return request
    } catch let error {
      completion?(success: false, error: error)
    }
    return nil
  }
  
  // MARK: - Payments
  
  func paymentsURLForOrderID(orderID: Int, completion: ((paymentURL: NSURL?, error: ErrorType?) -> Void)? = nil) -> Request? {
    
    do {
      let request = try post("/orders/\(orderID)/payments")
      request.validate().responseJSON { response in
        switch response.result {
        case .Success(let resultValue):
          let json = JSON(resultValue)
          guard let paymentURLString = json["url"].string else {
            completion?(paymentURL: nil, error: ServerError.InvalidData)
            return
          }
          
          guard let paymentURL = NSURL(string: paymentURLString) else {
            completion?(paymentURL: nil, error: ServerError.InvalidData)
            return
          }
          
          completion?(paymentURL: paymentURL, error: nil)
          
        case .Failure(let error):
          completion?(paymentURL: nil, error: error)
        }
      }
      
      return request
    } catch let error {
      print("Error: \(error)")
      completion?(paymentURL: nil, error: error)
    }
    
    return nil
  }
  
  // MARK: - Device token
  
  func updateDeviceTokenIfNeeded(completion: ((success: Bool, error: ErrorType?) -> Void)? = nil) -> Request? {
    
    if let uploadStatus = UserDefaultsHelper.loadObjectForKey(.DeviceTokenUploadStatus) as? Bool
        where uploadStatus == true {
      return nil
    }
    
    guard let deviceToken = deviceToken else { return nil }
    
    do {
      let parameters: [String: AnyObject] = ["user": ["device_token": deviceToken]]
      let request = try patch("/user", params: parameters)
      
      request.validate().response { (_, response, data, error) -> Void in
        if let error = error {
          completion?(success: false, error: error)
        } else {
          UserDefaultsHelper.save(true, forKey: .DeviceTokenUploadStatus)
          completion?(success: true, error: nil)
        }
      }
      
      return request
    } catch let error {
      completion?(success: false, error: error)
    }
    
    return nil
  }
}
