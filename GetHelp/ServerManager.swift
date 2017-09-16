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

  let baseURL = "https://gethelp24.ru"

  var apiToken: String? {
    didSet {
      print("API token updated: \(apiToken ?? "")")
      UserDefaultsHelper.save(false, forKey: .DeviceTokenUploadStatus)
      ServerManager.sharedInstance.updateDeviceTokenIfNeeded()
    }
  }

  var deviceToken: String? {
    didSet { print("Device token updated: \(deviceToken ?? "")") }
  }

  // MARK: - Preperties

  var authenticated: Bool { return apiToken != nil }


  func request(_ method: HTTPMethod, _ path: String,
                       parameters: [String : Any]?,
                       encoding: ParameterEncoding) throws -> DataRequest {

    let url = baseURL + path
    var parameters = parameters

    guard let token = apiToken else { throw ServerError.unauthorized }

    if parameters != nil {
      parameters!["api_token"] = token as Any
    } else {
      parameters = ["api_token": token as Any]
    }

    return Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: nil).responseDebugPrint()
  }

  func get(_ path: String, params: [String: Any]? = nil) throws -> DataRequest {
    return try request(.get, path, parameters: params, encoding: URLEncoding.default)
  }

  func post(_ path: String, params: [String: Any]? = nil) throws -> DataRequest {
    return try request(.post, path, parameters: params, encoding: JSONEncoding.default)
  }

  func patch(_ path: String, params: [String: Any]? = nil) throws -> DataRequest {
    return try request(.patch, path, parameters: params, encoding: JSONEncoding.default)
  }

  // MARK: - Login

  func createVerificationTokenFor(_ phoneNumber: String,
                                  completion: ((_ token: String?, _ error: Error?) -> Void)? = nil) -> Request? {

    let parameters = ["phone_number" : phoneNumber]
    let request = Alamofire.request(baseURL + "/verification_tokens", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)

    UIApplication.shared.isNetworkActivityIndicatorVisible = true

    request.responseJSON { (response) -> Void in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false

      guard let resultValue = response.result.value else {
        completion?(nil, ServerError.invalidData)
        return
      }

      let json = JSON(resultValue)

      guard let token = json["token"].string else {
        completion?(nil, ServerError.invalidData)
        return
      }

      completion?(token, nil)
    }

    return request
  }

  func verifyPhoneNumberWith(_ code: String,
                             forPhoneNumber phoneNumber: String,
                             andToken token: String,
                             completion: ((_ error: Error?) -> Void)? = nil) -> Request {

    UIApplication.shared.isNetworkActivityIndicatorVisible = true

    let parameters = ["phone_number": phoneNumber, "code": code]
    let request = Alamofire.request(baseURL + "/verification_tokens/\(token)", method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: nil)

    request.validate().responseJSON { response in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false

      switch response.result {
      case .success(let resultValue):
        let json = JSON(resultValue)

        // Create new user if api_token is nil
        if let apiToken = json["api_token"].string {
          self.apiToken = apiToken
          UserDefaultsHelper.save(false, forKey: .DeviceTokenUploadStatus)
          completion?(nil)
        } else {
          self.createNewUserWith(phoneNumber, andVerificationToken: token) { error in
            completion?(error)
          }
        }
      case .failure(let error):
        print("Error: \(error)")
        completion?(error)
      }
    }
    return request
  }

  func createNewUserWith(_ phoneNumber: String,
                         andVerificationToken token: String,
                         completion: ((_ error: Error?) -> Void)?) -> Void {

    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    let parameters: [String: Any] = [
      "user": [
        "phone_number": phoneNumber,
        "verification_token": token,
        "device_token": ServerManager.sharedInstance.deviceToken ?? nil,
        "platform": "ios"
      ]
    ]

    let req = try? self.request(.post, baseURL + "/user", parameters: parameters, encoding: JSONEncoding.default)
    req?.validate().responseJSON { (response) -> Void in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
      switch response.result {
      case .success(let resultValue):
        let json = JSON(resultValue)

        if let apiToken = json["api_token"].string {
          self.apiToken = apiToken
          completion?(nil)
        } else {
          completion?(ServerError.invalidData)
        }
      case .failure(let error):
        completion?(error)
      }
    }
  }

  // MARK: - HelpRequests

  func fetchHelpRequests(_ completion: ((_ success: Bool, _ error: Error?) -> Void)? = nil) -> Void {

    do {
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
      let request = try get("/orders")

      request.validate().responseJSON { (response) -> Void in
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        switch response.result {
        case .success(let resultValue):
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

          completion?(true, nil)
        case .failure(let error):
          completion?(false, error)
        }
      }

    } catch let error {
      completion?(false, error)
    }
  }

  func createNewHelpRequest(_ helpRequest: HelpRequest,
                            completion: ((_ helpRequest: HelpRequest?, _ error: Error?) -> Void)? = nil) -> Request? {

    let order = helpRequest.convertToDict()
    let parameters: [String: AnyObject] = ["order": order as AnyObject]

    do {
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
      let request = try post("/orders", params: parameters)

      request.validate().responseJSON { (response) -> Void in
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        switch response.result {
        case .success(let resultValue):
          let json = JSON(resultValue)

          if let helpRequest = HelpRequest.createFromJSON(json) {
            do {
              let realm = try Realm()
              try realm.write { () -> Void in
                realm.add(helpRequest)
              }
              completion?(helpRequest, nil)
            } catch let error {
              completion?(nil, error)
            }
          } else {
            completion?(nil, ServerError.invalidData)
          }
        case .failure(let error):
          completion?(nil, error)
        }
      }

      return request
    } catch let error {
      completion?(nil, error)
    }

    return nil
  }

  //MARK: - Messages

  func fetchAllMessagesForOrder(_ order: HelpRequest, completion: ((_ success: Bool, _ error: Error?) -> Void)? = nil) {

    do {
      UIApplication.shared.isNetworkActivityIndicatorVisible = true

      let request = try get("/orders/\(order.id)/messages")
      request.validate().responseJSON { (response) -> Void in
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        switch response.result {
        case .success(let resultValue):
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
            completion?(true, nil)
          } catch let error {
            completion?(false, error)
          }
        case .failure(let error):
          completion?(false, error)
        }
      }

    } catch let error {
      completion?(false, error)
    }
  }

  func sendMessageWithText(_ content: String, toOrder order: HelpRequest, completion: ((_ success: Bool, _ error: Error?) -> Void)? = nil) -> Request? {

    do {
      let parameters: [String: Any] = ["message": ["content": content]]

      let request = try post("/orders/\(order.id)/messages", params: parameters)
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
      request.validate().responseJSON { response in
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        switch response.result {
        case .success(let resultValue):
          let json = JSON(resultValue)

          guard let message = Message.createFromJSON(json) else {
            completion?(false, ServerError.invalidData)
            return
          }

          do {
            let realm = try Realm()
            try realm.write {
              realm.add(message, update: true)
            }

            completion?(true, nil)
          } catch let error {
            completion?(false, error)
          }
        case .failure(let error):
          completion?(false, error)
        }
      }

      return request
    } catch let error {
      completion?(false, error)
    }
    return nil
  }

  func sendMessageWithImage(_ image: UIImage, toOrder order: HelpRequest, completion: ((_ success: Bool, _ error: Error?) -> Void)? = nil) -> Request? {

    do {
      let imageData = UIImageJPEGRepresentation(image, 0.7)
      let base64ImageString = imageData?.base64EncodedString(options: .lineLength64Characters) ?? ""
      let formattedImage = "data:image/gif;base64,\(base64ImageString)"
      let parameters: [String: Any] = ["message": ["image": formattedImage]]

      let request = try post("/orders/\(order.id)/messages", params: parameters)
      request.validate().responseJSON { response in
        switch response.result {
        case .success(let resultValue):
          let json = JSON(resultValue)

          guard let message = Message.createFromJSON(json) else {
            completion?(false, ServerError.invalidData)
            return
          }

          do {
            let realm = try Realm()
            try realm.write {
              realm.add(message, update: true)
            }

            completion?(true, nil)
          } catch let error {
            completion?(false, error)
          }
        case .failure(let error):
          completion?(false, error)
        }
      }

      return request
    } catch let error {
      completion?(false, error)
    }
    return nil
  }

  // MARK: - Payments

  func paymentsURLForOrderID(_ orderID: Int, completion: ((_ paymentURL: URL?, _ error: Error?) -> Void)? = nil) {

    do {
      let request = try post("/orders/\(orderID)/payments")
      request.validate().responseJSON { response in
        switch response.result {
        case .success(let resultValue):
          let json = JSON(resultValue)
          guard let paymentURLString = json["url"].string else {
            completion?(nil, ServerError.invalidData)
            return
          }

          guard let paymentURL = URL(string: paymentURLString) else {
            completion?(nil, ServerError.invalidData)
            return
          }

          completion?(paymentURL, nil)

        case .failure(let error):
          completion?(nil, error)
        }
      }

    } catch let error {
      print("Error: \(error)")
      completion?(nil, error)
    }

  }

  // MARK: - Device token

  func updateDeviceTokenIfNeeded(_ completion: ((_ success: Bool, _ error: Error?) -> Void)? = nil) {

    if let uploadStatus = UserDefaultsHelper.loadObjectForKey(.DeviceTokenUploadStatus) as? Bool, uploadStatus == true {
      return
    }

    guard let deviceToken = deviceToken else { return }

    do {
      let parameters: [String: Any] = ["user": ["device_token": deviceToken]]
      let request = try patch("/user", params: parameters)

      request.validate().response { response in
        if let error = response.error {
          completion?(false, error)
        } else {
          UserDefaultsHelper.save(true, forKey: .DeviceTokenUploadStatus)
          completion?(true, nil)
        }

      }

    } catch let error {
      completion?(false, error)
    }

  }
}

extension Alamofire.DataRequest {
  func responseDebugPrint() -> Self {
    return responseJSON() {
      response in
      if let  JSON = response.result.value,
        let JSONData = try? JSONSerialization.data(withJSONObject: JSON, options: .prettyPrinted),
        let prettyString = NSString(data: JSONData, encoding: String.Encoding.utf8.rawValue) {
        print(prettyString)
      } else if let error = response.result.error {
        print("Error Debug Print: \(error.localizedDescription)")
      }
    }

  }
}
