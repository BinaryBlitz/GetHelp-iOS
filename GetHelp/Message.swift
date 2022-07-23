//
//  Message.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 05/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import RealmSwift
import SwiftyJSON
import SwiftDate

class Message: Object {

  dynamic var id: Int = 0
  dynamic var orderId: Int = 0
  dynamic var content: String?
  dynamic var imageURLString: String?
  dynamic var imageThumbURLString: String?
  fileprivate dynamic var _sender: String = MessageSender.User.rawValue
  dynamic var dateCreated: Date = Date()

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
  static func createFromJSON(_ json: JSON) -> Message? {
    guard let id = json["id"].int,
        let createdDateString = json["created_at"].string,
        let sender = json["category"].string,
        let orderId = json["order_id"].int
    else {
      return nil
    }

    let message = Message()
    message.id = id
    message.orderId = orderId
    message._sender = sender

    if let dateCreated = DateInRegion(string: createdDateString, format: .iso8601(options: .withInternetDateTimeExtended))?.absoluteDate {
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

  func convertToDict() -> [String : Any] {
    return ["": "" as Any]
  }

}
