//
//  HelpTypePresenter.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 30/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

struct HelpTypePresenter {
  let type: HelpType
  
  var image: UIImage? {
    switch type {
    case .Normal:
      return UIImage(named: "NormalRequest")
    case .Express:
      return UIImage(named: "ExpressRequest")
    }
  }
  
  var name: String {
    switch type {
    case .Normal:
      return "Домашнее задание"
    case .Express:
      return "Срочная помощь"
    }
  }
  
  var description: String {
    switch type {
    case .Normal:
      return "Помощь с домашними заданиями, докладами, презентациями"
    case .Express:
      return "Срочная помощь к контрольной или экзамену"
    }
  }
}
