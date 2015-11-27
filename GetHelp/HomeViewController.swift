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

class HomeViewController: UIViewController {

  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var createRequestButton: UIButton!
  
  var helpRequests: Results<HelpRequest>?

  //MARK: - Livecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    createRequestButton.layer.borderWidth = 2
    createRequestButton.layer.cornerRadius = 5
    createRequestButton.layer.borderColor = UIColor.blueColor().CGColor

    let helpRequestCellNib = UINib(nibName: "HelpRequestTableViewCell", bundle: nil)
    tableView.tableFooterView = UIView()
    tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    tableView.registerNib(helpRequestCellNib, forCellReuseIdentifier: "helpRequestCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 80

    fetchHelpRequests()

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload:",
            name: HelpRequestUpdatedNotification, object: nil)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  //MARK: - Tools

  func fetchHelpRequests(serverManager: ServerManager = ServerManager()) {
    let realm  = try! Realm()
    helpRequests = realm.objects(HelpRequest)
  }

  //MARK: - Actions
  
  @IBAction func profileBarButtonAction(sender: AnyObject) {
    tableView.reloadData()
  }
  
  @IBAction func addBarButtonAction(sender: AnyObject) {
    performSegueWithIdentifier("createNewRequest", sender: self)
  }
}

//MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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

    //TODO: configure cell
    cell.nameLabel.text = helpRequests?[indexPath.row].subject
    cell.indicatorImageView.tintColor = UIColor.orangeColor()

    return cell
  }
}
