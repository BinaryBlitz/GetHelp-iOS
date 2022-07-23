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

  fileprivate static var userDefaults: UserDefaults {
    return UserDefaults.standard
  }

  static func loadObjectForKey(_ key: UserDefaultsKey) -> Any? {
    return userDefaults.object(forKey: key.rawValue) as Any
  }

  static func save(_ object: Any?, forKey key: UserDefaultsKey) {
    userDefaults.set(object, forKey: key.rawValue)
  }
}
