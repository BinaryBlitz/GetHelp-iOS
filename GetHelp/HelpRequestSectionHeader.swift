//
//  HelpRequestSectionHeader.swift
//  GetHelp
//
//  Created by Алексей on 14.09.17.
//  Copyright © 2017 BinaryBlitz. All rights reserved.
//

import Foundation
import UIKit

class HelpRequestSectionHeader: UITableViewHeaderFooterView {
  @IBOutlet weak var typeNameLabel: UILabel!

  func configure(presenter: HelpTypePresenter) {
    typeNameLabel.text = presenter.name
  }

  func configure(text: String) {
    typeNameLabel.text = text
  }
}
