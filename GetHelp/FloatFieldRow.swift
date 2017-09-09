//
//  FloatFieldRow.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 30/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import Eureka

open class FloatFieldRow<Cell: CellType>: FormatteableRow<Cell> where Cell: BaseCell, Cell: TypedCellType, Cell: TextFieldCell {


    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
