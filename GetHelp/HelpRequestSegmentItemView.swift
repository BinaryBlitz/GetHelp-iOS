//
//  HelpRequestSegmentItemView.swift
//  GetHelp
//
//  Created by Алексей on 17.09.17.
//  Copyright © 2017 BinaryBlitz. All rights reserved.
//

import Foundation
import UIKit

class HelpRequestSegmentItemView: UIView {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var badgeView: UIView!
  @IBOutlet weak var badgeLabel: UILabel!
  @IBOutlet weak var bottomBorderView: UIView!

  var badgeItemTapHandler: (() -> Void)? = nil

  var titleText: String? {
    get {
      return titleLabel.text
    }
    set {
      titleLabel.text = newValue
    }
  }

  var badgeText: String? {
    get {
      return badgeLabel.text
    }
    set {
      badgeLabel.text = newValue
      guard let newValue = newValue, !newValue.isEmpty else {
        badgeView.isHidden = true
        return
      }
      badgeView.isHidden = false
    }
  }

  var isSelected: Bool = true {
    didSet {
      let isSelected = self.isSelected
      UIView.animate(withDuration: 0.1) { [weak self] in
        self?.titleLabel.textColor = isSelected ? UIColor.black : UIColor.black.withAlphaComponent(0.25)
        self?.bottomBorderView.backgroundColor = isSelected ? UIColor.orangeSecondaryColor() : UIColor.clear
      }
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    isSelected = false
    badgeView.isHidden = true

    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(badgeItemTapAction)))
  }

  func badgeItemTapAction() {
    badgeItemTapHandler?()
  }

}
