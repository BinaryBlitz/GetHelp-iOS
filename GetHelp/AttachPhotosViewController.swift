//
//  AttachPhotosViewController.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 09/01/2016.
//  Copyright © 2016 BinaryBlitz. All rights reserved.
//

import UIKit
import DKImagePickerController
import PKHUD
import Alamofire
import RealmSwift

class AttachPhotosViewController: UIViewController {

  @IBOutlet weak var attachButton: UIButton!
  @IBOutlet weak var imagesCountLabel: UILabel!
  @IBOutlet weak var continueButton: GoButton!

  var helpRequest: HelpRequest!
  lazy var imagePickerController: DKImagePickerController = {
    let imagePickerController = DKImagePickerController()
    imagePickerController.navigationBar.barStyle = UIBarStyle.blackTranslucent
    imagePickerController.maxSelectableCount = 5

    return imagePickerController
  }()

  var selectedAssets = [DKAsset]()

  var hudTapGesture: UITapGestureRecognizer!

  override func viewDidLoad() {
    super.viewDidLoad()

    imagePickerController.didSelectAssets = { assets in
      self.selectedAssets = assets
      if assets.count != 0 {
        self.imagesCountLabel.text = "+\(assets.count)"
      } else {
        self.imagesCountLabel.text = ""
      }
    }

    imagesCountLabel.textColor = UIColor.orangeSecondaryColor()

    let reqTypeColor = helpRequest.type.presenter.color

    attachButton.setImage(#imageLiteral(resourceName: "icDownload").withRenderingMode(.alwaysTemplate), for: .normal)
    attachButton.tintColor = reqTypeColor
    continueButton.backgroundColor = reqTypeColor
    continueButton.defaultBackgroundColor = reqTypeColor

    hudTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hudTapCancel))
  }

  @IBAction func continueButtonAction(_ sender: AnyObject) {
    if selectedAssets.count == 0 {
      dismiss(animated: true, completion: nil)
      return
    }

    let id = UserDefaultsHelper.loadObjectForKey(.FirstOperatorMessageId) as? Int
    let message = Message()
    message.id = (id ?? -1) - 1
    message.sender = .Operator
    message.orderId = helpRequest.id
    message.content = "Ваш заказ рассматривается. Оператор ответит вам в ближайшее время. Пишите, если у вас есть какие-то вопросы."
    message.dateCreated = helpRequest.createdAt ?? Date()
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

  @IBAction func attachButtonAction(_ sender: AnyObject) {
    present(imagePickerController, animated: true, completion: nil)
  }

  //MARK: - Images magic

  fileprivate var numberOfAssets: Int = 0
  fileprivate var finishedRequests: Int = 0
  fileprivate var imageSendRequests = [Request?]()

  func sendAssets(_ assets: [DKAsset]) {
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
        guard let image = image?.withNormalizedOrientation else { return }

        let request = serverManager.sendMessageWithImage(image, toOrder: self.helpRequest) { [unowned self] success, error in
          self.finishedRequests += 1
          if self.numberOfAssets == self.finishedRequests {
            HUD.flash(.success)
            self.dismiss(animated: true, completion: nil)
          }

          if let error = error {
            print("Error: \(error)")

            if (error as CustomStringConvertible).description.contains(": 413") {
              self.presentAlertWithTitle("Ошибка", andMessage: "Фотография слишком большая!")
              return
            }

            guard let error = error as? URLError else {
              return
            }

            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
              self.presentAlertWithTitle("Ошибка", andMessage: "Нет подключения к интерету")
            case .cancelled:
              return
            default:
              self.presentAlertWithTitle("Ошбика", andMessage: "Не удалось отправить фотографию. Попробуйте позже.")
            }
          }
        }

        self.imageSendRequests.append(request)
      }
    }

    HUD.show(.labeledProgress(title: "Отправка фотографий", subtitle: "Нажмите для отмены"))
  }

  func hudTapCancel() {
    HUD.flash(.labeledError(title: "Отправка отменена", subtitle: nil))
    self.imageSendRequests.forEach { request in
      request?.cancel()
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    PKHUD.sharedHUD.contentView.addGestureRecognizer(hudTapGesture)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    PKHUD.sharedHUD.contentView.removeGestureRecognizer(hudTapGesture)
  }

}
