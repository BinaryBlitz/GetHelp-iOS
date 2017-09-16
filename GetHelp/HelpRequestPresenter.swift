//
//  HelpRequestPresenter.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 03/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

class HelpRequestPresenter: HelpRequestPresentable {

  fileprivate var helpRequest: HelpRequest
  fileprivate var helpTypePresenter: HelpTypePresenter!
  fileprivate lazy var dateFormatter = DateFormatter(dateFormat: "EE, dd mmm")
  fileprivate lazy var timeFormatter = DateFormatter(dateFormat: "hh:mm")

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

  var typeColor: UIColor {
    return helpTypePresenter.color
  }

  var name: String {
    return helpRequest.subject
  }

  var schoolInfo: String {
    return "\(helpRequest.school), \(helpRequest.faculty), \(helpRequest.course) курс"
  }

  var email: String {
    return helpRequest.email
  }

  var status: String {
    switch helpRequest.status {
    case .Accepted:
      return "Принято"
    case .InReview:
      return "Рассматривается"
    case .Rejected:
      return "Отклонено"
    case .WaitingForPayment:
      return "Ожидает оплаты"
    case .Refunded:
      return "Возвращен"
    }
  }

  var statusImage: UIImage {
    switch helpRequest.status {
    case .Accepted:
      return #imageLiteral(resourceName: "icAccepted")
    case .InReview:
      return #imageLiteral(resourceName: "icPending")
    case .Rejected:
      return #imageLiteral(resourceName: "icDeclined")
    case .WaitingForPayment:
      return #imageLiteral(resourceName: "icPendingpay")
    case .Refunded:
      return #imageLiteral(resourceName: "icPendingpay")
    }
  }


  func isPayable() -> Bool {
    return helpRequest.status == .WaitingForPayment
  }

  var isViewed: Bool {
    return helpRequest.viewed
  }

  var price: String {
    return "\(helpRequest.sum) \(rubleSign)"
  }

  var indicatorColor: UIColor {
    switch helpRequest.status {
    case .Accepted:
      return .greenAccentColor()
    case .WaitingForPayment:
      return .yellowAccentColor()
    case .InReview:
      return .blueAccentColor()
    case .Rejected:
      return .redAccentColor()
    case .Refunded:
      return .redAccentColor()
    }
  }

  var filesCount: String {
    return "\(helpRequest.filesCount)"
  }

  var commentsCount: String {
    return "\(helpRequest.filesCount)"
  }

  var commentSectionVisible: Bool {
    return helpRequest.commentsCount > 0
  }

  var filesSectionVisible: Bool {
    return helpRequest.filesCount > 0
  }

  var date: String {
    if let startDate = helpRequest.startDate {
      return dateFormatter.string(from: startDate)
    } else if let dueDate = helpRequest.dueDate {
      return dateFormatter.string(from: dueDate)
    }
    return ""
  }

  var time: String {
    if let startDate = helpRequest.startDate {
      return timeFormatter.string(from: startDate)
    } else if let dueDate = helpRequest.dueDate {
      return timeFormatter.string(from: dueDate)
    }

    return ""
  }

  var dateTime: String {
    return "\(date) \(time)"
  }
}
