//
//  ExpressHelpRequest.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 25/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import RealmSwift

/// Describes help on exam and other urgent stuff
class ExpressHelpRequest: HelpRequest {

  dynamic var duration = 0 // in minutes
  dynamic var activityType = ""
}
