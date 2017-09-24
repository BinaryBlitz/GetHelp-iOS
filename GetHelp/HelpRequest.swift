//
//  HelpRequest.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 25/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import RealmSwift
import SwiftyJSON
import SwiftDate

/// Contains basic fields for help request
class HelpRequest: Object {

  dynamic var id = 0
  dynamic var subject = ""
  dynamic var course = ""
  dynamic var school = ""
  dynamic var faculty = ""
  dynamic var helpDescription = ""
  dynamic var messagesRead: Bool = false
  dynamic var lastMessageCreatedAt: Date?
  dynamic var dueDate: Date?
  dynamic var startDate: Date?
  dynamic var createdAt: Date?
  dynamic var email = ""
  dynamic var viewed: Bool = false
  dynamic var activityType = ""
  dynamic var _status = HelpRequestStatus.InReview.rawValue
  dynamic var _type = HelpType.Normal.rawValue
  dynamic var sum = 0

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

  func convertToDict() -> [String: Any] {
    // TODO: refactor date parsing
    let dateFormatter = DateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm:ssZ")

    var jsonData: [String: Any] = [
      "id": id as AnyObject,
      "course": subject as AnyObject,
      "grade": Int(course) as AnyObject ?? 1 as AnyObject,
      "category": type.rawValue as AnyObject,
      "university": school as AnyObject,
      "faculty": faculty as AnyObject,
      "email": email,
      "description": helpDescription,
      "messages_read": messagesRead
    ]

    if let dueDate = dueDate {
      jsonData["due_by"] = dateFormatter.string(from: dueDate)
    }

    if let startDate = startDate {
      jsonData["starts_at"] = dateFormatter.string(from: startDate)
    }

    return jsonData
  }

  static func createFromJSON(_ json: JSON) -> HelpRequest? {
    guard let id = json["id"].int,
        let subject = json["course"].string,
        let cource = json["grade"].int,
        let type = json["category"].string,
        let university = json["university"].string,
        let faculty = json["faculty"].string,
        let email = json["email"].string,
        let dueDateString = json["due_by"].string,
        let status = json["status"].string,
        let createdDateString = json["created_at"].string
      else {
      return nil
    }

    let helpRequest = HelpRequest()
    helpRequest.id = id
    helpRequest.subject = subject
    helpRequest.course = "\(cource)"
    helpRequest._status = status
    helpRequest._type = type
    helpRequest.school = university
    helpRequest.createdAt = DateInRegion(string: createdDateString, format: .iso8601(options: .withInternetDateTimeExtended))?.absoluteDate

    if let description = json["description"].string {
      helpRequest.helpDescription = description
    }

    if let messagesRead = json["messages_read"].bool {
      helpRequest.messagesRead = messagesRead
    }

    helpRequest.faculty = faculty
    helpRequest.email = email
    helpRequest.dueDate = DateInRegion(string: dueDateString, format: .iso8601(options: .withInternetDateTimeExtended))?.absoluteDate

    if let startDate = json["starts_at"].string {
      helpRequest.startDate = DateInRegion(string: startDate, format: .iso8601(options: .withInternetDateTimeExtended))?.absoluteDate
    }

    if let sum = json["sum"].int {
      helpRequest.sum = sum
    }

    if let viewed = json["viewed?"].bool {
      helpRequest.viewed = viewed
    }

    return helpRequest
  }

}
