//
//  UserMessageTableViewCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 06/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class UserMessageTableViewCell: UITableViewCell, ConfigurableMessageCell {

  @IBOutlet weak var attachmentStatusLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var cardView: UIView!
  @IBOutlet weak var indicatorView: UIView!
  
  override func awakeFromNib() {
    super.awakeFromNib()

    cardView.layer.cornerRadius = 10
    cardView.layer.borderWidth = 2
    cardView.layer.borderColor = UIColor(white: 0.86, alpha: 1).CGColor
  }

  func configure(presenter: MessagePresentable) {
    dateLabel.text = presenter.time
    attachmentStatusLabel.text = presenter.attachmentStatus
    contentLabel.text = presenter.content
  }
}
