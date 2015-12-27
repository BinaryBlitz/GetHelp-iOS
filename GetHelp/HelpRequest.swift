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
  
  dynamic var id = 0
  dynamic var subject = ""
  dynamic var cource = ""
  dynamic var school = ""
  dynamic var faculty = ""
  dynamic var helpDescription = ""
  dynamic var deadline: NSDate?
  dynamic var _status = "in_review"
  var status: HelpRequestStatus {
    get {
      return HelpRequestStatus(rawValue: _status)!
    }
    set(newStatus) {
      self._status = newStatus.rawValue
    }
  }
  
  // oops
  dynamic var email = ""
  dynamic var duration = 0 // in minutes
  dynamic var activityType = ""
  dynamic var _type = "normal"
  var type: HelpType {
    get {
      return HelpType(rawValue: _type)!
    }
    set(newType) {
      self._type = newType.rawValue
    }
  }

  let messages = List<Message>()
  
  func presenter() -> HelpRequestPresentable {
    return HelpRequestPresenter(helpRequest: self)
  }

//  override class func primaryKey() -> String? {
//    return "id"
//  }
}

