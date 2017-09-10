//
//  RequestInfoTableViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 04/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class RequestInfoTableViewController: UITableViewController {

  var helpRequest: HelpRequest!

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(UINib(nibName: "RequestInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "infoCell")
    tableView.register(UINib(nibName: "RequestStatusTableViewCell", bundle: nil), forCellReuseIdentifier: "statusCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 200
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.row {
      case 0:
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell") as? RequestInfoTableViewCell else {
          break
        }

        cell.configure(helpRequest.presenter())

        return cell

      case 1:
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell") as? RequestStatusTableViewCell else {
          break
        }

        cell.configure(helpRequest.presenter())

        return cell

      default:
        return UITableViewCell()
    }

    return UITableViewCell()
  }
}
