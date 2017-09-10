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

  //MARK: - Livecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationController?.navigationBar.barStyle = .blackTranslucent
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    configureCreateButton()
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
    tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    tableView.register(helpRequestCellNib, forCellReuseIdentifier: "helpRequestCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 80
    tableView.addSubview(refreshControl)
    tableView.sendSubview(toBack: refreshControl)
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 5))
    headerView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    tableView.tableHeaderView = headerView
  }

  func configureCreateButton() {
    createRequestButton.layer.borderWidth = 1
    createRequestButton.layer.cornerRadius = 5
    createRequestButton.layer.borderColor = UIColor.orangeSecondaryColor().cgColor
    createRequestButton.tintColor = UIColor.orangeSecondaryColor()
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
      destination.helpRequest = helpRequests?[indexPath.row]
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

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let requests = helpRequests else {
      tableView.isHidden = true
      backgroundView.isHidden = false
      return 0
    }

    let shouldHideTableView = requests.count == 0
    tableView.isHidden = shouldHideTableView
    backgroundView.isHidden = !shouldHideTableView
    return requests.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    guard let cell = tableView.dequeueReusableCell(withIdentifier: "helpRequestCell") as? HelpRequestTableViewCell else {
      return UITableViewCell()
    }

    let request = helpRequests?[indexPath.row]

    if let presenter = request?.presenter() {
      cell.configure(presenter)
    }

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
