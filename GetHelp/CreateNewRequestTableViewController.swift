//
//  CreateNewRequestTableViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 25/11/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import RealmSwift

class CreateNewRequestTableViewController: UITableViewController {

  var typePresenters: [HelpTypePresenter] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent

    typePresenters = HelpType.avaliableTypes().map { (type) -> HelpTypePresenter in
      return HelpTypePresenter(type: type)
    }
    
    let typeCellNib = UINib(nibName: "RequestTypeTableViewCell", bundle: nil)
    tableView.registerNib(typeCellNib, forCellReuseIdentifier: "typeOptionCell")
    tableView.rowHeight = UIScreen.mainScreen().bounds.height / 3
//    tableView.estimatedRowHeight = 250
  }

  //MARK: - UITableViewDataSource

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCellWithIdentifier("typeOptionCell") as? RequestTypeTableViewCell else {
      return UITableViewCell()
    }

    let presenter = typePresenters[indexPath.section]
    cell.configureWith(presenter)

    return cell
  }

  //MARK: - UITableViewDelegate

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return typePresenters.count
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier("fillTheForm", sender: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  //MARK: - IBActions

  @IBAction func cancelButtonAction(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  //MARK: - Navigation

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let indexPath = sender as? NSIndexPath,
        destination = segue.destinationViewController as? RequestFormViewController else {
      return
    }

    let presenter = typePresenters[indexPath.section]
    destination.type = presenter.type
  }
}
