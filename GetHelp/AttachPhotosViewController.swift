//
//  AttachPhotosViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 09/01/2016.
//  Copyright © 2016 BinaryBlitz. All rights reserved.
//

import UIKit
import DKImagePickerController
import SwiftSpinner
import Alamofire
import RealmSwift

class AttachPhotosViewController: UIViewController {

  @IBOutlet weak var attachButton: UIButton!
  @IBOutlet weak var imagesCountLabel: UILabel!
  
  var helpRequest: HelpRequest!
  lazy var imagePickerController: DKImagePickerController = {
    let imagePickerController = DKImagePickerController()
    imagePickerController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
    imagePickerController.maxSelectableCount = 5
    
    return imagePickerController
  }()
  
  var selectedAssets = [DKAsset]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    attachButton.layer.borderWidth = 1
    attachButton.layer.cornerRadius = 5
    attachButton.layer.borderColor = UIColor.orangeSecondaryColor().CGColor
    attachButton.tintColor = UIColor.orangeSecondaryColor()
    
    imagePickerController.didSelectAssets = { assets in
      self.selectedAssets = assets
      if assets.count != 0 {
        self.imagesCountLabel.text = "+\(assets.count)"
      } else {
        self.imagesCountLabel.text = ""
      }
    }
    
    imagesCountLabel.textColor = UIColor.orangeSecondaryColor()
  }
  
  @IBAction func continueButtonAction(sender: AnyObject) {
    if selectedAssets.count == 0 {
      dismissViewControllerAnimated(true, completion: nil)
      return
    }
    
    let id = UserDefaultsHelper.loadObjectForKey(.FirstOperatorMessageId) as? Int
    let message = Message()
    message.id = (id ?? -1) - 1
    message.sender = .Operator
    message.orderId = helpRequest.id
    message.content = "Ваш заказ рассматривается. Оператор ответит вам в ближайшее время. Пишите, если у вас есть какие-то вопросы."
    message.dateCreated = helpRequest.createdAt ?? NSDate()
    do {
      let realm = try Realm()
      try realm.write {
        realm.add(message)
      }
      
      UserDefaultsHelper.save(message.id, forKey: .FirstOperatorMessageId)
    } catch let error {
        print("Error: \(error)")
    }
    
    sendAssets(selectedAssets)
  }
  
  @IBAction func attachButtonAction(sender: AnyObject) {
    presentViewController(imagePickerController, animated: true, completion: nil)
  }
  
  //MARK: - Images magic
  
  private var numberOfAssets: Int = 0
  private var finishedRequests: Int = 0
  private var imageSendRequests = [Request?]()
  
  func sendAssets(assets: [DKAsset]) {
    let serverManager = ServerManager.sharedInstance
    numberOfAssets = 0
    finishedRequests = 0
    imageSendRequests = []
    
    if assets.count == 0 {
      return
    }
    
    numberOfAssets = assets.count
    assets.forEach { asset in
      asset.fetchOriginalImageWithCompleteBlock { image, info in
        guard let originalImage = image else {
          return
        }
        
        guard let image = UIImage.resizeImage(originalImage, withScalingFactor: 0.67) else {
          return
        }
        
        let request = serverManager.sendMessageWithImage(image, toOrder: self.helpRequest) { [unowned self] success, error in
          self.finishedRequests += 1
          if self.numberOfAssets == self.finishedRequests {
            SwiftSpinner.hide()
            self.dismissViewControllerAnimated(true, completion: nil)
          }
          
          if let error = error {
            print("Error: \(error)")
            
            if (error as NSError).description.containsString(": 413") {
              self.presentAlertWithTitle("Ошибка", andMessage: "Фотография слишком большая!")
              return
            }
            
            guard let error = error as? NSURLError else {
              return
            }

            switch error {
            case .NotConnectedToInternet, .NetworkConnectionLost:
              self.presentAlertWithTitle("Ошибка", andMessage: "Нет подключения к интерету")
            case .Cancelled:
              return
            default:
              self.presentAlertWithTitle("Ошбика", andMessage: "Не удалось отправить фотографию. Попробуйте позже.")
            }
          }
        }
        
        self.imageSendRequests.append(request)
      }
    }
    
    SwiftSpinner.show("Отправка фотографий").addTapHandler( {
        SwiftSpinner.hide()
        self.imageSendRequests.forEach { request in
          request?.cancel()
        }
    }, subtitle: "Нажмите для отмены")
  }
}
