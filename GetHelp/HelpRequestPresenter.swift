//
//  HelpRequestPresenter.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 03/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

class HelpRequestPresenter: HelpRequestPresentable {
  
  private var helpRequest: HelpRequest
  private let dateFormatter: NSDateFormatter
  private let timeFormatter: NSDateFormatter
  private var helpTypePresenter: HelpTypePresenter!
  
  init(helpRequest: HelpRequest) {
    self.helpRequest = helpRequest
    dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy"
    timeFormatter = NSDateFormatter()
    timeFormatter.dateFormat = "hh:mm"
    helpTypePresenter = HelpTypePresenter(type: helpRequest.type)
  }

  var type: String {
    return helpTypePresenter.name
  }
  
  var name: String {
    return helpRequest.subject
  }

  var schoolInfo: String {
    return "\(helpRequest.school), \(helpRequest.faculty), \(helpRequest.cource) курс"
  }

  var email: String {
    return helpRequest.email
  }

  var status: String {
    switch helpRequest.status {
    case .Accepted:
      return "Принят"
    case .Done:
      return "Завершен"
    case .InReview:
      return "Рассматривается"
    case .Rejected:
      return "Отклонен"
    case .WatingForPayment:
      return "Ожидает оплаты"
    }
  }

  var indicatorColor: UIColor {
    switch helpRequest.status {
    case .Accepted, .WatingForPayment:
      return UIColor.greenAccentColor()
    case .Done, .InReview:
      return UIColor.lightGrayColor()
    case .Rejected:
      return UIColor.redAccentColor()
    }
  }

  var date: String {
    guard let date = helpRequest.deadline else {
      return ""
    }
    
    return dateFormatter.stringFromDate(date)
  }
  
  var time: String {
    guard let date = helpRequest.deadline else {
      return ""
    }
    
    return timeFormatter.stringFromDate(date)
  }
  
  var dateTime: String {
    return "\(date) \(time)"
  }
}
