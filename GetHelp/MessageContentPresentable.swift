//
//  MessageContentPresentable.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 06/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

protocol MessageContentPresentable {
  var content: String? { get }
  var color: UIColor? { get }
  var imageURL: URL? { get }
  var imageThumbURL: URL? { get }
}
