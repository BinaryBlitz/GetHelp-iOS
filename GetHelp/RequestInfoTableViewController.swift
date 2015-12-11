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
    
    tableView.registerNib(UINib(nibName: "RequestInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "infoCell")
    tableView.registerNib(UINib(nibName: "RequestStatusTableViewCell", bundle: nil), forCellReuseIdentifier: "statusCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 200
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch indexPath.row {
      case 0:
        guard let cell = tableView.dequeueReusableCellWithIdentifier("infoCell") as? RequestInfoTableViewCell else {
          break
        }

        cell.configure(helpRequest.presenter())

        return cell

      case 1:
        guard let cell = tableView.dequeueReusableCellWithIdentifier("statusCell") as? RequestStatusTableViewCell else {
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
