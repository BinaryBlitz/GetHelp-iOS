//
//  ServerManager.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 26/11/2015.
//  Copyright (c) 2015 BinaryBlitz. All rights reserved.
//

import UIKit

/// Provides communication with the application server
class ServerManager {

  private var configuration: ServerManagerConfiguration

  init(configuration: ServerManagerConfiguration = ServerManagerConfiguration.defaultConfiguration) {
    self.configuration = configuration
  }
}
