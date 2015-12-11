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
  
  var content: String {
    return message.content
  }
  
  var attachmentStatus: String? {
    let imagesCount = message.images.count
    if imagesCount == 0 {
      return nil
    }

    if imagesCount <= 1 {
      return "+\(imagesCount) фотография"
    } else if imagesCount <= 4 {
      return "+\(imagesCount) фотографии"
    } else {
      return "+\(imagesCount) фотографий"
    }
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
