//
//  UserImageMessageTableViewCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 06/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import Kingfisher

class UserImageMessageTableViewCell: UITableViewCell, ConfigurableMessageCell {

  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var cardView: UIView!
  @IBOutlet weak var contentImageView: UIImageView!

  override func awakeFromNib() {
    super.awakeFromNib()
    contentView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
    contentImageView.clipsToBounds = true
    contentImageView.contentMode = .scaleAspectFill
  }

  func configure(_ presenter: MessagePresentable) {
    contentImageView.kf.cancelDownloadTask()
    contentImageView.image = nil
    dateLabel.text = presenter.dateTime

    if let imageURL = presenter.imageThumbURL {
      contentImageView.kf.setImage(with: imageURL)
    }
  }
}
