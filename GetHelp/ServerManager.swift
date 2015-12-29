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

/// Provides communication with the application server
class ServerManager {
  
  static var sharedInstance = ServerManager()
  private let baseURL = "http://getthelp.herokuapp.com/"
  private var manager = Manager.sharedInstance
  
  var apiToken: String? {
    didSet {
      print("Api token updated: \(apiToken)")
    }
  }
  
  var authenticated: Bool {
    return apiToken != nil
  }
  
  enum GHError: ErrorType {
    case Unauthorized
    case InternalServerError
    case UnspecifiedError
    case InvalidData
  }
  
  func saveApiToken() {
    NSUserDefaults.standardUserDefaults().setObject(apiToken, forKey: "apiToken")
  }
  
  private func request(method: Alamofire.Method, path: String, parameters: [String : AnyObject]?, encoding: ParameterEncoding) throws -> Request {
    let url = baseURL + path
    var parameters = parameters
    guard let token = apiToken else {
      throw GHError.Unauthorized
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

  //MARK: - Login
  
  func createVerificationTokenFor(phoneNumber: String, complition: ((token: String?, error: GHError?) -> Void)? = nil) -> Request {
    let parameters = ["phone_number" : phoneNumber]
    let req = manager.request(.POST, baseURL + "verification_tokens/", parameters: parameters, encoding: .JSON)
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    req.responseJSON { (response) -> Void in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      guard let resultValue = response.result.value else {
        complition?(token: nil, error: .InvalidData)
        return
      }
      
      let json = JSON(resultValue)
      
      guard let token = json["token"].string else {
        complition?(token: nil, error: .InvalidData)
        return
      }
      
      complition?(token: token, error: nil)
    }
    
    return req
  }
  
  func verifyPhoneNumberWith(code: String, forPhoneNumber phoneNumber: String,
      andToken token: String, complition: ((error: GHError?) -> Void)? = nil) -> Request {
        
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    let parameters = ["phone_number": phoneNumber, "code": code]
    let req = manager.request(.PATCH, baseURL + "verification_tokens/\(token)/", parameters: parameters, encoding: .JSON)
    req.responseJSON { (response) -> Void in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      guard let resultValue = response.result.value else {
        complition?(error: .InvalidData)
        return
      }
      
      let json = JSON(resultValue)
      
      // if api_token nil then create new user
      if let apiToken = json["api_token"].string {
        self.apiToken = apiToken
        complition?(error: nil)
      } else {
        self.createNewUserWhith(phoneNumber, andVerificationToken: token, complition: { (error) -> Void in
          complition?(error: error)
        })
      }
    }
    
    return req
  }
  
  func createNewUserWhith(phoneNumber: String, andVerificationToken token: String, complition: ((error: GHError?) -> Void)?) -> Request {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    let parameters = ["user": ["phone_number": phoneNumber, "verification_token": token]]
    let req = manager.request(.POST, baseURL + "user/", parameters: parameters, encoding: .JSON)
    req.responseJSON { (response) -> Void in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      guard let resultValue = response.result.value else {
        complition?(error: .InvalidData)
        return
      }
      
      let json = JSON(resultValue)
      
      if let apiToken = json["api_token"].string {
        self.apiToken = apiToken
        complition?(error: nil)
      } else {
        complition?(error: .InvalidData)
      }
    }
    
    return req
  }
  
  //MARK: - Orders
  
  func fetchHelpRequests(complition: ((success: Bool) -> Void)? = nil) -> Request? {
    
    do {
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      let request = try get("orders/")
      request.validate().responseJSON { (response) -> Void in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        switch response.result {
        case .Success(let resultValue):
          let json = JSON(resultValue)
          
          for (_, orderJSON) in json {
            HelpRequest.createFromJSON(orderJSON)
          }
          
          complition?(success: true)
        case .Failure(let error):
          print("error \(error)")
          complition?(success: false)
        }
      }
      
      return request
    } catch GHError.Unauthorized {
      print("Unauthorized")
      complition?(success: false)
    } catch GHError.InternalServerError {
      print("InternalServerError")
      complition?(success: false)
    } catch {
      print("wat")
      complition?(success: false)
    }
    
    return nil
  }
}
