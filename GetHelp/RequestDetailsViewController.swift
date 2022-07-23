//
//  RequestDetailsViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 04/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import RealmSwift

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

  var requestInfoViewController: RequestInfoTableViewController!

  var helpRequest: HelpRequest!

  var token : NotificationToken?

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
        setMessagesReadIfNeeded()
      }

    }
  }

  var segmentViews: [HelpRequestSegmentItemView] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    configureSegments()

    self.token = helpRequest.addNotificationBlock { [weak self] change in
      guard let `self` = self else { return }
      switch change {
      case .change(let properties):
        for property in properties {
          guard property.name == "messagesRead" else { continue }
          guard let newValue = property.newValue as? Bool else { continue }
          self.segmentViews[RequestDetailsSegment.chat.rawValue].badgeView.isHidden = newValue
          self.requestInfoViewController.setCommentSectionHidden(newValue)
          if !newValue && self.currentSegment == .chat  {
            ServerManager.sharedInstance.setRequest(self.helpRequest, messagesRead: true, completion: nil)
          }
        }
      default:
        break
      }
    }
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
    self.segmentViews[RequestDetailsSegment.chat.rawValue].badgeView.isHidden = helpRequest.messagesRead
  }

  func setMessagesReadIfNeeded() {
    guard !helpRequest.messagesRead else { return }
    ServerManager.sharedInstance.setRequest(self.helpRequest, messagesRead: true, completion: nil)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }


  //MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let infoViewController = segue.destination as? RequestInfoTableViewController {
      infoViewController.helpRequest = helpRequest
      self.requestInfoViewController = infoViewController
    } else if let conversationViewController = segue.destination as? ConversationViewController {
      conversationViewController.helpRequest = helpRequest
    }
  }

}
