//
//  StatusPresentable.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 03/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

protocol StatusPresentable {
  var status: String { get }
  var statusImage: UIImage { get }
  func isPayable() -> Bool
}
