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
    
    navigationController?.navigationBar.barStyle = .BlackTranslucent
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

    refreshControl.addTarget(self, action: #selector(refresh(_:)), forControlEvents: .ValueChanged)
    configureCreateButton()
    configureTableView()
    
    fetchHelpRequests()
    tableView.reloadData()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refresh(_:)),
            name: HelpRequestUpdatedNotification, object: nil)
    
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    refresh(self)
    
    if !ServerManager.sharedInstance.authenticated {
      let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
      let loginViewController = loginStoryboard.instantiateInitialViewController()!
      let navigation = UINavigationController(rootViewController: loginViewController)
      navigation.navigationBarHidden = true
      presentViewController(navigation, animated: true, completion: nil)
    }
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  //MARK: - Initialize

  func configureTableView() {
    let helpRequestCellNib = UINib(nibName: "HelpRequestTableViewCell", bundle: nil)
    tableView.tableFooterView = UIView()
    tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    tableView.registerNib(helpRequestCellNib, forCellReuseIdentifier: "helpRequestCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 80
    tableView.addSubview(refreshControl)
    tableView.sendSubviewToBack(refreshControl)
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 5))
    headerView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    tableView.tableHeaderView = headerView
  }

  func configureCreateButton() {
    createRequestButton.layer.borderWidth = 1
    createRequestButton.layer.cornerRadius = 5
    createRequestButton.layer.borderColor = UIColor.orangeSecondaryColor().CGColor
    createRequestButton.tintColor = UIColor.orangeSecondaryColor()
  }
  
  //MARK: - Refresh
  
  func refresh(sender: AnyObject) {
    beginRefreshWithCompletion {
      self.fetchHelpRequests()
      self.tableView.reloadData()
      self.refreshControl.endRefreshing()
    }
  }
  
  func beginRefreshWithCompletion(completion: () -> Void) {
    //TODO: Reresh request
    ServerManager.sharedInstance.fetchHelpRequests { success, error in
      if !success {
        print("Error in ferching request")
      }
      
      do {
        let realm = try Realm()
        let results = realm.objects(HelpRequest).filter("viewed == false")
        UIApplication.sharedApplication().applicationIconBadgeNumber = results.count
      } catch {
        return
      }
      
      completion()
    }
  }

  //MARK: - Tools

  func fetchHelpRequests() {
    let realm  = try! Realm()
    helpRequests = realm.objects(HelpRequest).sorted("createdAt", ascending: false)
  }

  //MARK: - Actions
  
  @IBAction func addBarButtonAction(sender: AnyObject) {
    performSegueWithIdentifier("createNewRequest", sender: self)
  }
  
  //MARK: Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let destination = segue.destinationViewController as? RequestDetailsViewController,
        indexPath = sender as? NSIndexPath {
      destination.helpRequest = helpRequests?[indexPath.row]
    }
  }
}

//MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier("showDetails", sender: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}

//MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let requests = helpRequests else {
      tableView.hidden = true
      backgroundView.hidden = false
      return 0
    }
    
    let shouldHideTableView = requests.count == 0
    tableView.hidden = shouldHideTableView
    backgroundView.hidden = !shouldHideTableView
    return requests.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    guard let cell = tableView.dequeueReusableCellWithIdentifier("helpRequestCell") as? HelpRequestTableViewCell else {
      return UITableViewCell()
    }

    let request = helpRequests?[indexPath.row]
    if let presenter = request?.presenter() {
      cell.configure(presenter)
    }
    
    cell.delegate = self

    return cell
  }
  
  func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    guard let cell = cell as? HelpRequestTableViewCell else {
      return
    }
    
    cell.stopAnimations()
  }
}

//MARK: - HelpRequestCellDelegate

extension HomeViewController: HelpRequestCellDelegate {
  func didTouchPayButtonInCell(cell: HelpRequestTableViewCell) {
    struct Status {
      static var isActive: Bool = false
    }
    
    if Status.isActive {
      return
    }
    
    guard let indexPath = tableView.indexPathForCell(cell) else {
      return
    }
    
    guard let order = helpRequests?[indexPath.row] else {
      return
    }
    
    Status.isActive = true
    ServerManager.sharedInstance.paymentsURLForOrderID(order.id) { paymentURL, error in
      if let url = paymentURL {
        self.presentWebViewControllerWith(url)
      } else if let error = error {
        guard let error = error as? NSURLError else {
          return
        }

        switch error {
        case .NotConnectedToInternet, .NetworkConnectionLost:
          self.presentAlertWithTitle("Ошибка", andMessage: "Нет подключения к интерету")
        case .Cancelled:
          return
        default:
          self.presentAlertWithTitle("Ошбика", andMessage: "Не удалось загрузить страницу. Попробуйте позже.")
        }
      }
      
      Status.isActive = false
    }
  }
}
