//
//  OperatorMessageTableViewCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 06/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class OperatorMessageTabelViewCell: UITableViewCell, ConfigurableMessageCell {

  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var cardView: UIView!
  @IBOutlet weak var bubbleTipView: UIImageView!

  override func awakeFromNib() {
    super.awakeFromNib()

  }

  func configure(_ presenter: MessagePresentable) {
    dateLabel.text = presenter.dateTime
    contentLabel.text = presenter.content
  }
}
