//
//  OperatorMessageTableViewCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 06/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class OperatorMessageTabelViewCell: UITableViewCell, ConfigurableMessageCell {

  @IBOutlet weak var attachmentStatusLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var cardView: UIView!
  @IBOutlet weak var indicatorView: IndicatorView!
  
  override func awakeFromNib() {
    super.awakeFromNib()

    indicatorView.type = .Left
    cardView.layer.cornerRadius = 10
    cardView.layer.shadowColor = UIColor.blackColor().CGColor
    cardView.layer.shadowOpacity = 0.37
    cardView.layer.shadowRadius = 2.3
    cardView.layer.shadowOffset = CGSize()
  }

  func configure(presenter: MessagePresentable) {
    dateLabel.text = presenter.time
    attachmentStatusLabel.text = presenter.attachmentStatus
    contentLabel.text = presenter.content
  }
}
