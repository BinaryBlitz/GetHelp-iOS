//
//  Message.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 05/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import RealmSwift
import SwiftyJSON

class Message: Object {
  
  dynamic var id: Int = 0
  dynamic var orderId: Int = 0
  dynamic var content: String?
  dynamic var imageURLString: String?
  dynamic var imageThumbURLString: String?
  private dynamic var _sender: String = MessageSender.User.rawValue
  dynamic var dateCreated: NSDate = NSDate()

  var sender: MessageSender {
    get {
      return MessageSender(rawValue: _sender)!
    }
    set(newSender) {
      _sender = newSender.rawValue
    }
  }
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

//MARK: - ServerModelPresentable

extension Message: ServerModelPresentable {
  
  //TODO: implement protocol
  static func createFromJSON(json: JSON) -> Message? {
    guard let id = json["id"].int,
        createdDateString = json["created_at"].string,
        sender = json["category"].string,
        orderId = json["order_id"].int
    else {
      return nil
    }
    
    let message = Message()
    message.id = id
    message.orderId = orderId
    message._sender = sender
    if let dateCreated = NSDate(dateString: createdDateString) {
      message.dateCreated = dateCreated
    }
    
    if let content = json["content"].string {
      message.content = content
    }
    
    if let imageURLString = json["image_url"].string {
      message.imageURLString = imageURLString
    }
    
    if let imageThumbURLString = json["image_thumb_url"].string {
      message.imageThumbURLString = imageThumbURLString
    }
    
    return message
  }
  
  func convertToDict() -> [String : AnyObject] {
    return ["": ""]
  }
}
