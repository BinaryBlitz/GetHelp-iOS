//
//  RequestFormViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 30/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift

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
      form +++= DateTimeInlineRow("dateTimeRow") {
        $0.title = "Дата и время сдачи"
        $0.value = NSDate().dateByAddingTimeInterval(60 * 60 * 24 * 3)
      }
    case .Express:
      form +++= DateTimeInlineRow("dateTimeRow") {
        $0.title = "Дата и время сдачи"
        $0.value = NSDate().dateByAddingTimeInterval(60 * 60 * 24 * 3)
      }
      <<< TimeInlineRow("timeRow") {
        $0.title = "Конец работы"
        $0.value = NSDate().dateByAddingTimeInterval(60 * 60 * 3)
      }
    }
    
    //MARK: - Section 2 (subject info)
    
    switch type {
    case .Normal:
      form +++= TextFloatLabelRow("subjectRow") {
        $0.title = "Предмет"
      }
    case .Express:
      form +++= TextFloatLabelRow("subjectRow") {
        $0.title = "Предмет"
      }
      <<< TextFloatLabelRow("activityTypeRow") {
        $0.title = "Тип работы"
      }
    }
    
    //MARK: - Section 3 (university info)
    
    form +++= Section()
    <<< PushRow<String>("schoolRow") {
      $0.title = "Вуз"
      $0.options = ["ВШЭ", "МГУ"] //TODO: список вузов
      $0.value = "ВШЭ"
      $0.selectorTitle = "Выберите вуз"
    }
    <<< TextFloatLabelRow("facilityRow") {
      $0.title = "Факультет"
    }

    //MARK: - Section 4 (Add content)
    
    //TODO: Multiple photo selection. Alert with options. Create custome cell.
    form +++= ImageRow("photoRow") { row in
      row.title = "Приложить фотографии"
    }
    
    //MARK: - Section 5 (description)
    
    form +++= Section("Описание работы")
    <<< TextAreaRow("desctiptionRow") {
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
    guard let subject = form.rowByTag("subjectRow")?.baseValue as? String else {
      return
    }
    
    let helpRequest = HelpRequest()
    
    helpRequest.type = type.rawValue
    helpRequest.subject = subject
    
    let realm = try! Realm()
    do {
      try realm.write {
        realm.add(helpRequest)
      }
      presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    } catch {
      //Something is really wrong. 
      //TODO: Alert about error
    }
  }
}
