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

    typePresenters = HelpType.avaliableTypes().map { (type) -> HelpTypePresenter in
      return HelpTypePresenter(type: type)
    }
  }

  //MARK: - UITableViewDataSource

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCellWithIdentifier("typeOptionCell") else {
      return UITableViewCell()
    }

    let presenter = typePresenters[indexPath.section]
    cell.textLabel?.text = presenter.name
    cell.imageView?.image = presenter.image

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

  override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    let presenter = typePresenters[section]
    return presenter.description
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
