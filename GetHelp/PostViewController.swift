//
//  PostViewController.swift
//  GetHelp
//
//  Created by Алексей on 17.09.17.
//  Copyright © 2017 BinaryBlitz. All rights reserved.
//

import Foundation
import UIKit

class PostViewController: UIViewController, LightContentViewController {
  @IBOutlet weak var maskView: UIView!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!

  fileprivate lazy var dateFormatter = DateFormatter(dateFormat: "EE dd MMM")

  var post: Post!

  override func viewDidLoad() {
    imageView.kf.setImage(with: URL(string: post.imageUrl))
    dateLabel.text = dateFormatter.string(from: post.createdAt)
    titleLabel.text = post.title
    maskView.backgroundColor = post.promo ? UIColor.orangeSecondaryColor().withAlphaComponent(0.45) : UIColor.black.withAlphaComponent(0.3)
    contentLabel.text = post.content

  }

  override func viewWillAppear(_ animated: Bool) {
    self.tabBarController?.tabBar.isHidden = true
  }

}
