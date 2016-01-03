//
//  InfoTableViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 20/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import MessageUI

struct InfoLink {
  let name: String
  let urlString: String
  var url: NSURL? {
    return NSURL(string: urlString)
  }
}

class InfoTableViewController: UITableViewController {

  let infoData = [
    InfoLink(name: "Публичная оферта #1", urlString: "http://getthelp.ru/docs/%D0%9E%D1%84%D0%B5%D1%80%D1%82%D0%B0%201.docx"),
    InfoLink(name: "Публичная оферта #2", urlString: "http://getthelp.ru/docs/%D0%9E%D1%84%D0%B5%D1%80%D1%82%D0%B0%202.docx"),
    InfoLink(name: "Пользовательское соглашение", urlString: "https://google.com"),
    InfoLink(name: "Как это работает?", urlString: "https://google.com"),
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.barStyle = .BlackTranslucent
    tableView.tableFooterView = UIView()
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return infoData.count
    }
    
    return 1
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      guard let cell = tableView.dequeueReusableCellWithIdentifier("infoCell") else {
        return UITableViewCell()
      }
      
      cell.textLabel?.text = infoData[indexPath.row].name
      
      return cell
    case 1:
      guard let cell = tableView.dequeueReusableCellWithIdentifier("actionCell") else {
        return UITableViewCell()
      }
      
      if let textLabel = cell.viewWithTag(1) as? UILabel {
        textLabel.text = "Написать разработчикам"
      }
      
      return cell
    case 2:
      guard let cell = tableView.dequeueReusableCellWithIdentifier("actionCell") else {
        return UITableViewCell()
      }
      
      if let textLabel = cell.viewWithTag(1) as? UILabel {
        textLabel.text = "Выйти"
      }
      
      return cell
    default:
      return UITableViewCell()
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    defer { tableView.deselectRowAtIndexPath(indexPath, animated: true) }
    
    switch indexPath.section {
    case 0:
      guard let url = infoData[indexPath.row].url else {
        return
      }
      
      self.presentWebViewControllerWithURL(url)
    case 1:
      let mailViewController = MFMailComposeViewController()
      mailViewController.setSubject("Ошибка")
      mailViewController.navigationBar.tintColor = UIColor.whiteColor()
      mailViewController.setToRecipients(["danshevlyuk@icloud.com"])
      mailViewController.mailComposeDelegate = self
      presentViewController(mailViewController, animated: true, completion: nil)
    default:
      break
    }
  }
}

extension InfoTableViewController: MFMailComposeViewControllerDelegate {
  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
