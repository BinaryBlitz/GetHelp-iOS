//
//  HomeViewController.swift
//  GetHelp
//
// Created by Dan Shevlyuk on 22/11/15.
// Copyright (c) 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import RealmSwift

let HelpRequestUpdatedNotification = "HelpRequestUpdatedNotification"

/// Home screen with list of created requests
class HomeViewController: UIViewController {

  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var createRequestButton: UIButton!

  let refreshControl = UIRefreshControl()
  var helpRequests: Results<HelpRequest>?

  var normalRequests: [HelpRequest] {
    return helpRequests?.filter { $0.type == .Normal } ?? []
  }

  var expressRequests: [HelpRequest] {
    return helpRequests?.filter { $0.type == .Express } ?? []
  }

  //MARK: - Livecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationController?.navigationBar.barStyle = .blackTranslucent
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    configureTableView()

    fetchHelpRequests()
    tableView.reloadData()

    NotificationCenter.default
        .addObserver(self,
                     selector: #selector(refresh(_:)),
                     name: NSNotification.Name(rawValue: HelpRequestUpdatedNotification), object: nil)

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refresh(self)

    if !ServerManager.sharedInstance.authenticated {
      let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
      let loginViewController = loginStoryboard.instantiateInitialViewController()!
      present(loginViewController, animated: true, completion: nil)
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  //MARK: - Initialize

  func configureTableView() {
    let helpRequestCellNib = UINib(nibName: "HelpRequestTableViewCell", bundle: nil)
    tableView.tableFooterView = UIView()
    tableView.backgroundColor = UIColor.white
    tableView.register(helpRequestCellNib, forCellReuseIdentifier: "helpRequestCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 80
    tableView.addSubview(refreshControl)
    tableView.sendSubview(toBack: refreshControl)
    tableView.backgroundColor = UIColor.white

    let sectionHeaderNib = UINib(nibName: "HelpRequestSectionHeader", bundle: nil)
    tableView.register(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: "helpRequestHeader")
  }

  //MARK: - Refresh

  func refresh(_ sender: AnyObject) {
    beginRefreshWithCompletion {
      self.fetchHelpRequests()
      self.tableView.reloadData()
      self.refreshControl.endRefreshing()
    }
  }

  func beginRefreshWithCompletion(_ completion: @escaping () -> Void) {
    //TODO: Reresh request
    ServerManager.sharedInstance.fetchHelpRequests { success, error in
      if !success {
        print("Error in ferching request")
      }

      do {
        let realm = try Realm()
        let results = realm.objects(HelpRequest.self).filter("viewed == false")
        UIApplication.shared.applicationIconBadgeNumber = results.count
      } catch {
        return
      }

      completion()
    }
  }

  //MARK: - Tools

  func fetchHelpRequests() {
    let realm  = try! Realm()
    helpRequests = realm.objects(HelpRequest.self).sorted(byKeyPath: "createdAt", ascending: false)
  }

  //MARK: - Actions

  @IBAction func addBarButtonAction(_ sender: AnyObject) {
    performSegue(withIdentifier: "createNewRequest", sender: self)
  }

  //MARK: Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? RequestDetailsViewController,
        let indexPath = sender as? IndexPath {
      switch indexPath.section {
      case 0:
        destination.helpRequest = normalRequests[indexPath.row]
      case 1:
        destination.helpRequest = expressRequests[indexPath.row]
      default:
        break
      }
    }
  }
}

//MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "showDetails", sender: indexPath)
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

//MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    switch section {
    case 0 where normalRequests.count == 0:
      return 0
    case 1 where expressRequests.count == 0:
      return 0
    default:
      break
    }

    return 60
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "helpRequestHeader") as! HelpRequestSectionHeader
    switch section {
    case 0 where normalRequests.count != 0:
      header.configure(presenter: HelpTypePresenter(type: .Normal))
    case 1 where expressRequests.count == 0:
      header.configure(presenter: HelpTypePresenter(type: .Express))
    default:
      break
    }

    return header
  }
  

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let requests = helpRequests else {
      tableView.isHidden = true
      backgroundView.isHidden = false
      navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logoGethelpNavbar2"))
      return 0
    }

    let shouldHideTableView = requests.count == 0
    tableView.isHidden = shouldHideTableView
    backgroundView.isHidden = !shouldHideTableView
    if shouldHideTableView {
      navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logoGethelpNavbar2"))
    } else {
      navigationItem.titleView = nil
      navigationItem.title = "Мои заказы"
    }

    return section == 0 ? normalRequests.count : expressRequests.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    guard let cell = tableView.dequeueReusableCell(withIdentifier: "helpRequestCell") as? HelpRequestTableViewCell else {
      return UITableViewCell()
    }

    let request = indexPath.section == 0 ? normalRequests[indexPath.row] : expressRequests[indexPath.row]

    cell.configure(request.presenter())

    cell.delegate = self

    return cell
  }

  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let cell = cell as? HelpRequestTableViewCell else {
      return
    }

    cell.stopAnimations()
  }

}

//MARK: - HelpRequestCellDelegate

extension HomeViewController: HelpRequestCellDelegate {

  func didTouchPayButtonInCell(_ cell: HelpRequestTableViewCell) {
    struct Status {
      static var isActive: Bool = false
    }

    if Status.isActive { return }

    guard let indexPath = tableView.indexPath(for: cell) else { return }
    guard let order = helpRequests?[indexPath.row] else { return }

    Status.isActive = true
    ServerManager.sharedInstance.paymentsURLForOrderID(order.id) { paymentURL, error in
      if let url = paymentURL {
        self.presentWebViewControllerWith(url)
      } else if let error = error {
        guard let error = error as? URLError else {
          return
        }

        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
          self.presentAlertWithTitle("Ошибка", andMessage: "Нет подключения к интерету")
        case .cancelled:
          return
        default:
          self.presentAlertWithTitle("Ошбика", andMessage: "Не удалось загрузить страницу. Попробуйте позже.")
        }
      }

      Status.isActive = false
    }
  }

}
