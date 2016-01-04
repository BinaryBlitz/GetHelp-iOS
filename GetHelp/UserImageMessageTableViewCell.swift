//
//  UserImageMessageTableViewCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 06/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class UserImageMessageTableViewCell: UITableViewCell, ConfigurableMessageCell {

  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var cardView: UIView!
  @IBOutlet weak var indicatorView: UIView!
  @IBOutlet weak var contentImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()

    cardView.layer.cornerRadius = 10
    cardView.layer.borderWidth = 2
    cardView.layer.borderColor = UIColor(white: 0.86, alpha: 1).CGColor
  }

  func configure(presenter: MessagePresentable) {
    dateLabel.text = presenter.time
  }
}
