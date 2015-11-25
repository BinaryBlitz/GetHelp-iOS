//
//  HomeViewController.swift
//  GetHelp
//
// Created by Dan Shevlyuk on 22/11/15.
// Copyright (c) 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var createRequestButton: UIButton!
  
  var helpRequests: Results<HelpRequest> {
    let realm  = try! Realm()
    return realm.objects(HelpRequest)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    createRequestButton.layer.borderWidth = 2
    createRequestButton.layer.cornerRadius = 5
    createRequestButton.layer.borderColor = UIColor.blueColor().CGColor

    let helpRequestCellNib = UINib(nibName: "HelpRequestTableViewCell", bundle: nil)
    tableView.registerNib(helpRequestCellNib, forCellReuseIdentifier: "helpRequestCell")
  }
  
  //MARK: - Actions
  
  @IBAction func profileBarButtonAction(sender: AnyObject) {
    
  }
  
  @IBAction func addBarButtonAction(sender: AnyObject) {
    
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

    tableView.hidden = helpRequests.count == 0

    return helpRequests.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    guard let cell = tableView.dequeueReusableCellWithIdentifier("helpRequestCell") as? HelpRequestTableViewCell else {
      return UITableViewCell()
    }

    //TODO: Set up cell
    cell.textLabel?.text = helpRequests[indexPath.row].id

    return cell
  }
}
