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
  
  func configureRealm() {
    let realmDefaultConfig = Realm.Configuration(
    schemaVersion: 6,
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
  
  func dropDatabaseData() {
    let realm = try! Realm()
    try! realm.write {
      realm.deleteAll()
    }
  }
  
  func setTestDbData() {
    let realm = try! Realm()
    
    try! realm.write { () -> Void in
      for _ in 1..<10 {
        realm.create(HelpRequest)
      }
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
//  
//  func loadApiToken() {
//    if let token = NSUserDefaults.standardUserDefaults().objectForKey("apiToken") as? String {
//      ServerManager.sharedInstance.apiToken = token
//    }
//  }
  
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

