//
//  HelpRequestTableViewCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 22/11/15.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class HelpRequestTableViewCell: UITableViewCell {

  @IBOutlet weak var indicatorViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var indicatorImageView: UIImageView!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var typeLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  var helpStatus: HelpRequestStatus?
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    indicatorImageView.image  = indicatorImageView?.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
  }
  
  func configure(presenter: HelpRequestPresentable) {
    indicatorImageView.tintColor = presenter.indicatorColor
    timeLabel.text = presenter.time
    dateLabel.text = presenter.date
    typeLabel.text = presenter.type
    nameLabel.text = presenter.name
  }
}
