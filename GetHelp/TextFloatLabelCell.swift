//
//  TextFloatLabelCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 30/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import Eureka

open class TextFloatLabelCell : _FloatLabelCell<String>, CellType {

  required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func setup() {
    super.setup()
    textField?.autocorrectionType = .default
    textField?.autocapitalizationType = .sentences
    textField?.keyboardType = .default
  }

}
