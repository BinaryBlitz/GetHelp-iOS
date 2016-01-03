//
//  MessagePresenter.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 06/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

struct MessagePresenter: MessagePresentable {

  let message: Message

  private let dateFormatter = NSDateFormatter(dateFormat: "HH:mm")

  //MARK : - MessageContentPresentable
  
  var content: String? {
    return message.content
  }
  
  var imageURL: NSURL? {
    guard let urlString = message.imageURLString else {
      return nil
    }
    
    return NSURL(string: urlString)
  }
  
  //MARK: - DateTimePresentable
  
  var date: String {
    return ""
  }

  var time: String {
    return dateFormatter.stringFromDate(message.dateCreated)
  }
  
  var dateTime: String {
    return "\(date) \(time)"
  }
}
