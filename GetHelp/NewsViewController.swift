//
//  NewsViewController.swift
//  GetHelp
//
//  Created by Алексей on 17.09.17.
//  Copyright © 2017 BinaryBlitz. All rights reserved.
//

import Foundation
import UIKit

private let reuseIdentifier = "NewsItemTableViewCell"

class NewsViewController: UITableViewController {

  var posts: [Post] = [] {
    didSet {
      tableView.reloadData()
    }
  }

  var news: [Post] {
    return posts.filter { !$0.promo }
  }

  var promoNews: [Post] {
    return posts.filter { $0.promo }
  }


  override func viewDidLoad() {
    let sectionHeaderNib = UINib(nibName: "HelpRequestSectionHeader", bundle: nil)
    tableView.register(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: "helpRequestHeader")

    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.tabBarController?.tabBar.isHidden = false
    refresh()
  }

  func refresh() {
    ServerManager.sharedInstance.fetchNews { [weak self] posts, _ in
      self?.posts = posts
    }
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? promoNews.count : news.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let post = indexPath.section == 0 ? promoNews[indexPath.row] : news[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NewsItemTableViewCell

    cell.configure(post: post)
    return cell
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "helpRequestHeader") as! HelpRequestSectionHeader

    switch section {
    case 0 where !promoNews.isEmpty:
      header.contentView.backgroundColor = UIColor.white
      header.configure(text: "Акции")
    case 1 where !news.isEmpty:
      header.contentView.backgroundColor = UIColor.white
      header.configure(text: "Новости")
    default:
      header.configure(text: "")
      header.contentView.backgroundColor = UIColor.clear
    }
    return header
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    switch section {
    case 0 where promoNews.isEmpty:
      return 0
    case 1 where news.isEmpty:
      return 0
    default:
      return 60
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let post = indexPath.section == 0 ? promoNews[indexPath.row] : news[indexPath.row]
    performSegue(withIdentifier: "showPost", sender: post)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? PostViewController, let post = sender as? Post {
      destination.post = post
    }
  }
}
