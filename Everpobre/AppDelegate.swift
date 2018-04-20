//
//  AppDelegate.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 10/03/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Notebook.createDefaultIfNotExist()
        
        window = UIWindow()
        window?.rootViewController = MasterViewController()
        window?.makeKeyAndVisible()
        
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .badge, .sound];
        center.requestAuthorization(options: options) {
            (granted, error) in
            
            if !granted {
                print("Something went wrong")
            }
        }
        
        return true
    }
}

