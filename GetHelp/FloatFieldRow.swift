//
//  FloatFieldRow.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 30/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import Eureka

public class FloatFieldRow<T: Any, Cell: CellType where Cell: BaseCell, Cell: TypedCellType, Cell: TextFieldCell, Cell.Value == T>: FormatteableRow<T, Cell> {


    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
