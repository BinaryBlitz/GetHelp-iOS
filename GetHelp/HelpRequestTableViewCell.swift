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
  @IBOutlet weak var updateMarkerWidthConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var orderNumberLabel: UILabel!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var separatorView: UIView!
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var typeLabel: UILabel!
  @IBOutlet weak var dateTimeLabel: UILabel!
  
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var payButton: UIButton!
  
  weak var delegate: HelpRequestCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    updateMarkerImageView.image = UIImage(named: "Circle")!.imageWithRenderingMode(.AlwaysTemplate)
    updateMarkerImageView.tintColor = UIColor(r: 46, g: 170, b: 60)
    cardView.layer.borderColor = UIColor.lightGrayColor().CGColor
    cardView.layer.borderWidth = 1.4
    cardView.layer.cornerRadius = 10
    setUpButtons()
  }
  
  func configure(presenter: HelpRequestPresentable) {
    orderNumberLabel.text = presenter.id
    dateTimeLabel.text = presenter.dateTime
    statusLabel.text = presenter.status
    statusLabel.textColor = presenter.indicatorColor
    typeLabel.text = presenter.type
    nameLabel.text = presenter.name
    priceLabel.text = presenter.price
    
    setPayementSectionHidden( !presenter.isPayable())
    setUpdateMarkerHidden(presenter.isViewed)
  }
  
  private func setUpdateMarkerHidden(hidden: Bool) {
    updateMarkerImageView.hidden = hidden
    updateMarkerWidthConstraint.constant = hidden ? 0 : 15
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
