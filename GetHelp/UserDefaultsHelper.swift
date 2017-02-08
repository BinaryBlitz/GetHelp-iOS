//
//  UserDefaultsHelper.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 05/01/2016.
//  Copyright © 2016 BinaryBlitz. All rights reserved.
//

enum UserDefaultsKey: String {
  case ApiToken
  case DeviceToken
  case DeviceTokenUploadStatus
  case FirstOperatorMessageId
}

struct UserDefaultsHelper {

  private static var userDefaults: NSUserDefaults {
    return NSUserDefaults.standardUserDefaults()
  }

  static func loadObjectForKey(key: UserDefaultsKey) -> AnyObject? {
    return userDefaults.objectForKey(key.rawValue)
  }

  static func save(object: AnyObject?, forKey key: UserDefaultsKey) {
    userDefaults.setObject(object, forKey: key.rawValue)
  }
}
