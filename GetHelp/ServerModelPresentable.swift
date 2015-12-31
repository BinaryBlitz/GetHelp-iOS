//
//  ServerModelPresentable.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 31/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import SwiftyJSON

protocol ServerModelPresentable {
  typealias ObjectType
  static func createFromJSON(json: JSON) -> ObjectType?
  func convertToDict() -> [String: AnyObject]
}
