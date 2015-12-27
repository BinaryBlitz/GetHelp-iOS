//
//  RequestPresentable.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 03/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

protocol RequestPresentale {
  var id: String { get }
  var type: String  { get }
  var name: String { get }
  var schoolInfo: String { get }
  var email: String { get }
  var price: String  { get }
}
