//
//  HelpRequestPresenter.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 03/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

class HelpRequestPresenter: HelpRequestPresentable {
  
  private var helpRequest: HelpRequest
  private var helpTypePresenter: HelpTypePresenter!
  private lazy var dateFormatter = NSDateFormatter(dateFormat: "dd.MM.yyyy")
  private lazy var timeFormatter = NSDateFormatter(dateFormat: "hh:mm")
  
  init(helpRequest: HelpRequest) {
    self.helpRequest = helpRequest
    helpTypePresenter = HelpTypePresenter(type: helpRequest.type)
  }
  
  var id: String {
    return "#\(helpRequest.id)"
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
    case .WaitingForPayment:
      return "Ожидает оплаты"
    }
  }
  
  func isPayable() -> Bool {
    switch helpRequest.status {
    case .WaitingForPayment:
      return true
    default:
      return false
    }
  }
  
  var price: String {
    return "\(helpRequest.price) \(rubleSign)"
  }

  var indicatorColor: UIColor {
    switch helpRequest.status {
    case .Accepted:
      return UIColor.greenAccentColor()
    case .WaitingForPayment:
      return UIColor.yellowAccentColor()
    case .Done:
      return UIColor.lightGrayColor()
    case .InReview:
      return UIColor.blueAccentColor()
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
