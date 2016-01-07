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
import Alamofire

class RequestFormViewController: FormViewController {

  var type: HelpType = HelpType.Normal
  
  var createdRequest: Request?

  override func viewDidLoad() {
    super.viewDidLoad()

    initialiseForm()
  }
  
  override func viewWillDisappear(animated: Bool) {
    if let request = createdRequest {
      request.cancel()
    }
  }

  //MARK: - Form

  func initialiseForm() {

    rowsSetup()

    //MARK: - Section 1 (date and time)

    switch type {
    case .Normal:
      form +++= DateTimeInlineRow("dueDateRow") {
        $0.title = "Дата и время сдачи"
        $0.value = NSDate().dateByAddingTimeInterval(60 * 60 * 24 * 3)
      }
    case .Express:
      form +++= DateTimeInlineRow("startDateRow") {
        $0.title = "Началo работы"
        $0.value = NSDate().dateByAddingTimeInterval(60 * 60 * 24 * 3)
      }
      <<< DateTimeInlineRow("endDateRow") {
        $0.title = "Конец работы"
        $0.value = NSDate().dateByAddingTimeInterval(60 * 60 * 24 * 3 + 60 * 2)
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
    <<< TextFloatLabelRow("schoolRow") {
      $0.title = "Вуз"
    }
    <<< TextFloatLabelRow("facilityRow") {
      $0.title = "Факультет"
    }
    <<< PushRow<String>("courseRow") {
      $0.title = "Курс"
      $0.options = ["1", "2", "3", "4", "5", "6"]
      $0.value = "1"
      $0.selectorTitle = "Ваш курс"
    }

    //MARK: - Section 4 (description)

    if type == .Normal {
      form +++= Section("Email для отправки решения") {
        $0.header
      }
      <<< TextFloatLabelRow("emailRow") {
        $0.title = "email"
      }
    }

    form +++= Section("Описание работы")
    <<< TextAreaRow("descriptionRow") {
      $0.placeholder = "Что это за работа?"
    }

    //MARK: - Section 5 (Add content)

    //TODO: Multiple photo selection. Alert with options. Create custome cell.
    form +++= ImageRow("photoRow") { row in
      row.title = "Приложить фотографии"
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
    if let request = createdRequest {
      request.cancel()
    }
    
    guard let subject = form.rowByTag("subjectRow")?.baseValue as? String else {
      print("subject!")
      presentAlertWithMessage("Вы не указали предмет")
      return
    }

    guard let school = form.rowByTag("schoolRow")?.baseValue as? String else {
      print("school!")
      presentAlertWithMessage("Вы не выбрали где вы учитесь")
      return
    }

    guard let facility = form.rowByTag("facilityRow")?.baseValue as? String else {
      print("facility")
      presentAlertWithMessage("Вы не указали ваш факультет")
      return
    }

    guard let course = form.rowByTag("courseRow")?.baseValue as? String else {
      print("course")
      presentAlertWithMessage("Вы не выбрали ваш курс")
      return
    }

    guard let helpDesctiption = form.rowByTag("descriptionRow")?.baseValue as? String else {
      print("description!")
      presentAlertWithMessage("Вы не добавили описание вашей работы")
      return
    }

    let helpRequest = HelpRequest()

    helpRequest.type = type
    helpRequest.subject = subject
    helpRequest.school = school
    helpRequest.faculty = facility
    helpRequest.course = course
    helpRequest.helpDescription = helpDesctiption
    
    if let dueDate = form.rowByTag("dueDateRow")?.baseValue as? NSDate {
      helpRequest.dueDate = dueDate
    } else if let startDate = form.rowByTag("startDateRow")?.baseValue as? NSDate,
          endDate =  form.rowByTag("endDateRow")?.baseValue as? NSDate {
      if endDate.timeIntervalSinceDate(startDate) < 0 {
        presentAlertWithMessage("Неверно указаны даты начала и конца")
        return
      }
            
      helpRequest.startDate = startDate
      helpRequest.dueDate = endDate
    }

    if type == .Express {
      if let activityType = form.rowByTag("activityTypeRow")?.baseValue as? String {
        helpRequest.activityType = activityType
      } else {
        print("activity type")
        presentAlertWithMessage("Вы не указали тип работы")
        return
      }
    } else {
      if let email = form.rowByTag("emailRow")?.baseValue as? String {
        helpRequest.email = email
      } else {
        print("email")
        presentAlertWithMessage("Вы не указали email для отправки решения")
        return
      }
    }
    
    createdRequest = ServerManager.sharedInstance.createNewHelpRequest(helpRequest) { [weak self] (success, error) -> Void in
      if success {
        self?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
      } else {
        self?.presentAlertWithMessage("Что-то не так! Попробуйте ещё раз позже")
      }
    }
  }
}
