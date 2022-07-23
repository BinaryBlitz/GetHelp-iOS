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
    layer.borderColor = UIColor.orangeSecondaryColor().cgColor
    addFundsButton.tintColor = UIColor.black
    addFundsButton.layer.borderColor = UIColor.orange.cgColor
    addFundsButton.layer.borderWidth = 2
    addFundsButton.layer.cornerRadius = 5
  }

  fileprivate func updateWalletBalance(_ balance: Int) {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = NumberFormatter.Style.decimal
    let formattedNumber = numberFormatter.string(from: NSNumber(value: balance as Int)) ?? ""
    walletBalanceLabel.text = formattedNumber + "\(rubleSign)"
  }

  func configure(_ presenter: WalletInfoPresentable) {
    updateWalletBalance(presenter.balance)
  }

  //MARK: - IBActions

  @IBAction func addFundsAction(_ sender: AnyObject) {
    print("Yo! Add funds action!")
  }
}
