//
//  HelpRequest.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 25/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import RealmSwift
import SwiftyJSON

/// Contains basic fields for help request
class HelpRequest: Object {
  
  dynamic var id = 0
  dynamic var subject = ""
  dynamic var cource = ""
  dynamic var school = ""
  dynamic var faculty = ""
  dynamic var helpDescription = ""
  dynamic var deadline: NSDate?
  dynamic var _status = HelpRequestStatus.InReview.rawValue
  dynamic var email = ""
  dynamic var duration = 0 // in minutes
  dynamic var activityType = ""
  dynamic var _type = HelpType.Normal.rawValue
  dynamic var price = 0
  let messages = List<Message>()
  
  var type: HelpType {
    get {
      return HelpType(rawValue: _type)!
    }
    set(newType) {
      self._type = newType.rawValue
    }
  }
  var status: HelpRequestStatus {
    get {
      return HelpRequestStatus(rawValue: _status)!
    }
    set(newStatus) {
      self._status = newStatus.rawValue
    }
  }
  
  func presenter() -> HelpRequestPresentable {
    return HelpRequestPresenter(helpRequest: self)
  }
  
  static func createFromJSON(json: JSON) -> HelpRequest? {
    guard let id = json["id"].int,
        subject = json["course"].string,
        cource = json["grade"].int,
        type = json["category"].string,
        university = json["university"].string,
        faculty = json["faculty"].string,
        email = json["email"].string,
        deadlineDateString = json["due_by"].string
    else {
      return nil
    }
    
    let helpRequest = HelpRequest()
    helpRequest.id = id
    helpRequest.subject = subject
    helpRequest.cource = "\(cource)"
    helpRequest._type = type
    helpRequest.school = university
    helpRequest.faculty = faculty
    helpRequest.email = email
    helpRequest.deadline = NSDate(dateString: deadlineDateString)
    
    do {
      let realm = try Realm()
      try realm.write {
        realm.add(helpRequest, update: true)
      }
    } catch let error {
      print("Error: \(error)")
      return nil
    }
    
    return helpRequest
  }

  override class func primaryKey() -> String? {
    return "id"
  }
}

