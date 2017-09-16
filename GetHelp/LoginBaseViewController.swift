//
//  LoginBaseViewController.swift
//  GetHelpLoginStuff
//
//  Created by Dan Shevlyuk on 25/12/2015.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit

protocol ContainerPresentable {
  var viewController: UIViewController { get }
  func updateNavigationDelegate(_ delegate: LoginNavigationDelegate)
  func setData(_ data: AnyObject?)
}

protocol LoginNavigationDelegate {
  func moveForward(_ data: AnyObject?)
  func moveBackward(_ data: AnyObject?)
}

class LoginBaseViewController: UIViewController, LightContentViewController {

  enum MoveOption {
    case forward
    case backward

    func getAinmationOptions() -> UIViewAnimationOptions {
      switch self {
      case .forward:
        return UIViewAnimationOptions.transitionFlipFromRight
      case .backward:
        return UIViewAnimationOptions.transitionFlipFromLeft
      }
    }
  }

  @IBOutlet weak var containerView: UIView!

  fileprivate var numberOfPages = 3
  fileprivate var viewControllersIdentifiers = [
    "GreetingViewController",
    "PhoneNumberViewController",
    "CodeViewController"
  ]
  fileprivate var viewControllers = [String: UIViewController]()
  fileprivate var presentingIndex: Int = 0

  override func viewDidLoad() {
    super.viewDidLoad()

  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let content = segue.destination as? ContainerPresentable {
      content.updateNavigationDelegate(self)
    }
  }

  func presentViewControllerWithIndex(_ index: Int, withOptions moveOption: MoveOption, andData data: AnyObject?) {
    guard let viewControllerToPresent = viewControllerAtIndex(index) else {
      return
    }

    var currentContent: ContainerPresentable? = nil

    for child in childViewControllers {
      if let content = child as? ContainerPresentable {
        currentContent = content
        break
      }
    }

    guard let currentController = currentContent?.viewController else { return }

    currentController.willMove(toParentViewController: nil)
    addChildViewController(viewControllerToPresent)
    let duration = 0.57

    if let contentToPresent = viewControllerToPresent as? ContainerPresentable {
      contentToPresent.updateNavigationDelegate(self)
      contentToPresent.setData(data)
    }
    viewControllerToPresent.view.frame = currentController.view.frame

    transition(from: currentController,
      to: viewControllerToPresent,
      duration: duration,
      options: moveOption.getAinmationOptions(),
      animations: { () -> Void in
        //code
      }) { (finished) -> Void in
        if finished {
          currentController.removeFromParentViewController()
          viewControllerToPresent.didMove(toParentViewController: self)
        }
    }
  }

  fileprivate func viewControllerAtIndex(_ index: Int) -> UIViewController? {
    if index >= numberOfPages {
      return nil
    }

    let identifire = viewControllersIdentifiers[index]
    if let controller = viewControllers[identifire] {
      return controller
    } else {
      guard let controller = storyboard?.instantiateViewController(withIdentifier: identifire) else {
        return nil
      }
      viewControllers[identifire] = controller

      return controller
    }
  }
}

extension LoginBaseViewController: LoginNavigationDelegate {
  func moveForward(_ data: AnyObject?) {
    if presentingIndex + 1 >= numberOfPages {
      return
    }

    presentingIndex += 1
    presentViewControllerWithIndex(presentingIndex, withOptions: .forward, andData: data)
  }

  func moveBackward(_ data: AnyObject?) {
    if presentingIndex - 1 < 0 { return }

    presentingIndex -= 1
    presentViewControllerWithIndex(presentingIndex, withOptions: .backward, andData: data)
  }
}
