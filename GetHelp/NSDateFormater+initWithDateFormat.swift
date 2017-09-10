//
//  NSDateFormater+initWithDateFormat.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 06/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

extension DateFormatter {
  convenience init(dateFormat: String) {
    self.init()
    self.dateFormat = dateFormat
  }
}
