//
//  WalletTableViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 02/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import RealmSwift

class WalletTableViewController: UITableViewController {

  fileprivate let kWalletInfoCellIdentifier = "walletInfoCell"
  fileprivate let kRequestBillCellIdentifire = "requestBillCell"
  fileprivate let kNoDataMessageCellIdentifire = "noDataMessageCell"

  var activeRequests: Results<HelpRequest>? = nil
  var completedRequests:  Results<HelpRequest>? = nil //TODO: Create type for bills

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationController?.navigationBar.barStyle = .blackTranslucent

    fetchHelpRequests()
    setUpRefreshControl()
    setUpTableView()
  }

  //MARK: - Tools

  func fetchHelpRequests(_ serverManager: ServerManager = ServerManager()) {
    let realm  = try! Realm()
    activeRequests = realm.objects(HelpRequest.self).filter("_status == '\(HelpRequestStatus.WaitingForPayment.rawValue)'")
  }

  func setUpRefreshControl() {
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
  }

  func setUpTableView() {
    let walletInfoNib = UINib(nibName: "WalletInfoTableViewCell", bundle: nil)
    tableView.register(walletInfoNib, forCellReuseIdentifier: kWalletInfoCellIdentifier)

    let billCellNib = UINib(nibName: "BillTableViewCell", bundle: nil)
    tableView.register(billCellNib, forCellReuseIdentifier: kRequestBillCellIdentifire)

    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 370
  }

  //MARK: - Refresh

  func refresh(_ sender: AnyObject) {
    beginRefreshWithCompletion { () -> Void in
      self.tableView.reloadData()
      self.refreshControl?.endRefreshing()
    }
  }

  func beginRefreshWithCompletion(_ completion: @escaping () -> Void) {
    //TODO: Reresh request
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
      completion()
    }
  }

  //MARK: - UITableViewDataSource

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 1
    case 1:
      return activeRequests?.count ?? 0
    case 2:
      return completedRequests?.count ?? 0
    case 3:
      return 1
    default:
      return 0
    }
  }

  override func tableView(_ tableView: UITableView,
      cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    switch indexPath.section {
    case 0:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: kWalletInfoCellIdentifier) else {
        return UITableViewCell()
      }

      return cell
    case 1:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: kRequestBillCellIdentifire) as? BillTableViewCell else {
        return UITableViewCell()
      }

      let request = activeRequests?[indexPath.row]
      //TODO: fix wtf with presenter
      let presenter = request?.presenter()
      cell.titleLabel.text = presenter?.name
      cell.detailsLabel.text = "\(request?.sum ?? 0)\(rubleSign)"

      return cell
    case 3:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: kNoDataMessageCellIdentifire) else {
        return UITableViewCell()
      }

      return cell
    default:
      return UITableViewCell()
    }
  }

  //MARK: - UITableViewDelegate

  override func numberOfSections(in tableView: UITableView) -> Int {
    let contentRowsCount = (activeRequests?.count ?? 0) + (completedRequests?.count ?? 0)
    return contentRowsCount == 0 ? 4 : 3
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }

  // Magic number 0.01 actually means 0 height for wierd UITableView. lol
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    switch section {
    case 0:
      return 0.01
    case 1 where (activeRequests?.count ?? 0) == 0:
      return 0.01
    case 2:
      return 0.01
    default:
      return super.tableView(tableView, heightForHeaderInSection: section)
    }
  }

  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if section == 0 {
      return 15
    }
    return 0.01
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 1:
      let requestsCount = activeRequests?.count ?? 0
      return requestsCount != 0 ? "Активные заказы" : nil
    case 2:
//      return "Завершенные заказы"
      return nil
    default:
      return nil
    }
  }
}
