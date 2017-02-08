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
    guard let encodedURLString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()) else {
      return nil
    }

    return NSURL(string: encodedURLString)
  }
}

class InfoTableViewController: UITableViewController {

  let infoData = [
    InfoLink(name: "Пользовательское соглашение", urlString: "http://getthelp.ru/docs/Пользовательское соглашение.docx"),
    InfoLink(name: "Политика конфиденциальности", urlString: "http://getthelp.ru/docs/Политика конфиденциальности.docx"),
    InfoLink(name: "Как это работает?", urlString: "http://getthelp.ru/docs/FAQ.docx")
  ]

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationController?.navigationBar.barStyle = .BlackTranslucent
    tableView.tableFooterView = UIView()
  }

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 3
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return infoData.count
    case 1, 2:
      return 1
    default:
      return 0
    }
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
        textLabel.textColor = UIColor.blackColor()
      }

      return cell
    case 2:
      guard let cell = tableView.dequeueReusableCellWithIdentifier("actionCell") else {
        return UITableViewCell()
      }

      if let textLabel = cell.viewWithTag(1) as? UILabel {
        textLabel.text = "Выйти"
        textLabel.textColor = UIColor.redColor()
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

      presentWebViewControllerWith(url, entersReaderIfAvailable: true)
    case 1:
      let supportEmail = "support@getthelp.ru"
      guard MFMailComposeViewController.canSendMail() else {
        let mailURL = NSURL(string: "mailto:\(supportEmail)")
        if let url = mailURL {
          UIApplication.sharedApplication().openURL(url)
        }
        return
      }

      let mailViewController = MFMailComposeViewController()
      mailViewController.setSubject("Getthelp")
      mailViewController.navigationBar.tintColor = UIColor.whiteColor()
      mailViewController.setToRecipients([supportEmail])
      mailViewController.mailComposeDelegate = self
      presentViewController(mailViewController, animated: true, completion: nil)
    case 2:
      let alert = UIAlertController(title: nil, message: "Вы уверены, что хотите выйти?", preferredStyle: .Alert)

      alert.addAction(UIAlertAction(title: "Отмена", style:.Default, handler: nil))
      let logoutAction = UIAlertAction(title: "Выйти", style: UIAlertActionStyle.Destructive, handler: logoutActionHandler)
      alert.addAction(logoutAction)

      presentViewController(alert, animated: true, completion: nil)
    default:
      break
    }
  }

  private func logoutActionHandler(alertAction: UIAlertAction?) {
    ServerManager.sharedInstance.deviceToken = ""
    UserDefaultsHelper.save(false, forKey: UserDefaultsKey.DeviceTokenUploadStatus)

    let activityIndicator = createActivityIndicator()
    navigationController?.navigationBar.addSubview(activityIndicator)
    view.bringSubviewToFront(activityIndicator)

    activityIndicator.startAnimating()

    ServerManager.sharedInstance.updateDeviceTokenIfNeeded { (success, error) -> Void in
      activityIndicator.stopAnimating()
      if success {
        ServerManager.sharedInstance.apiToken = nil
        UserDefaultsHelper.save(nil, forKey: .ApiToken)
        UserDefaultsHelper.save(false, forKey: UserDefaultsKey.DeviceTokenUploadStatus)
        self.tabBarController?.selectedIndex = 0
      } else {
        self.presentAlertWithTitle("Ошибка", andMessage: "Проверьте интернет соединение и попробуйте позже")
      }
    }
  }

  private func createActivityIndicator() -> UIActivityIndicatorView {
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    indicator.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
    indicator.layer.cornerRadius = 3
    indicator.backgroundColor = UIColor.orangeSecondaryColor()
    indicator.center = view.center

    return indicator
  }
}

extension InfoTableViewController: MFMailComposeViewControllerDelegate {
  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
