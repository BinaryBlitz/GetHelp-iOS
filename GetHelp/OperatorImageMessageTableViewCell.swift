//
//  OperatorImageMessageTableViewCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 06/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import Kingfisher

class OperatorImageMessageTabelViewCell: UITableViewCell, ConfigurableMessageCell {

  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var cardView: UIView!
  @IBOutlet weak var contentImageView: UIImageView!
  @IBOutlet weak var bubbleTipView: UIImageView!

  override func awakeFromNib() {
    super.awakeFromNib()
    contentView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
    contentImageView.clipsToBounds = true
    contentImageView.contentMode = .scaleAspectFill
    bubbleTipView.image = #imageLiteral(resourceName: "incomingBubbleTip").withRenderingMode(.alwaysTemplate)
  }

  func configure(_ presenter: MessagePresentable) {
    contentImageView.kf.cancelDownloadTask()
    contentImageView.image = nil
    dateLabel.text = presenter.dateTime

    if let imageURL = presenter.imageThumbURL {
      contentImageView.kf.setImage(with: imageURL)
    }

    cardView.backgroundColor = presenter.color ?? UIColor.tealishTwo
    bubbleTipView.tintColor = presenter.color ?? UIColor.tealishTwo
  }
}
