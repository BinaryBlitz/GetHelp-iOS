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
    <<< PushRow<String>("courceRow") {
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

  func presentAlertWithMessage(message: String) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
    presentViewController(alert, animated: true, completion: nil)
  }

  @IBAction func submitButtonAction(sender: AnyObject) {
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

    guard let cource = form.rowByTag("courceRow")?.baseValue as? String else {
      print("cource")
      presentAlertWithMessage("Вы не выбрали ваш курс")
      return
    }

    guard let helpDesctiption = form.rowByTag("descriptionRow")?.baseValue as? String else {
      print("description!")
      presentAlertWithMessage("Вы не добавили описание вашей работы")
      return
    }

    guard let deadline = form.rowByTag("dateTimeRow")?.baseValue as? NSDate else {
      print("deadline")
      presentAlertWithMessage("Вы не выбрали дату работы")
      return
    }

    let helpRequest = HelpRequest()

    helpRequest.type = type
    helpRequest.subject = subject
    helpRequest.school = school
    helpRequest.faculty = facility
    helpRequest.email = "foo@bar.com"
    helpRequest.deadline = deadline
    helpRequest.cource = cource
    helpRequest.helpDescription = helpDesctiption

    if let endTime = form.rowByTag("timeRow")?.baseValue as? NSDate {
      helpRequest.duration = Int(endTime.timeIntervalSinceDate(deadline) / (60 * 60)) // in minutes
    }

    if let activityType = form.rowByTag("activityTypeRow")?.baseValue as? String
        where type == .Express {

      helpRequest.activityType = activityType
    } else {
      print("activity type")
      presentAlertWithMessage("Вы не указали тип работы")
      return
    }

    let realm = try! Realm()
    do {
      try realm.write {
        realm.add(helpRequest)
      }
      presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    } catch {
      //Something is really wrong.
      //TODO: Alert about error
      print("Something is really wrong.")
    }
  }
}
