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
  
  dynamic var content: String?
  dynamic var imageURLString: String?
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
}

//MARK: - ServerModelPresentable

extension Message: ServerModelPresentable {
  
  //TODO: implement protocol
  static func createFromJSON(json: JSON) -> Message? {
    return Message()
  }
  
  func convertToDict() -> [String : AnyObject] {
    return ["": ""]
  }
}
