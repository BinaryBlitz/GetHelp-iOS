//
//  AppDelegate.swift
//  GetHelp
//
//  Created by Dan Shevlyuk on 17/11/15.
//  Copyright © 2015 BinaryBlitz. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import RealmSwift
import AudioToolbox
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    Fabric.with([Crashlytics.self])

    configureRealm()
    configureServerManager()

    checkArguments()

    application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    return true
  }

  // MARK: - Launch arguments

  fileprivate func checkArguments() {
    for argument in CommandLine.arguments {
      switch argument {
      case "--dont-login":
        ServerManager.sharedInstance.apiToken = "foobar"
      default:
        break
      }
    }
  }

  // MARK: - App configuration

  func configureRealm() {
    let realmDefaultConfig = Realm.Configuration(
      schemaVersion: 17,
      migrationBlock: { migration, oldSchemaVersion in
        if oldSchemaVersion < 16 {
          migration.deleteData(forType: Message.className())
        }
      }
    )

    Realm.Configuration.defaultConfiguration = realmDefaultConfig
  }

  func configureServerManager() {
    let manager = ServerManager.sharedInstance

    if let apiToken = UserDefaultsHelper.loadObjectForKey(.ApiToken) as? String {
      manager.apiToken = apiToken
    }

    if let deviceToken = UserDefaultsHelper.loadObjectForKey(.DeviceToken) as? String {
      manager.deviceToken = deviceToken
    }

    ServerManager.sharedInstance.updateDeviceTokenIfNeeded()
  }

  // MARK - Push notifications

  func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

    let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
    var token = ""

    for i in 0 ..< deviceToken.count {
      token += String(format: "%02.2hhx", arguments: [tokenChars[i]])
    }

    UserDefaultsHelper.save(token, forKey: .DeviceToken)
    ServerManager.sharedInstance.deviceToken = token
  }

  func application(_ application: UIApplication,
                   didFailToRegisterForRemoteNotificationsWithError error: Error) {

    print("didFailToRegisterForRemoteNotificationsWithError")
  }

  func application(_ application: UIApplication,
                   didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {

    NotificationCenter.default
      .post(name: Notification.Name(rawValue: HelpRequestUpdatedNotification), object: nil)

    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
  }

  

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    NotificationCenter.default
      .post(name: Notification.Name(rawValue: HelpRequestUpdatedNotification), object: nil)

    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    completionHandler(.noData)
  }

  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .sound, .badge])
  }

  func application(
    _ application: UIApplication,
    performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    ServerManager.sharedInstance.fetchHelpRequests { success, error in
      do {
        let realm = try Realm()
        let results = realm.objects(HelpRequest.self).filter("messagesRead == false")
        UIApplication.shared.applicationIconBadgeNumber = results.count
      } catch {
        return
      }

      let backgroundFetchResult: UIBackgroundFetchResult = (error == nil ? .newData : .failed)
      completionHandler(backgroundFetchResult)
    }
  }
}
