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
  dynamic var sender: String = ""
  let imagesLinks = List<Image>()
  dynamic var dateCreated: NSDate = NSDate()
  dynamic var helpReuqest: HelpRequest?

  var senderEnum: MessageSender? {
    return MessageSender(rawValue: sender)
  }
}
