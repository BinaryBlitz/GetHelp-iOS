//
//  MessagePresenter.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 06/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

struct MessagePresenter: MessagePresentable {

  let message: Message
  var color: UIColor?

  fileprivate let dateFormatter = DateFormatter(dateFormat: "dd.MM.yy")
  fileprivate let timeFormatter = DateFormatter(dateFormat: "HH:mm")

  //MARK : - MessageContentPresentable

  var content: String? {
    return message.content
  }

  var imageURL: URL? {
    return urlFromString(message.imageURLString)
  }

  var imageThumbURL: URL? {
    return urlFromString(message.imageThumbURLString)
  }

  fileprivate func urlFromString(_ urlString: String?) -> URL? {
    guard let urlString = urlString else {
      return nil
    }

    return URL(string: urlString)
  }

  //MARK: - DateTimePresentable

  var date: String {
    return dateFormatter.string(from: message.dateCreated)
  }

  var time: String {
    return timeFormatter.string(from: message.dateCreated)
  }

  var dateTime: String {
    let calendar = Calendar.current
    let messageDateComponents = (calendar as NSCalendar).components([.day, .month, .year], from: message.dateCreated as Date)
    let currentDate = (calendar as NSCalendar).components([.day, .month, .year], from: Date())
    if messageDateComponents.day == currentDate.day &&
        messageDateComponents.month == currentDate.month &&
      messageDateComponents.year == currentDate.year {
        return time
    }

    return "\(date) \(time)"
  }
}
