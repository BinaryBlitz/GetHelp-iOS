//
//  String+onlyDigits.swift
//  GetHelp
//
//  Created by Алексей on 11.09.17.
//  Copyright © 2017 BinaryBlitz. All rights reserved.
//

import Foundation

extension String {
  var onlyDigits: String {
    return components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
  }
}
