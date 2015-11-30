//
//  FloatFieldRow.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 30/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import Eureka

public class FloatFieldRow<T: Any, Cell: CellType where Cell: BaseCell, Cell: TextFieldCell, Cell.Value == T>: Row<T, Cell> {

    public var formatter: NSFormatter?
    public var useFormatterDuringInput: Bool
    
    public required init(tag: String?) {
        useFormatterDuringInput = false
        super.init(tag: tag)
        self.displayValueFor = { [unowned self] value in
            guard let v = value else {
                return nil
            }
            if let formatter = self.formatter {
                if self.cell.textField.isFirstResponder() {
                    if self.useFormatterDuringInput {
                        return formatter.editingStringForObjectValue(v as! AnyObject)
                    }
                    else {
                        return String(v)
                    }
                }
                return formatter.stringForObjectValue(v as! AnyObject)
            }
            else{
                return String(v)
            }
        }
    }
}
