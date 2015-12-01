//
//  HelpRequest.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 25/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import RealmSwift

/// Contains basic fields for help request
class HelpRequest: Object {
  
//  dynamic var id = ""
  dynamic var subject = ""
  dynamic var cource = ""
  dynamic var school = ""
  dynamic var faculty = ""
  dynamic var helpDescription = ""
  dynamic var deadline: NSDate?
  dynamic var status = ""
  
  // oops
  dynamic var email = ""
  dynamic var duration = 0 // in minutes
  dynamic var activityType = ""
  dynamic var type = ""
  var typeEnum: HelpType? {
    return HelpType(rawValue: type)
  }
  
  func presenter() -> HelpRequestPresenter? {
    return Presenter(helpRequest: self)
  }

//  override class func primaryKey() -> String? {
//    return "id"
//  }
}

extension HelpRequest {
  
  private class Presenter: HelpRequestPresenter {
    
    private var helpRequest: HelpRequest
    private let dateFormatter: NSDateFormatter
    private let timeFormatter: NSDateFormatter
    private var helpTypePresenter: HelpTypePresenter!
    
    init?(helpRequest: HelpRequest) {
      self.helpRequest = helpRequest
      dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "dd.MM.yyyy"
      timeFormatter = NSDateFormatter()
      timeFormatter.dateFormat = "hh:mm"
      
      if let type = helpRequest.typeEnum {
        helpTypePresenter = HelpTypePresenter(type: type)
      } else {
        return nil
      }
    }

    var type: String {
      return helpTypePresenter.name
    }
    
    var name: String {
      return helpRequest.subject
    }

    var status: String {
      return helpRequest.type
      
    }
    var indicatorColor: UIColor {
      return UIColor.orangeSecondaryColor()
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
  }
}