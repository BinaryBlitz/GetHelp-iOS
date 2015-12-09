//
//  Message.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 05/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import RealmSwift

class Message: Object {
  dynamic var content: String = ""
  private dynamic var _sender: String = "user"
  dynamic var dateCreated: NSDate = NSDate()
  let images = List<Image>()

  var sender: MessageSender {
    get {
      return MessageSender(rawValue: _sender)!
    }
    set(newSender) {
      _sender = newSender.rawValue
    }
  }
}
