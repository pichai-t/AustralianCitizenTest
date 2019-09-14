//
//  AppDelegate.swift
//  Australian Citizenship Test
//
//  Created by Pichai Tangtrongsakundee on 7/5/19.
//  Copyright © 2019 Pichai Tangtrongsakundee. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        loadRealmInstance()
        return true
    }

    private func loadRealmInstance() {
        let pathx = Bundle.main.path(forResource: "act", ofType: "realm")
        let defaultPath = Realm.Configuration.defaultConfiguration.fileURL!.path.replacingOccurrences(of: "default", with: "act")
        
        print ("Path: \(defaultPath)")
        let bundledPath = pathx
        
        // If file exists, but the size is too small, to replace it
        if FileManager.default.fileExists(atPath: defaultPath) {
            let actFileSize = try! FileManager.default.attributesOfItem(atPath: defaultPath)[FileAttributeKey.size]
            if (actFileSize as! Int) < 300000 {
                do {
                    try FileManager.default.removeItem(atPath: defaultPath)
                    try FileManager.default.copyItem(atPath: bundledPath!, toPath: defaultPath)
                    } catch {
                        print("Error copying pre-populated Realm Database\(error)")
                    }
                    //exit(0) // Restart the application to re-connect to the newly loaded database instance
                }
            
        } else { // if file does not exist, just copy it.
            do {
                // try FileManager.default.removeItem(atPath: defaultPath)
                try FileManager.default.copyItem(atPath: bundledPath!, toPath: defaultPath)
            } catch {
                print("Error copying pre-populated Realm Database\(error)")
            }
            //exit(0) // Restart the application to re-connect to the newly loaded database instance
        }

        let config = Realm.Configuration(fileURL: URL(string: defaultPath), readOnly: false)
        _ = try! Realm(configuration: config)
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    
}

