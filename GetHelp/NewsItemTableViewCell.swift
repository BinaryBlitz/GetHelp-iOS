//
//  NewsItemTableViewCell.swift
//  GetHelp
//
//  Created by Алексей on 17.09.17.
//  Copyright © 2017 BinaryBlitz. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class NewsItemTableViewCell: UITableViewCell {
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var cardView: UIView!

  fileprivate lazy var dateFormatter = DateFormatter(dateFormat: "EE dd MMM")

  func configure(post: Post) {
    backgroundImageView.kf.setImage(with: URL(string: post.imageUrl))
    dateLabel.text = dateFormatter.string(from: post.createdAt)
    headerLabel.text = post.title
    cardView.backgroundColor = post.promo ? UIColor.orangeSecondaryColor().withAlphaComponent(0.45) : UIColor.black.withAlphaComponent(0.3)
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    backgroundImageView.kf.cancelDownloadTask()
  }

}
