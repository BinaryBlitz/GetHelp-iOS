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
  func updateNavigationDelegate(delegate: LoginNavigationDelegate)
  func setData(data: AnyObject?)
}

protocol LoginNavigationDelegate {
  func moveForward(data: AnyObject?)
  func moveBackward(data: AnyObject?)
}

class LoginBaseViewController: UIViewController {

  enum MoveOption {
    case Forward
    case Backward
    
    func getAinmationOptions() -> UIViewAnimationOptions {
      switch self {
      case .Forward:
        return UIViewAnimationOptions.TransitionFlipFromRight
      case .Backward:
        return UIViewAnimationOptions.TransitionFlipFromLeft
      }
    }
  }

  @IBOutlet weak var containerView: UIView!
  
  private var numberOfPages = 3
  private var viewControllersIdentifiers = [
    "GreetingViewController",
    "PhoneNumberViewController",
    "CodeViewController"
  ]
  private var viewControllers = [String: UIViewController]()
  private var presentingIndex: Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let content = segue.destinationViewController as? ContainerPresentable {
      content.updateNavigationDelegate(self)
    }
  }
  
  func presentViewControllerWithIndex(index: Int, withOptions moveOption: MoveOption, andData data: AnyObject?) {
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
    
    currentController.willMoveToParentViewController(nil)
    addChildViewController(viewControllerToPresent)
    let duration = 0.57
    
    if let contentToPresent = viewControllerToPresent as? ContainerPresentable {
      contentToPresent.updateNavigationDelegate(self)
      contentToPresent.setData(data)
    }
    viewControllerToPresent.view.frame = currentController.view.frame
    
    transitionFromViewController(currentController,
      toViewController: viewControllerToPresent,
      duration: duration,
      options: moveOption.getAinmationOptions(),
      animations: { () -> Void in
        //code
      }) { (finished) -> Void in
        if finished {
          currentController.removeFromParentViewController()
          viewControllerToPresent.didMoveToParentViewController(self)
        }
    }
  }
  
  private func viewControllerAtIndex(index: Int) -> UIViewController? {
    if index >= numberOfPages {
      return nil
    }
    
    let identifire = viewControllersIdentifiers[index]
    if let controller = viewControllers[identifire] {
      return controller
    } else {
      guard let controller = storyboard?.instantiateViewControllerWithIdentifier(identifire) else {
        return nil
      }
      viewControllers[identifire] = controller
      
      return controller
    }
  }
}

extension LoginBaseViewController: LoginNavigationDelegate {
  func moveForward(data: AnyObject?) {
    if presentingIndex + 1 >= numberOfPages {
      return
    }
    
    presentingIndex += 1
    presentViewControllerWithIndex(presentingIndex, withOptions: .Forward, andData: data)
  }
  
  func moveBackward(data: AnyObject?) {
    if presentingIndex - 1 < 0 { return }
    
    presentingIndex -= 1
    presentViewControllerWithIndex(presentingIndex, withOptions: .Backward, andData: data)
  }
}
