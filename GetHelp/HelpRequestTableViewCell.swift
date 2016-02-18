//
//  HelpRequestTableViewCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 22/11/15.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

protocol HelpRequestCellDelegate: class {
  func didTouchPayButtonInCell(cell: HelpRequestTableViewCell)
}

class HelpRequestTableViewCell: UITableViewCell {

  @IBOutlet weak var cardView: UIView!
  @IBOutlet weak var updateMarkerImageView: UIImageView!
  
  @IBOutlet weak var orderNumberLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var separatorView: UIView!
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var typeLabel: UILabel!
  @IBOutlet weak var dateTimeLabel: UILabel!
  
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var payButton: UIButton!
  
  weak var delegate: HelpRequestCellDelegate?
  var timer: NSTimer?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    updateMarkerImageView.image = UIImage(named: "Message")!.imageWithRenderingMode(.AlwaysTemplate)
    updateMarkerImageView.tintColor = UIColor.lightGrayColor()
    cardView.layer.borderColor = UIColor.lightGrayColor().CGColor
    cardView.layer.borderWidth = 1.4
    cardView.layer.cornerRadius = 10
    setUpButtons()
  }
  
  deinit {
    stopAnimations()
  }
  
  func configure(presenter: HelpRequestPresentable) {
    timer?.invalidate()
    orderNumberLabel.text = presenter.id
    dateTimeLabel.text = presenter.dateTime
    statusLabel.text = presenter.status
    statusLabel.textColor = presenter.indicatorColor
    typeLabel.text = presenter.type
    nameLabel.text = presenter.name
    priceLabel.text = presenter.price
    
    setPayementSectionHidden( !presenter.isPayable())
    
    if presenter.isViewed {
      updateMarkerImageView.tintColor = UIColor.lightGrayColor()
    } else {
      updateMarkerImageView.tintColor = UIColor.newMessageIndicatorColor()
      setUpAnimationTimer()
    }
  }
  
  func stopAnimations() {
    timer?.invalidate()
  }
  
  private func setUpAnimationTimer() {
    timer = NSTimer.scheduledTimerWithTimeInterval(
      5,
      target: self,
      selector: "fireAnimation:",
      userInfo: nil,
      repeats: true
    )
    timer?.fire()
  }
  
  func fireAnimation(sender: AnyObject) {
    updateMarkerImageView.shakeWithDuration(0.065)
  }
  
  private func setPayementSectionHidden(hidden: Bool) {
    if hidden { priceLabel.text = nil }
    priceLabel.hidden = hidden
    payButton.hidden = hidden
  }
  
  private func setUpButtons() {
    payButton.layer.cornerRadius = (payButton.frame.height / 2) - 1
    payButton.backgroundColor = UIColor.yellowAccentColor()
  }
  
  @IBAction func payButtonAction(sender: AnyObject) {
    delegate?.didTouchPayButtonInCell(self)
  }
}
