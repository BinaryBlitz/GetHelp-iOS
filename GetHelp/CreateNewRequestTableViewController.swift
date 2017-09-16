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
    edgesForExtendedLayout = UIRectEdge()
    view.backgroundColor = UIColor.white

    typePresenters = HelpType.avaliableTypes().map { (type) -> HelpTypePresenter in
      return HelpTypePresenter(type: type)
    }

    let typeCellNib = UINib(nibName: "RequestTypeTableViewCell", bundle: nil)
    tableView.register(typeCellNib, forCellReuseIdentifier: "typeOptionCell")
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 250
  }

  //MARK: - UITableViewDataSource

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "typeOptionCell") as? RequestTypeTableViewCell else {
      return UITableViewCell()
    }

    let presenter = typePresenters[indexPath.section]
    cell.configureWith(presenter)

    return cell
  }

  //MARK: - UITableViewDelegate

  override func numberOfSections(in tableView: UITableView) -> Int {
    return typePresenters.count
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard section == 0 else { return 0 }
    return 40
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = UIColor.clear
    return view
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "fillTheForm", sender: indexPath)
    tableView.deselectRow(at: indexPath, animated: true)
  }

  //MARK: - IBActions

  @IBAction func cancelButtonAction(_ sender: AnyObject) {
    dismiss(animated: true, completion: nil)
  }

  //MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let indexPath = sender as? IndexPath,
        let destination = segue.destination as? RequestFormViewController else {
      return
    }

    let presenter = typePresenters[indexPath.section]
    destination.type = presenter.type
  }
}
