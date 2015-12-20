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
    configureServerManager()
    
    let navigation: UINavigationController
    
    if !ServerManager.sharedInstance.authenticated {
      let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
      let loginViewController = loginStoryboard.instantiateInitialViewController()!
      navigation = UINavigationController(rootViewController: loginViewController)
    } else {
      let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
      let homeViewController = mainStoryboard.instantiateInitialViewController()!
      navigation = UINavigationController(rootViewController: homeViewController)
    }

    window?.rootViewController = navigation
    
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
    } else {
//      manager.apiToken = "foobar"
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
    UINavigationBar.appearance().tintColor = UIColor.orangeSecondaryColor()
  }

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

