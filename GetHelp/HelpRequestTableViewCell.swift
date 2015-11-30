//
//  HelpRequestTableViewCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 22/11/15.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

protocol RequestPresenter {
  var type: String  { get }
  var name: String { get }
}

protocol HelpReqestStatusPresenter {
  var status: String { get }
  var indicatorColor: UIColor { get }
}

protocol DatePresenter {
  var date: String { get }
  var time: String { get }
}

typealias HelpRequestPresenter = protocol<RequestPresenter, DatePresenter, HelpReqestStatusPresenter>

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
  
  func configure(presenter: HelpRequestPresenter) {
    indicatorImageView.tintColor = presenter.indicatorColor
    timeLabel.text = presenter.time
    dateLabel.text = presenter.date
    typeLabel.text = presenter.type
    nameLabel.text = presenter.name
  }
}
