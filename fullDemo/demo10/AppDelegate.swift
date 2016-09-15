//
//  AppDelegate.swift
//  demo10
//
//  Created by pwilkniss on 8/16/16.
//  Copyright © 2016 CleverTap. All rights reserved.
//

import UIKit
import UserNotifications
import SharedManager
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    
    var window: UIWindow?
    
    private lazy var sharedManager: SharedManager = {
        let appGroupName = Bundle.main.infoDictionary?["appGroupName"] as! String
        return SharedManager(forAppGroup: appGroupName)
    }()
    
    private lazy var cleverTap: CleverTap = CleverTap.sharedInstance()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // set up CleverTap
        CleverTap.setDebugLevel(1277182231)
        CleverTap.autoIntegrate()
        
        // demo: storing userId in shared group for app extension access
        let userId = "123456"
        sharedManager.userId = "123456"
        
        // demo: identify the user on the CleverTap profile
        cleverTap.onUserLogin(["Identity":userId])
        
        // demo: grab the last push received saved by the Notification Service to the shared group user defaults for use here
        if let lastPush = sharedManager.lastPushNotification {
            print("last push received: \(lastPush)")
        }
        
        // demo: Watch session
        if WCSession.isSupported() {
            let session = WCSession.default()
            session.delegate = self
            session.activate()
        }
        
        // register for push notifications on next tick
        DispatchQueue.main.async {
            self.registerPush()
        }
        
        return true
    }
    
    private func registerPush() {
        // register category with actions
        let accept = UNNotificationAction(identifier: "accept", title: "Accept", options: [])
        let decline = UNNotificationAction(identifier: "decline", title: "Decline", options: [])
        let dismiss = UNNotificationAction(identifier: "dismiss", title: "Dismiss", options: [])
        let category = UNNotificationCategory(identifier: "map", actions: [accept, decline, dismiss], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        // request permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) {
            (granted, error) in
            if (granted) {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("open url \(url)")
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("did receive remote notification \(userInfo)")
        completionHandler(.noData)
    }
    
    //MARK: WCSessionDelegate
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // no-op for demo purposes
    }
    
    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        // no-op for demo purposes
    }
    
    
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
        // no-op for demo purposes
    }
    
    /** Called on the delegate of the receiver. Will be called on startup if the incoming message caused the receiver to launch. */
    @available(iOS 9.0, *)
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let handled = cleverTap.handleMessage(message, forWatch: session)
        if (!handled) {
            // handle the message as its not a CleverTap Message
        }
    }
    
    /** Called on the delegate of the receiver when the sender sends a message that expects a reply. Will be called on startup if the incoming message caused the receiver to launch. */
    @available(iOS 9.0, *)
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void) {
        let handled = cleverTap.handleMessage(message, forWatch: session)
        if (!handled) {
            // handle the message as its not a CleverTap Message
        }
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

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

