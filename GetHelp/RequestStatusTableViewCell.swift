//
//  RequestStatusTableViewCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 09/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class RequestStatusTableViewCell: UITableViewCell {

  @IBOutlet weak var statusLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()

  }

  func configure(_ presenter: StatusPresentable) {
    statusLabel.text = presenter.status
    backgroundColor = presenter.indicatorColor
  }
}
