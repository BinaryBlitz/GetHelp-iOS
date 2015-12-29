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
    
    if !ServerManager.sharedInstance.authenticated {
      UIApplication.sharedApplication().statusBarHidden = true
      let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
      let loginViewController = loginStoryboard.instantiateInitialViewController()!
      let navigation = UINavigationController(rootViewController: loginViewController)
      navigation.navigationBarHidden = true
      window?.rootViewController = navigation
    } else {
      UIApplication.sharedApplication().statusBarHidden = false
      let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
      let homeViewController = mainStoryboard.instantiateInitialViewController()!
      window?.rootViewController = homeViewController
    }
    
    return true
  }
  
  //MARK: - Launch arguments
  
  private func checkArguments() {
    for argument in Process.arguments {
      switch argument {
      case "--dont-login":
        ServerManager.sharedInstance.apiToken = "4YdZnMy9TtnuWQotqhKhS3Dx"
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
      request3.price = 2000
      request3.email = "foobar@gmail.com"
      
      realm.add(request3)
      realm.add(request1)
      realm.add(request2)
    }
  }
  
  //MARK: - App configuration
  
  func configureRealm() {
    let realmDefaultConfig = Realm.Configuration(
    schemaVersion: 10,
            migrationBlock: { migration, oldSchemaVersion in
              if oldSchemaVersion < 1 {}
            }
    )
    Realm.Configuration.defaultConfiguration = realmDefaultConfig
  }
  
  func configureServerManager() {
    let manager = ServerManager.sharedInstance
    
    if let token = NSUserDefaults.standardUserDefaults().objectForKey("apiToken") as? String {
      manager.apiToken = token
    }
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
  
  //MARK: - Application delegate
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

