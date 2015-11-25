//
//  HelpRequest.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 25/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import RealmSwift

class HelpRequest: Object {
  
  dynamic var id = ""
  dynamic var subject = ""
  dynamic var cource = ""
  dynamic var school = ""
  dynamic var faculty = ""
  dynamic var helpDescription = ""
  dynamic var deadline: NSDate?

  override class func primaryKey() -> String? {
    return "id"
  }
}
