//
//  MessagePresenter.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 06/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

struct MessagePresenter: MessagePresentable {

  let message: Message

  private let dateFormatter = NSDateFormatter(dateFormat: "dd.MM.yy")
  private let timeFormatter = NSDateFormatter(dateFormat: "HH:mm")

  //MARK : - MessageContentPresentable
  
  var content: String? {
    return message.content
  }
  
  var imageURL: NSURL? {
    return urlFromString(message.imageURLString)
  }
  
  var imageThumbURL: NSURL? {
    return urlFromString(message.imageThumbURLString)
  }
  
  private func urlFromString(urlString: String?) -> NSURL? {
    guard let urlString = urlString else {
      return nil
    }
    
    let fullURLString = ServerManager.sharedInstance.baseURL + urlString
    
    return NSURL(string: fullURLString)
  }
  
  //MARK: - DateTimePresentable
  
  var date: String {
    return dateFormatter.stringFromDate(message.dateCreated)
  }

  var time: String {
    return timeFormatter.stringFromDate(message.dateCreated)
  }
  
  var dateTime: String {
    let calendar = NSCalendar.currentCalendar()
    let messageDateComponents = calendar.components([.Day, .Month, .Year], fromDate: message.dateCreated)
    let currentDate = calendar.components([.Day, .Month, .Year], fromDate: NSDate())
    if messageDateComponents.day == currentDate.day &&
        messageDateComponents.month == currentDate.month &&
      messageDateComponents.year == currentDate.year {
        return time
    }
    
    return "\(date) \(time)"
  }
}
