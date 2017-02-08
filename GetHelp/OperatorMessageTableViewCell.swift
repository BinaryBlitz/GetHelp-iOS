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
  @IBOutlet weak var indicatorView: UIView!

  override func awakeFromNib() {
    super.awakeFromNib()

    cardView.layer.cornerRadius = 10
    cardView.layer.borderWidth = 2
    cardView.layer.borderColor = UIColor(white: 0.93, alpha: 1).CGColor
    cardView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
  }

  func configure(presenter: MessagePresentable) {
    dateLabel.text = presenter.dateTime
    contentLabel.text = presenter.content
  }
}
