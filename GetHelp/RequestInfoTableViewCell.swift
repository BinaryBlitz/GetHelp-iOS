//
//  RequestInfoTableViewCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 09/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class RequestInfoTableViewCell: UITableViewCell {

  @IBOutlet weak var subjectLabel: UILabel!
  @IBOutlet weak var helpTypeLabel: UILabel!
  @IBOutlet weak var dateTimeLabel: UILabel!
  @IBOutlet weak var schoolInfoLabel: UILabel!
  @IBOutlet weak var emailLabel: UILabel!
  @IBOutlet weak var orderIdLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  func configure(presenter: HelpRequestPresentable) {
    dateTimeLabel.text = "Дата: " + presenter.dateTime
    subjectLabel.text = presenter.name
    helpTypeLabel.text = presenter.type
    schoolInfoLabel.text = presenter.schoolInfo
    emailLabel.text = "Email: " + presenter.email
    orderIdLabel.text = presenter.id
  }
}
