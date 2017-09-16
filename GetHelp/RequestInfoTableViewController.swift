//
//  RequestInfoTableViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 04/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

class RequestInfoTableViewController: UITableViewController {

  var cell: HelpRequestTableViewCell!

  var helpRequest: HelpRequest!

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.backgroundColor = UIColor.white
    tableView.separatorStyle = .none

    let cellNib = UINib(nibName: "HelpRequestTableViewCell", bundle: nil)
    cell = cellNib.instantiate(withOwner: nil, options: nil)[0] as! HelpRequestTableViewCell
    cell.isExpanded = true
    cell.configure(HelpRequestPresenter(helpRequest: helpRequest))
    tableView.register(HelpRequestTableViewCell.self, forCellReuseIdentifier: "HelpRequestTableViewCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 200

    let sectionHeaderNib = UINib(nibName: "HelpRequestSectionHeader", bundle: nil)
    tableView.register(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: "helpRequestHeader")
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return cell
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "helpRequestHeader") as! HelpRequestSectionHeader
    header.configure(presenter: HelpTypePresenter(type: helpRequest.type))
    return header
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 60
  }
}
