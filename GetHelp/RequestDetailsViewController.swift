//
//  RequestDetailsViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 04/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

enum RequestDetailsSegment: Int {
  case order = 0
  case chat

  var name: String {
    switch self {
    case .order:
      return "Заказ"
    case .chat:
      return "Чат"
    }
  }

  static let allValues = [order, chat]
}

class RequestDetailsViewController: UIViewController {
  @IBOutlet weak var requestInfoView: UIView!
  @IBOutlet weak var conversationView: UIView!
  @IBOutlet weak var segmentsStackView: UIStackView!

  var helpRequest: HelpRequest!

  var currentSegment: RequestDetailsSegment = .order {
    didSet {
      for (index, view) in segmentViews.enumerated() {
        view.isSelected = currentSegment.rawValue == index
      }

      switch currentSegment {
      case .order:
        requestInfoView.isHidden = false
        conversationView.isHidden = true
      case .chat:
        requestInfoView.isHidden = true
        conversationView.isHidden = false
      }

    }
  }

  var segmentViews: [HelpRequestSegmentItemView] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    configureSegments()
  }

  func configureSegments() {
    for segment in RequestDetailsSegment.allValues {
      let nib = UINib(nibName: "HelpRequestSegmentItemView", bundle: nil)
      let view = nib.instantiate(withOwner: nil, options: nil)[0] as! HelpRequestSegmentItemView
      view.titleText = segment.name
      view.isSelected = currentSegment == segment

      view.badgeItemTapHandler = { [weak self] in
        self?.currentSegment = segment
      }
      
      segmentViews.append(view)
      segmentsStackView.addArrangedSubview(view)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    self.tabBarController?.tabBar.isHidden = true
  }


  //MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let infoViewController = segue.destination as? RequestInfoTableViewController {
      infoViewController.helpRequest = helpRequest
    } else if let conversationViewController = segue.destination as? ConversationViewController {
      conversationViewController.helpRequest = helpRequest
    }
  }

}
