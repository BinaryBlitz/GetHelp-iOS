//
//  WalletInfoTableViewCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 12/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class WalletInfoTableViewCell: UITableViewCell {

  @IBOutlet weak var walletBalanceLabel: UILabel!
  @IBOutlet weak var addFundsButton: UIButton!

  override func awakeFromNib() {
    super.awakeFromNib()

    layer.borderWidth = 0.5
    layer.borderColor = UIColor.orangeSecondaryColor().CGColor
    addFundsButton.tintColor = UIColor.orangeSecondaryColor()
  }

  private func updateWalletBalance(balance: Int) {
    let numberFormatter = NSNumberFormatter()
    numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
    let formattedNumber = numberFormatter.stringFromNumber(NSNumber(long:  balance)) ?? ""
    walletBalanceLabel.text = formattedNumber + "\(rubleSign)"
  }

  func configure(presenter: WalletInfoPresentable) {
    updateWalletBalance(presenter.balance)
  }

  //MARK: - IBActions

  @IBAction func addFundsAction(sender: AnyObject) {
    print("Yo! Add funds action!")
  }
}
