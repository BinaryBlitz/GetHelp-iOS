//
//  MessagesQueue.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 04/01/2016.
//  Copyright © 2016 BinaryBlitz. All rights reserved.
//

import Alamofire

struct MessagesQueue {
  var images = [UIImage]()
  var textMessage: String?
  let order: HelpRequest

  private var update: ((success: Bool, error: ErrorType?) -> Void)?
  private var currentRequest: Request?

  init(order: HelpRequest) {
    self.order = order
  }

  mutating func append(image: UIImage) {
    images.append(image)
  }

  mutating func append(text: String) {
    textMessage = text
  }

  mutating func clearQueue() {
    images = []
    textMessage = nil
  }

  mutating func sendMessagesWithUpdateMethod(update: (success: Bool, error: ErrorType?) -> Void) {
    print("Images count: \(images.count)")
    self.update = update
    if let text = textMessage {
      currentRequest = ServerManager.sharedInstance.sendMessageWithText(text, toOrder: order) { success, error in
        self.update?(success: success, error: error)
        if success {
          self.sendNextImage()
        }
      }
    } else {
      sendNextImage()
    }
  }

  mutating private func sendNextImage() {
    guard let image = images.popLast() else {
      return
    }

    self.currentRequest = ServerManager.sharedInstance.sendMessageWithImage(image, toOrder: order) { success, error in
      print("Success: \(success)")
      print("Error: \(error)")
      self.update?(success: success, error: error)
      if success {
        self.sendNextImage()
      }
    }
  }

  mutating func cancel() {
    currentRequest?.cancel()
    currentRequest = nil
  }
}
