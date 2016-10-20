//
//  AppDelegate.swift
//  Flare
//
//  Created by Georgia Mills on 06/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var storyboard: UIStoryboard?
    var notificationFlareId: String?
       
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Remove badge when app is launched
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Check if launched from notification
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            notificationFlareId = notification["flare"] as! String?
        }
        
        // Register for notifications
        if #available(iOS 8.0, *) {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            let types: UIRemoteNotificationType = [.alert, .badge, .sound]
            application.registerForRemoteNotifications(matching: types)
        }
        
        FIRApp.configure()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification(notification:)), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        determineAndSetView()
        return true
    }
    
    
//    func application(_ application: UIApplication,
//                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
//    {
//        FIRInstanceID.instanceID().setAPNSToken(deviceToken as Data, type: FIRInstanceIDAPNSTokenType.prod)
//    }
    
//    func currentUserView() {
//        self.storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let currentUser = FIRAuth.auth()?.currentUser
//        if currentUser != nil {
//            self.window?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "mapView")
//        } else {
//            self.window?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "rootView")
//        }
//    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(application, open: url as URL!, sourceApplication: sourceApplication, annotation: annotation)
        // Add any custom logic here.
        return handled
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        FIRMessaging.messaging().disconnect()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        connectToFCM()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func tokenRefreshNotification(notification: NSNotification) {
        let refreshedToken = FIRInstanceID.instanceID().token()
        print("instanceID token: \(refreshedToken)")
        connectToFCM()
    }
    
    func connectToFCM() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect to fcm \(error)")
            } else {
                print("Connected to FCM")
            }
        }
    }
    
    func determineAndSetView() {
        self.storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let currentUser = FIRAuth.auth()?.currentUser
        if currentUser != nil {
            let controller = storyboard?.instantiateViewController(withIdentifier: "mapView") as! MapViewController
            if notificationFlareId != nil {
              controller.notificationFlareId = notificationFlareId
            }
            self.window?.rootViewController = controller
        } else {
            self.window?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "rootView")
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (_ result: UIBackgroundFetchResult) -> Void) {
        
        print("RECEIVED NOTIFICATION")
        let state = application.applicationState
        
        if state == .background || state == .inactive {
            print("Background or Inactive State")
            notificationFlareId = userInfo["flare"] as! String?
            determineAndSetView()
            UIApplication.shared.applicationIconBadgeNumber = 0
            completionHandler(.newData)

        } else {
            //Show an in-app banner
            print("Active State")
            completionHandler(.newData)

        }
    }
    
    
}

