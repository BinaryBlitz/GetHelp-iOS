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

  private let kWalletInfoCellIdentifier = "walletInfoCell"
  private let kRequestBillCellIdentifire = "requestBillCell"
  private let kNoDataMessageCellIdentifire = "noDataMessageCell"

  var activeRequests: Results<HelpRequest>? = nil
  var completedRequests:  Results<HelpRequest>? = nil //TODO: Create type for bills

  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.barStyle = .BlackTranslucent

    fetchHelpRequests()
    setUpRefreshControl()
    setUpTableView()
  }

  //MARK: - Tools

  func fetchHelpRequests(serverManager: ServerManager = ServerManager()) {
    let realm  = try! Realm()
    activeRequests = realm.objects(HelpRequest).filter("_status == '\(HelpRequestStatus.WaitingForPayment.rawValue)'")
  }

  func setUpRefreshControl() {
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
  }

  func setUpTableView() {
    let walletInfoNib = UINib(nibName: "WalletInfoTableViewCell", bundle: nil)
    tableView.registerNib(walletInfoNib, forCellReuseIdentifier: kWalletInfoCellIdentifier)
    
    let billCellNib = UINib(nibName: "BillTableViewCell", bundle: nil)
    tableView.registerNib(billCellNib, forCellReuseIdentifier: kRequestBillCellIdentifire)

    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 370
  }

  //MARK: - Refresh

  func refresh(sender: AnyObject) {
    beginRefreshWithComplition { () -> Void in
      self.tableView.reloadData()
      self.refreshControl?.endRefreshing()
    }
  }

  func beginRefreshWithComplition(complition: () -> Void) {
    //TODO: Reresh request
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))),
        dispatch_get_main_queue()
    ) { () -> Void in
      complition()
    }
  }

  //MARK: - UITableViewDataSource

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

  override func tableView(tableView: UITableView,
      cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
    switch indexPath.section {
    case 0:
      guard let cell = tableView.dequeueReusableCellWithIdentifier(kWalletInfoCellIdentifier) else {
        return UITableViewCell()
      }
      
      return cell
    case 1:
      guard let cell = tableView.dequeueReusableCellWithIdentifier(kRequestBillCellIdentifire) as? BillTableViewCell else {
        return UITableViewCell()
      }

      let request = activeRequests?[indexPath.row]
      //TODO: fix wtf with presenter
      let presenter = request?.presenter()
      cell.titleLabel.text = presenter?.name
      cell.detailsLabel.text = "\(request?.sum ?? 0)\(rubleSign)"

      return cell
    case 3:
      guard let cell = tableView.dequeueReusableCellWithIdentifier(kNoDataMessageCellIdentifire) else {
        return UITableViewCell()
      }
      
      return cell
    default:
      return UITableViewCell()
    }
  }

  //MARK: - UITableViewDelegate
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    let contentRowsCount = (activeRequests?.count ?? 0) + (completedRequests?.count ?? 0)
    return contentRowsCount == 0 ? 4 : 3
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  // Magic number 0.01 actually means 0 height for wierd UITableView. lol
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
  
  override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    if section == 0 {
      return 15
    }
    return 0.01
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
