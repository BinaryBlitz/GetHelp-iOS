//
//  ServerModelPresentable.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 31/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import SwiftyJSON

protocol ServerModelPresentable {
  associatedtype ObjectType
  static func createFromJSON(_ json: JSON) -> ObjectType?
  func convertToDict() -> [String: Any]
}
