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

  var onRequestCreate: ((HelpRequest) -> Void)? = nil
  var onError: ((String) -> Void)? = nil

  override func viewDidLoad() {
    super.viewDidLoad()
    automaticallyAdjustsScrollViewInsets = false
    edgesForExtendedLayout = UIRectEdge()
    view.backgroundColor = UIColor.white
    tableView.backgroundColor = UIColor.white
    tableView.separatorStyle = .singleLine
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0 )
    initialiseForm()
  }

  override func viewWillDisappear(_ animated: Bool) {
    if let request = createdRequest {
      request.cancel()
    }
  }

  //MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? AttachPhotosViewController,
        let helpRequest = sender as? HelpRequest, segue.identifier == "attachPhotos" {
      destination.helpRequest = helpRequest
    }
  }

  //MARK: - Form

  func initialiseForm() {

    rowsSetup()

    form +++ Section()

    switch type {
    case .Normal:
      form.last! <<< DateTimeInlineRow("dueDateRow") {
        $0.title = "Дата и время сдачи"
        $0.value = NSDate().addingTimeInterval(60 * 60 * 24 * 3) as Date
      }
    case .Express:
      form.last! <<< DateTimeInlineRow("startDateRow") {
        $0.title = "Началo работы"
        $0.value = NSDate().addingTimeInterval(60 * 60 * 24 * 3) as Date
      }
      <<< DateTimeInlineRow("endDateRow") {
        $0.title = "Конец работы"
        $0.value = NSDate().addingTimeInterval(60 * 60 * 24 * 3 + 60 * 2) as Date
      }
    }

    //MARK: - Section 2 (subject info)

    form.last! <<<
    TextFloatLabelRow("subjectRow") {
      $0.title = "Предмет"
    }

    <<< PushRow<String>("activityTypeRow") { row in
      row.title = "Тип работы"
      row.options = [
        "Домашнее задание",
        "Тест",
        "Эссе",
        "Доклад",
        "Реферат",
        "Курсовая работа",
        "Дипломная работа",
        "Магистерская работа",
        "Научно-исследовательская работа",
        "Отчет по практике",
        "Контрольная работа",
        "Презентация",
        "Чертеж",
        "Перевод",
        "Другое"
      ]

      row.value = row.options.first!
    }

    //MARK: - Section 3 (university info)

    form.last!
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
      let emailSectionTitle = "Электронная почта для отправки решения"
      form +++ Section(emailSectionTitle) { section in
        var header = HeaderFooterView<HelpRequestSectionHeader>(.nibFile(name: "HelpRequestSectionHeader", bundle: nil))

        header.onSetupView = { view, _ in
          view.configure(text: emailSectionTitle)
        }
        section.header = header

      }

      <<< TextFloatLabelRow("emailRow") {
        $0.title = "Ваша электронная почта"
        $0.cell.textField.keyboardType = .emailAddress
      }
    }

    let descriptionSectionTitle = "Описание работы"
    form +++ Section(descriptionSectionTitle) { section in
      var header = HeaderFooterView<HelpRequestSectionHeader>(.nibFile(name: "HelpRequestSectionHeader", bundle: nil))

      header.onSetupView = { view, _ in
        view.configure(text: descriptionSectionTitle)
      }
      section.header = header

    }
    <<< TextAreaRow("descriptionRow") {
      $0.placeholder = "Что это за работа?"
      $0.cell.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
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

  func validate() {
    if let request = createdRequest {
      request.cancel()
    }

    guard let subject = form.rowBy(tag: "subjectRow")?.baseValue as? String else {
      onError?("Вы не указали предмет")
      return
    }

    guard let school = form.rowBy(tag: "schoolRow")?.baseValue as? String else {
      onError?("Вы не выбрали где вы учитесь")
      return
    }

    guard let facility = form.rowBy(tag: "facilityRow")?.baseValue as? String else {
      onError?("Вы не указали ваш факультет")
      return
    }

    guard let course = form.rowBy(tag: "courseRow")?.baseValue as? String else {
      onError?("Вы не выбрали ваш курс")
      return
    }

    guard let helpDesctiption = form.rowBy(tag: "descriptionRow")?.baseValue as? String else {
      onError?("Вы не добавили описание вашей работы")
      return
    }

    let helpRequest = HelpRequest()

    helpRequest.type = type
    helpRequest.subject = subject
    helpRequest.school = school
    helpRequest.faculty = facility
    helpRequest.course = course
    helpRequest.helpDescription = helpDesctiption

    if let dueDate = form.rowBy(tag: "dueDateRow")?.baseValue as? Date {
      helpRequest.dueDate = dueDate
    } else if let startDate = form.rowBy(tag: "startDateRow")?.baseValue as? Date,
      let endDate =  form.rowBy(tag: "endDateRow")?.baseValue as? Date {
      if endDate.timeIntervalSince(startDate) < 0 {
        onError?("Неверно указаны даты начала и конца")
        return
      }

      helpRequest.startDate = startDate
      helpRequest.dueDate = endDate
    }

    if let activityType = form.rowBy(tag: "activityTypeRow")?.baseValue as? String {
      helpRequest.activityType = activityType
    } else {
      print("activity type")
      onError?("Вы не указали тип работы")
      return
    }

    if type == .Normal {
      if let email = form.rowBy(tag: "emailRow")?.baseValue as? String {
        helpRequest.email = email
      } else {
        print("email")
        onError?("Вы не указали email для отправки решения")
        return
      }
    }

    createdRequest = ServerManager.sharedInstance.createNewHelpRequest(helpRequest) { [weak self] (helpRequest, error) -> Void in
      if let helpRequest = helpRequest {
        self?.onRequestCreate?(helpRequest)
      } else {
        self?.onError?("Что-то не так! Попробуйте ещё раз позже")
      }
    }
  }

  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.01
  }

}
