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
  dynamic var course = ""
  dynamic var school = ""
  dynamic var faculty = ""
  dynamic var helpDescription = ""
  dynamic var dueDate: NSDate?
  dynamic var startDate: NSDate?
  dynamic var email = ""
  dynamic var activityType = ""
  dynamic var _status = HelpRequestStatus.InReview.rawValue
  dynamic var _type = HelpType.Normal.rawValue
  dynamic var price = 0
  let messages = List<Message>()

  override class func primaryKey() -> String? {
    return "id"
  }
  
  //MARK: - Properties
  
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
  
  //MARK: - Presentes stuff
  
  func presenter() -> HelpRequestPresentable {
    return HelpRequestPresenter(helpRequest: self)
  }
}

//MARK: - ServerModelPresentable

extension HelpRequest: ServerModelPresentable {
  
  func convertToDict() -> [String: AnyObject] {
    let dateFormatter = NSDateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    var jsonData: [String: AnyObject] = [
      "id": id,
      "course": subject,
      "grade": Int(course) ?? 1,
      "category": type.rawValue,
      "university": school,
      "faculty": faculty,
      "email": email,
      "description": helpDescription
    ]
    
    if let dueDate = dueDate {
      jsonData["due_by"] = dateFormatter.stringFromDate(dueDate)
    }
    
    if let startDate = startDate {
      jsonData["starts_at"] = dateFormatter.stringFromDate(startDate)
    }
    
    return jsonData
  }
  
  static func createFromJSON(json: JSON) -> HelpRequest? {
    guard let id = json["id"].int,
        subject = json["course"].string,
        cource = json["grade"].int,
        type = json["category"].string,
        university = json["university"].string,
        faculty = json["faculty"].string,
        email = json["email"].string,
        dueDateString = json["due_by"].string,
        description = json["description"].string
    else {
      return nil
    }
    
    let helpRequest = HelpRequest()
    helpRequest.id = id
    helpRequest.subject = subject
    helpRequest.course = "\(cource)"
    helpRequest._type = type
    helpRequest.school = university
    helpRequest.helpDescription = description
    helpRequest.faculty = faculty
    helpRequest.email = email
    helpRequest.dueDate = NSDate(dateString: dueDateString)
    if let startDate = json["starts_at"].string {
      helpRequest.startDate = NSDate(dateString: startDate)
    }
    
    return helpRequest
  }
}

