//
//  Image.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 06/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import RealmSwift
import DKImagePickerController

class Image: Object {
//  var owner: Message?
  dynamic var link: String? = nil
  dynamic var assets: [DKAsset] = []
//  dynamic var imageData: NSData?

  override static func ignoredProperties() -> [String] {
    return ["assets"]
  }
}
