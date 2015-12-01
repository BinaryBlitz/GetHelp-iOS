//
//  RequestFormViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 30/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import Eureka

class RequestFormViewController: FormViewController {
  
  var type: HelpType = HelpType.Normal

  override func viewDidLoad() {
    super.viewDidLoad()
    
    initialiseForm()
  }
  
  //MARK: - Form
  
  func initialiseForm() {
    
    rowsSetup()
    
    //MARK: - Section 1 (date and time)
    
    switch type {
    case .Normal:
      form +++= DateTimeInlineRow("Дата и время сдачи") {
        $0.title = $0.tag
        $0.value = NSDate().dateByAddingTimeInterval(60 * 60 * 24 * 3)
      }
    case .Express:
      form +++= DateTimeInlineRow("Начало работы") {
        $0.title = $0.tag
        $0.value = NSDate().dateByAddingTimeInterval(60 * 60 * 24 * 3)
      }
      <<< TimeInlineRow("Конец работы") {
        $0.title = $0.tag
        $0.value = NSDate().dateByAddingTimeInterval(60 * 60 * 3)
      }
    }
    
    //MARK: - Section 2 (subject info)
    
    switch type {
    case .Normal:
      form +++= TextFloatLabelRow() {
        $0.title = "Предмет"
      }
    case .Express:
      form +++= TextFloatLabelRow() {
        $0.title = "Предмет"
      }
      <<< TextFloatLabelRow() {
        $0.title = "Тип работы"
      }
    }
    
    //MARK: - Section 3 (university info)
    
    form +++= Section()
    <<< PushRow<String>() {
      $0.title = "Вуз"
      $0.options = ["ВШЭ", "МГУ"] //TODO: список вузов
      $0.value = "ВШЭ"
      $0.selectorTitle = "Выберите вуз"
    }
    <<< TextFloatLabelRow() {
      $0.title = "Тип работы"
    }

    //MARK: - Section 4 (Add content)
    
    form +++= ImageRow("Приложить фотографии") { row in
      row.title = "Приложить фотографии"
    }
    
    //MARK: - Section 5 (description)
    
    form +++= Section("Описание работы")
    <<< TextAreaRow() {
      $0.placeholder = "Что это за работа?"
    }
  }
  
  func rowsSetup() {
    
    DateTimeInlineRow.defaultCellSetup = { cell, _ in
      cell.tintColor = UIColor.orangeSecondaryColor()
    }
    
    TimeInlineRow.defaultCellSetup = { cell, _ in
      cell.tintColor = UIColor.orangeSecondaryColor()
    }
  }
  
  @IBAction func submitButtonAction(sender: AnyObject) {
    print("Submit!")
  }
}
