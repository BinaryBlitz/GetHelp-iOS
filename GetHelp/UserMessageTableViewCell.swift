//
//  UserMessageTableViewCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 06/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class UserMessageTableViewCell: UITableViewCell, ConfigurableMessageCell {

  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var cardView: UIView!

  override func awakeFromNib() {
    super.awakeFromNib()
    contentView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))

  }

  func configure(_ presenter: MessagePresentable, tableView: UITableView) {
    dateLabel.text = presenter.dateTime
    contentLabel.text = presenter.content
  }
}
