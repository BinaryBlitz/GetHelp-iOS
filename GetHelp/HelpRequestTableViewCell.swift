//
//  HelpRequestTableViewCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 22/11/15.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

protocol HelpRequestCellDelegate: class {
  func didTouchPayButtonInCell(_ cell: HelpRequestTableViewCell)
}

class HelpRequestTableViewCell: UITableViewCell {

  @IBOutlet weak var cardView: UIView!

  @IBOutlet weak var orderNumberLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var dateTimeLabel: UILabel!

  @IBOutlet weak var filesCountLabel: UILabel!
  @IBOutlet weak var messagesCountLabel: UILabel!

  @IBOutlet weak var statusImageView: UIImageView!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var payButton: UIButton!
  @IBOutlet weak var indicatorNewMessageView: UIView!
  @IBOutlet var filesCountViews: [UIView]!

  @IBOutlet var messageCountViews: [UIView]!

  weak var delegate: HelpRequestCellDelegate?
  var timer: Timer?

  override func awakeFromNib() {
    super.awakeFromNib()

  }

  deinit {
    stopAnimations()
  }

  func configure(_ presenter: HelpRequestPresentable) {
    timer?.invalidate()

    cardView.backgroundColor = presenter.typeColor
    orderNumberLabel.text = presenter.id
    dateTimeLabel.text = presenter.date
    statusLabel.text = presenter.status
    nameLabel.text = presenter.name
    statusImageView.image = presenter.statusImage
    priceLabel.text = presenter.price
    messagesCountLabel.text = presenter.commentsCount
    filesCountLabel.text = presenter.filesCount
    statusImageView.image = presenter.statusImage
    messageCountViews.forEach { $0.isHidden = !presenter.commentSectionVisible }
    filesCountViews.forEach { $0.isHidden = !presenter.filesSectionVisible }
    setPayementSectionHidden( !presenter.isPayable())

    if presenter.isViewed {
      indicatorNewMessageView.tintColor = UIColor.clear
    } else {
      indicatorNewMessageView.tintColor = UIColor.red
      setUpAnimationTimer()
    }
  }

  func stopAnimations() {
    timer?.invalidate()
  }

  fileprivate func setUpAnimationTimer() {
    timer = Timer.scheduledTimer(
      timeInterval: 2,
      target: self,
      selector: #selector(fireAnimation(_:)),
      userInfo: nil,
      repeats: true
    )
    timer?.fire()
  }

  func fireAnimation(_ sender: AnyObject) {
    statusImageView.shakeWithDuration(0.065)
  }

  fileprivate func setPayementSectionHidden(_ hidden: Bool) {
    if hidden { priceLabel.text = nil }
    priceLabel.isHidden = hidden
    payButton.isHidden = hidden
  }

  @IBAction func payButtonAction(_ sender: AnyObject) {
    delegate?.didTouchPayButtonInCell(self)
  }
}
