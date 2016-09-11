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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    Fabric.with([Crashlytics.self])

    configureRealm()
    configureNavigationBar()
    configureTabBar()
    configureServerManager()
    
    checkArguments()
    
    application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
    
    return true
  }
  
  // MARK: - Launch arguments
  
  private func checkArguments() {
    for argument in Process.arguments {
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
      schemaVersion: 16,
      migrationBlock: { migration, oldSchemaVersion in
        if oldSchemaVersion < 16 {
          migration.deleteData(Message.className())
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
  
  func configureNavigationBar() {
    let appearance = UINavigationBar.appearance()

    appearance.barTintColor = UIColor.orangeSecondaryColor()
    appearance.translucent = false
    appearance.tintColor = UIColor.whiteColor()
    appearance.titleTextAttributes = [
      NSForegroundColorAttributeName: UIColor.whiteColor(),
      NSFontAttributeName: UIFont.systemFontOfSize(18)
    ]

    UIApplication
      .sharedApplication()
      .setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
  }

  func configureTabBar() {
    UITabBar.appearance().tintColor = UIColor.orangeSecondaryColor()
  }
  
  // MARK - Push notifications
  
  func application(application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {

    let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
    var token = ""
    
    for i in 0 ..< deviceToken.length {
      token += String(format: "%02.2hhx", arguments: [tokenChars[i]])
    }
    
    UserDefaultsHelper.save(token, forKey: .DeviceToken)
    ServerManager.sharedInstance.deviceToken = token
  }
  
  func application(application: UIApplication,
                   didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    
    print("didFailToRegisterForRemoteNotificationsWithError")
  }
  
  func application(application: UIApplication,
                   didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    
    NSNotificationCenter
      .defaultCenter()
      .postNotificationName(HelpRequestUpdatedNotification, object: nil)
    
    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
  }
  
  func application(
    application: UIApplication,
    performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    
    ServerManager.sharedInstance.fetchHelpRequests { success, error in
      do {
        let realm = try Realm()
        let results = realm.objects(HelpRequest).filter("viewed == false")
        UIApplication.sharedApplication().applicationIconBadgeNumber = results.count
      } catch {
        return
      }

      let backgroundFetchResult: UIBackgroundFetchResult = (error == nil ? .NewData : .Failed)
      completionHandler(backgroundFetchResult)
    }
  }
}

