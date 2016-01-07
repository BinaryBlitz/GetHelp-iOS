//
//  OperatorImageMessageTableViewCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 06/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import Haneke

class OperatorImageMessageTabelViewCell: UITableViewCell, ConfigurableMessageCell {

  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var cardView: UIView!
  @IBOutlet weak var indicatorView: UIView!
  @IBOutlet weak var contentImageView: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()

    cardView.layer.cornerRadius = 10
    cardView.layer.borderWidth = 2
    cardView.layer.borderColor = UIColor(white: 0.93, alpha: 1).CGColor
    cardView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
    
    contentImageView.clipsToBounds = true
    contentImageView.contentMode = .ScaleAspectFill
  }

  func configure(presenter: MessagePresentable) {
    contentImageView.hnk_cancelSetImage()
    contentImageView.image = nil
    dateLabel.text = presenter.time
    
    if let imageURL = presenter.imageThumbURL {
      contentImageView.hnk_setImageFromURL(imageURL)
    }
  }
}
