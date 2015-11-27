//
//  ServerManagerConfiguration.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 27/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

/// Describes server manager configuration
class ServerManagerConfiguration {
  
  static let defaultConfiguration = ServerManagerConfiguration(apiToken: "foobar")
  
  var apiToken: String
  var deviceToken: String?
  
  init(apiToken: String, deviceToken: String? = nil) {
    self.apiToken = apiToken
    self.deviceToken = deviceToken
  }
}
