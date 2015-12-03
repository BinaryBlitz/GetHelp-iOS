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
  
  func presenter() -> HelpRequestPresentable? {
    return HelpRequestPresenter(helpRequest: self)
  }

//  override class func primaryKey() -> String? {
//    return "id"
//  }
}

