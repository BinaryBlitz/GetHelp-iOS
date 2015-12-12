//
//  FolatLabelCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 30/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import Eureka

public class FloatLabelCell<T where T: Equatable, T: InputTypeInitiable>: Cell<T>, UITextFieldDelegate, TextFieldCell {
        
    public var textField : UITextField { return floatLabelTextField }

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    lazy public var floatLabelTextField: FloatLabelTextField = { [unowned self] in
        let floatTextField = FloatLabelTextField()
        floatTextField.translatesAutoresizingMaskIntoConstraints = false
        floatTextField.font = .preferredFontForTextStyle(UIFontTextStyleBody)
        floatTextField.titleFont = .boldSystemFontOfSize(11.0)
        floatTextField.clearButtonMode = .WhileEditing
        return floatTextField
        }()
    
    
    public override func setup() {
        super.setup()
        height = { 55 }
        selectionStyle = .None
        contentView.addSubview(floatLabelTextField)
        floatLabelTextField.delegate = self
        floatLabelTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        contentView.addConstraints(layoutConstraints())
    }
    
    public override func update() {
        super.update()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        floatLabelTextField.attributedPlaceholder = NSAttributedString(string: row.title ?? "", attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        floatLabelTextField.text =  row.displayValueFor?(row.value)
        floatLabelTextField.enabled = !row.isDisabled
        floatLabelTextField.titleTextColour = .lightGrayColor()
        floatLabelTextField.alpha = row.isDisabled ? 0.6 : 1
    }
    
    public override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && floatLabelTextField.canBecomeFirstResponder()
    }
    
    public override func cellBecomeFirstResponder() -> Bool {
        return floatLabelTextField.becomeFirstResponder()
    }
    
    public override func cellResignFirstResponder() -> Bool {
        return floatLabelTextField.resignFirstResponder()
    }
    
    private func layoutConstraints() -> [NSLayoutConstraint] {
        let views = ["floatLabeledTextField": floatLabelTextField]
        let metrics = ["vMargin":8.0]
        return NSLayoutConstraint.constraintsWithVisualFormat("H:|-[floatLabeledTextField]-|", options: .AlignAllBaseline, metrics: metrics, views: views) + NSLayoutConstraint.constraintsWithVisualFormat("V:|-(vMargin)-[floatLabeledTextField]-(vMargin)-|", options: .AlignAllBaseline, metrics: metrics, views: views)
    }
    
    public func textFieldDidChange(textField : UITextField){
        guard let textValue = textField.text else {
            row.value = nil
            return
        }
        if let fieldRow = row as? FormatterConformance, let formatter = fieldRow.formatter where fieldRow.useFormatterDuringInput {
            let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<T>.alloc(1))
            let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?> = nil
            if formatter.getObjectValue(value, forString: textValue, errorDescription: errorDesc) {
                row.value = value.memory as? T
                if var selStartPos = textField.selectedTextRange?.start {
                    let oldVal = textField.text
                    textField.text = row.displayValueFor?(row.value)
                    if let f = formatter as? FormatterProtocol {
                        selStartPos = f.getNewPosition(forPosition: selStartPos, inTextInput: textField, oldValue: oldVal, newValue: textField.text)
                    }
                    textField.selectedTextRange = textField.textRangeFromPosition(selStartPos, toPosition: selStartPos)
                }
                return
            }
        }
        guard !textValue.isEmpty else {
            row.value = nil
            return
        }
        guard let newValue = T.init(string: textValue) else {
            row.updateCell()
            return
        }
        row.value = newValue
    }
    
    //MARK: TextFieldDelegate
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        formViewController()?.beginEditing(self)
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        formViewController()?.endEditing(self)
    }
}