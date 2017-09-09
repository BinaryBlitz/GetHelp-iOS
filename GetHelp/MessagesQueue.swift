//
//  MessagesQueue.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 04/01/2016.
//  Copyright © 2016 BinaryBlitz. All rights reserved.
//

import Alamofire

class MessagesQueue {
  var images = [UIImage]()
  var textMessage: String?
  let order: HelpRequest

  fileprivate var update: ((_ success: Bool, _ error: Error?) -> Void)?
  fileprivate var currentRequest: Request?

  init(order: HelpRequest) {
    self.order = order
  }

  func append(_ image: UIImage) {
    images.append(image)
  }

  func append(_ text: String) {
    textMessage = text
  }

  func clearQueue() {
    images = []
    textMessage = nil
  }

  func sendMessagesWithUpdateMethod(_ update: @escaping (_ success: Bool, _ error: Error?) -> Void) {
    print("Images count: \(images.count)")
    self.update = update
    if let text = textMessage {
      currentRequest = ServerManager.sharedInstance.sendMessageWithText(text, toOrder: order) { success, error in
        self.update?(success, error)
        if success {
          self.sendNextImage()
        }
      }
    } else {
      sendNextImage()
    }
  }

  fileprivate func sendNextImage() {
    guard let image = images.popLast() else {
      return
    }

    self.currentRequest = ServerManager.sharedInstance.sendMessageWithImage(image, toOrder: order) { success, error in
      print("Success: \(success)")
      print("Error: \(String(describing: error))")
      self.update?(success, error)
      if success {
        self.sendNextImage()
      }
    }
  }

  func cancel() {
    currentRequest?.cancel()
    currentRequest = nil
  }
}
