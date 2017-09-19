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
  var url: URL? {
    guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
      return nil
    }

    return URL(string: encodedURLString)
  }
}

class InfoTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var signOutButton: GoButton!

  let infoData = [
    InfoLink(name: "Пользовательское соглашение", urlString: "http://getthelp.ru/docs/Пользовательское соглашение.docx"),
    InfoLink(name: "Политика конфиденциальности", urlString: "http://getthelp.ru/docs/Политика конфиденциальности.docx"),
    InfoLink(name: "Как это работает?", urlString: "http://getthelp.ru/docs/FAQ.docx")
  ]

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationController?.navigationBar.barStyle = .blackTranslucent
    tableView.tableFooterView = UIView()
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return section == 0 ? 0 : 30
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = UIColor.clear
    return view
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return infoData.count
    case 1:
      return 1
    default:
      return 0
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell") else {
        return UITableViewCell()
      }

      cell.textLabel?.text = infoData[indexPath.row].name

      return cell
    case 1:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell") else {
        return UITableViewCell()
      }
      cell.textLabel?.text = "Написать нам"

      return cell
    default:
      return UITableViewCell()
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    defer { tableView.deselectRow(at: indexPath, animated: true) }

    switch indexPath.section {
    case 0:
      guard let url = infoData[indexPath.row].url else {
        return
      }

      presentWebViewControllerWith(url, entersReaderIfAvailable: true)
    case 1:
      let supportEmail = "zakaz@gethelp24.ru"
      guard MFMailComposeViewController.canSendMail() else {
        let mailURL = URL(string: "mailto:\(supportEmail)")
        if let url = mailURL {
          UIApplication.shared.openURL(url)
        }
        return
      }

      let mailViewController = MFMailComposeViewController()
      mailViewController.setSubject("Getthelp")
      mailViewController.setToRecipients([supportEmail])
      mailViewController.mailComposeDelegate = self
      present(mailViewController, animated: true, completion: nil)
    default:
      break
    }
  }

  fileprivate func logoutActionHandler(_ alertAction: UIAlertAction?) {
    ServerManager.sharedInstance.deviceToken = ""
    UserDefaultsHelper.save(false, forKey: UserDefaultsKey.DeviceTokenUploadStatus)

    let activityIndicator = createActivityIndicator()
    navigationController?.navigationBar.addSubview(activityIndicator)
    view.bringSubview(toFront: activityIndicator)

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

  fileprivate func createActivityIndicator() -> UIActivityIndicatorView {
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    indicator.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
    indicator.layer.cornerRadius = 3
    indicator.backgroundColor = UIColor.orangeSecondaryColor()
    indicator.center = view.center

    return indicator
  }

  @IBAction func signOutButtonAction(_ sender: Any) {
    let alert = UIAlertController(title: nil, message: "Вы уверены, что хотите выйти?", preferredStyle: .alert)

    alert.addAction(UIAlertAction(title: "Отмена", style:.default, handler: nil))
    let logoutAction = UIAlertAction(title: "Выйти", style: UIAlertActionStyle.destructive, handler: logoutActionHandler)
    alert.addAction(logoutAction)

    present(alert, animated: true, completion: nil)
  }

}

extension InfoTableViewController: MFMailComposeViewControllerDelegate {
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    dismiss(animated: true, completion: nil)
  }
}
