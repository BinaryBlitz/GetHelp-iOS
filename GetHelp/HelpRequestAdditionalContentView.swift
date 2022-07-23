//
//  HelpRequestAdditionalContentView.swift
//  GetHelp
//
//  Created by Алексей on 17.09.17.
//  Copyright © 2017 BinaryBlitz. All rights reserved.
//

import Foundation
import UIKit

class HelpRequestAdditionalContentView: UIView {
  @IBOutlet weak var emailLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var schoolLabel: UILabel!
  @IBOutlet weak var facultyLabel: UILabel!
  @IBOutlet weak var courseLabel: UILabel!

  func configure(_ presenter: HelpRequestPresentable) {
    emailLabel.text = presenter.email
    descriptionLabel.text = presenter.requestDescription
    schoolLabel.text = presenter.school
    facultyLabel.text = presenter.faculty
    courseLabel.text = presenter.course
  }
}
