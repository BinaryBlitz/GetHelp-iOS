//
//  RequestTypeTableViewCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 28/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class RequestTypeTableViewCell: UITableViewCell {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var descriptionLabel: UILabel!

  func configureWith(presenter: HelpTypePresenter) {
    titleLabel.text = presenter.name
    iconImageView.image = presenter.image
    descriptionLabel.text = presenter.description
  }
}
