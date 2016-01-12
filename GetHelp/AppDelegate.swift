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

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    Fabric.with([Crashlytics.self])

    configureRealm()
    configureNavigationBar()
    configureTabBar()
    configureServerManager()
    
    checkArguments()
    
    application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
    
    return true
  }
  
  //MARK: - Launch arguments
  
  private func checkArguments() {
    for argument in Process.arguments {
      switch argument {
      case "--dont-login":
        ServerManager.sharedInstance.apiToken = "BXaNe1rF3tYowNFtLDFk8jqh"
      case "--test-data":
        dropDatabaseData()
        setTestDbData()
      default:
        break
      }
    }
  }
  
  //MARK: Testing methods
  
  private func dropDatabaseData() {
    let realm = try! Realm()
    try! realm.write {
      realm.deleteAll()
    }
  }
  
  func setTestDbData() {
    let realm = try! Realm()
    
    try! realm.write { () -> Void in
      let request1 = HelpRequest()
      request1.id = 123
      request1.subject = "Математический анализ"
      request1.course = "1"
      request1.school = "МГУ"
      request1.faculty = "Экономики"
      request1.helpDescription = "оолололол"
      request1.type = .Express
      request1.status = HelpRequestStatus.InReview
      request1.dueDate = NSDate().dateByAddingTimeInterval(10000)
      request1.startDate = NSDate().dateByAddingTimeInterval(10000 - 7200)
      request1.email = "foobar@gmail.com"
      
      let request2 = HelpRequest()
      request2.id = 124
      request2.subject = "Эконометрика"
      request2.course = "3"
      request2.school = "ВШЭ"
      request2.faculty = "Математики"
      request2.helpDescription = "оолололол"
      request2.type = .Normal
      request2.status = HelpRequestStatus.Accepted
      request2.dueDate = NSDate().dateByAddingTimeInterval(5000)
      request2.email = "foobar@gmail.com"
      
      let request3 = HelpRequest()
      request3.id = 150
      request3.subject = "Операционные системы"
      request3.course = "3"
      request3.school = "ВШЭ"
      request3.faculty = "Компьютерных наук"
      request3.helpDescription = "ололоыуаошыоашыоа"
      request3.type = .Normal
      request3.status = HelpRequestStatus.WaitingForPayment
      request3.dueDate = NSDate().dateByAddingTimeInterval(30000)
      request3.sum = 2000
      request3.email = "foobar@gmail.com"
      
      realm.add(request3)
      realm.add(request1)
      realm.add(request2)
    }
  }
  
  //MARK: - App configuration
  
  func configureRealm() {
    let realmDefaultConfig = Realm.Configuration(
    schemaVersion: 15,
            migrationBlock: { migration, oldSchemaVersion in
              if oldSchemaVersion < 1 {}
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
    UINavigationBar.appearance().barTintColor = UIColor.orangeSecondaryColor()
    UINavigationBar.appearance().translucent = false
    UINavigationBar.appearance().tintColor = UIColor.whiteColor()
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(18)]
    UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
  }

  func configureTabBar() {
    UITabBar.appearance().tintColor = UIColor.orangeSecondaryColor()
  }
  
  //MARK - Push notifications
  
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
    var token = ""
    
    for var i = 0; i < deviceToken.length; i++ {
      token += String(format: "%02.2hhx", arguments: [tokenChars[i]])
    }
    
    UserDefaultsHelper.save(token, forKey: .DeviceToken)
    ServerManager.sharedInstance.deviceToken = token
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    // develper.layOnTheFloor()
    // do {
    //    try developer.notToCry()
    // catch {
    //    developer.cryALot()
    // }
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    NSNotificationCenter.defaultCenter().postNotificationName(HelpRequestUpdatedNotification, object: nil)
    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
  }
  
  func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    ServerManager.sharedInstance.fetchHelpRequests { success, error in
      do {
        let realm = try Realm()
        let results = realm.objects(HelpRequest).filter("viewed == false")
        UIApplication.sharedApplication().applicationIconBadgeNumber = results.count
      } catch {
        return
      }
      
      if let _ = error {
        completionHandler(UIBackgroundFetchResult.Failed)
      } else {
        completionHandler(UIBackgroundFetchResult.NewData)
      }
    }
  }
}

