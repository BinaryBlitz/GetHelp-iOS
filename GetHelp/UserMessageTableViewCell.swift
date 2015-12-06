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
  @IBOutlet weak var indicatorView: IndicatorView!
  
  override func awakeFromNib() {
    super.awakeFromNib()

    indicatorView.type = .Right
    cardView.layer.cornerRadius = 10
  }

  func configure(presenter: MessagePresentable) {
    dateLabel.text = presenter.time
    attachmentStatusLabel.text = presenter.attachmentStatus
    contentLabel.text = presenter.content
  }
}
