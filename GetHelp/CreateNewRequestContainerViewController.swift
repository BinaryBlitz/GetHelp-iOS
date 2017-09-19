//
//  CreateNewRequestContainerViewController.swift
//  GetHelp
//
//  Created by Алексей on 16.09.17.
//  Copyright © 2017 BinaryBlitz. All rights reserved.
//

import Foundation
import UIKit

class CreateNewRequestContainerViewController: UIViewController {
  var type: HelpType? = nil {
    didSet {
      guard let vc = formViewController, let type = type else { return }
      vc.type = type
    }
  }

  var formViewController: RequestFormViewController? = nil {
    didSet {
      guard let vc = formViewController, let type = type else { return }
      vc.type = type
      vc.onError = { [weak self] message in
        self?.presentAlertWithMessage(message)
      }
      vc.onRequestCreate = { [weak self] request in
        let storyboard = UIStoryboard(name: "CreateNewRequest", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AttachPhotosViewController") as! AttachPhotosViewController
        viewController.helpRequest = request
        self?.navigationController?.pushViewController(viewController, animated: true)
      }
    }
  }

  @IBOutlet weak var sendButton: GoButton!

  @IBAction func sendButtonAction(_ sender: Any) {
    formViewController?.validate()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    sendButton.backgroundColor = type?.presenter.color ?? UIColor.tealishTwo
    sendButton.defaultBackgroundColor = type?.presenter.color ?? UIColor.tealishTwo
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? RequestFormViewController {
      formViewController = destination
    }
  }
  
}
