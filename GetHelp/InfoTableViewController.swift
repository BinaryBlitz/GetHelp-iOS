//
//  InfoTableViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 20/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import WebKit
import SafariServices
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
    InfoLink(name: "Правила пользования", urlString: "https://google.com"),
    InfoLink(name: "Пользовательское соглашение", urlString: "https://google.com")
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
        textLabel.text = "Сообщить об ошибке"
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
      
      if #available(iOS 9.0, *) {
        let safariController = SFSafariViewController(URL: url)
        presentViewController(safariController, animated: true, completion: nil)
      } else {
        UIApplication.sharedApplication().openURL(url)
      }
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
