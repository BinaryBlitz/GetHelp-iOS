//
//  HelpType.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 30/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

enum HelpType: String {
  case Normal = "homework"
  case Express = "urgent"

  var presenter: HelpTypePresenter {
    return HelpTypePresenter(type: self)
  }

  static func avaliableTypes() -> [HelpType] {
    return [.Normal, .Express]
  }
}
