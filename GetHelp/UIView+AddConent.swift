//
//  UIView+AddConent.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 06/01/2016.
//  Copyright © 2016 BinaryBlitz. All rights reserved.
//

import UIKit

extension UIView {

  static func addContent(_ content: UIView, toView contentView: UIView) {

    content.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(content)

    let topConstraint = NSLayoutConstraint(item: content,
      attribute: NSLayoutAttribute.top,
      relatedBy: NSLayoutRelation.equal,
      toItem: contentView,
      attribute: NSLayoutAttribute.top,
      multiplier: 1,
      constant: 0
    )

    let bottomContraint = NSLayoutConstraint(item: content,
      attribute: .bottom,
      relatedBy: .equal,
      toItem: contentView,
      attribute: .bottom,
      multiplier: 1,
      constant: 0
    )

    let trallingConstaint = NSLayoutConstraint(item: content,
      attribute: .trailing,
      relatedBy: .equal,
      toItem: contentView,
      attribute: .trailing,
      multiplier: 1,
      constant: 0
    )

    let leadingConstraint = NSLayoutConstraint(item: content,
      attribute: .leading,
      relatedBy: .equal,
      toItem: contentView,
      attribute: .leading,
      multiplier: 1,
      constant: 0
    )

    contentView.addConstraints([topConstraint, bottomContraint, leadingConstraint, trallingConstaint])
  }
}
