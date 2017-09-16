//
//  FolatLabelCell.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 30/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import Eureka


open class _FloatLabelCell<T>: Cell<T>, UITextFieldDelegate, TextFieldCell where T: Equatable, T: InputTypeInitiable {

  public var textField: UITextField! { return floatLabelTextField }

  required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  lazy public var floatLabelTextField: FloatLabelTextField = { [unowned self] in
    let floatTextField = FloatLabelTextField()
    floatTextField.translatesAutoresizingMaskIntoConstraints = false
    floatTextField.font = .preferredFont(forTextStyle: .body)
    floatTextField.titleFont = .boldSystemFont(ofSize: 11.0)
    floatTextField.clearButtonMode = .whileEditing
    return floatTextField
    }()


  open override func setup() {
    super.setup()
    height = { 55 }
    selectionStyle = .none
    contentView.addSubview(floatLabelTextField)
    floatLabelTextField.delegate = self
    floatLabelTextField.addTarget(self, action: #selector(_FloatLabelCell.textFieldDidChange(_:)), for: .editingChanged)
    contentView.addConstraints(layoutConstraints())
  }

  open override func update() {
    super.update()

    textLabel?.text = nil
    detailTextLabel?.text = nil
    floatLabelTextField.attributedPlaceholder = NSAttributedString(string: row.title ?? "", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
    floatLabelTextField.text =  row.displayValueFor?(row.value)
    floatLabelTextField.isEnabled = !row.isDisabled
    floatLabelTextField.titleTextColour = .lightGray
    floatLabelTextField.alpha = row.isDisabled ? 0.6 : 1
  }

  open override func cellCanBecomeFirstResponder() -> Bool {
    return !row.isDisabled && floatLabelTextField.canBecomeFirstResponder
  }

  open override func cellBecomeFirstResponder(withDirection direction: Direction) -> Bool {
    return floatLabelTextField.becomeFirstResponder()
  }

  open override func cellResignFirstResponder() -> Bool {
    return floatLabelTextField.resignFirstResponder()
  }

  private func layoutConstraints() -> [NSLayoutConstraint] {
    layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    let views = ["floatLabeledTextField": floatLabelTextField]
    let metrics = ["vMargin":8.0]
    return NSLayoutConstraint.constraints(withVisualFormat: "H:|-[floatLabeledTextField]-|", options: .alignAllLastBaseline, metrics: metrics, views: views) + NSLayoutConstraint.constraints(withVisualFormat: "V:|-(vMargin)-[floatLabeledTextField]-(vMargin)-|", options: .alignAllLastBaseline, metrics: metrics, views: views)
  }

  open func textFieldDidChange(_ textField: UITextField) {
    guard let textValue = textField.text else {
      row.value = nil
      return
    }
    guard let fieldRow = row as? FormatterConformance, let formatter = fieldRow.formatter else {
      row.value = textValue.isEmpty ? nil : (T.init(string: textValue) ?? row.value)
      return
    }
    if fieldRow.useFormatterDuringInput {
      let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<T>.allocate(capacity: 1))
      let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?>? = nil
      if formatter.getObjectValue(value, for: textValue, errorDescription: errorDesc) {
        row.value = value.pointee as? T
        guard var selStartPos = textField.selectedTextRange?.start else { return }
        let oldVal = textField.text
        textField.text = row.displayValueFor?(row.value)
        selStartPos = (formatter as? FormatterProtocol)?.getNewPosition(forPosition: selStartPos, inTextInput: textField, oldValue: oldVal, newValue: textField.text) ?? selStartPos
        textField.selectedTextRange = textField.textRange(from: selStartPos, to: selStartPos)
        return
      }
    } else {
      let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<T>.allocate(capacity: 1))
      let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?>? = nil
      if formatter.getObjectValue(value, for: textValue, errorDescription: errorDesc) {
        row.value = value.pointee as? T
      } else {
        row.value = textValue.isEmpty ? nil : (T.init(string: textValue) ?? row.value)
      }
    }
  }


  //Mark: Helpers
  private func displayValue(useFormatter: Bool) -> String? {
    guard let v = row.value else { return nil }
    if let formatter = (row as? FormatterConformance)?.formatter, useFormatter {
      return textField?.isFirstResponder == true ? formatter.editingString(for: v) : formatter.string(for: v)
    }
    return String(describing: v)
  }

  //MARK: TextFieldDelegate
  public func textFieldDidBeginEditing(_ textField: UITextField) {
    formViewController()?.beginEditing(of: self)
    if let fieldRowConformance = row as? FormatterConformance, let _ = fieldRowConformance.formatter, fieldRowConformance.useFormatterOnDidBeginEditing ?? fieldRowConformance.useFormatterDuringInput {
      textField.text = displayValue(useFormatter: true)
    } else {
      textField.text = displayValue(useFormatter: false)
    }
  }

  public func textFieldDidEndEditing(_ textField: UITextField) {
    formViewController()?.endEditing(of: self)
    formViewController()?.textInputDidEndEditing(textField, cell: self)
    textFieldDidChange(textField)
    textField.text = displayValue(useFormatter: (row as? FormatterConformance)?.formatter != nil)
  }

  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
  }

  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return formViewController()?.textInput(textField, shouldChangeCharactersInRange:range, replacementString:string, cell: self) ?? true
  }

  public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    return formViewController()?.textInputShouldBeginEditing(textField, cell: self) ?? true
  }

  public func textFieldShouldClear(_ textField: UITextField) -> Bool {
    return formViewController()?.textInputShouldClear(textField, cell: self) ?? true
  }

  public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
  }

}
