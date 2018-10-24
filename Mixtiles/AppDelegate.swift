//
//  AppDelegate.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 27/08/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.statusBarStyle = .lightContent
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().toolbarPreviousNextAllowedClasses = [UIScrollView.self, UIView.self]
        self.initFreshchatSDK()
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        application.registerForRemoteNotifications()
        let langStr = Locale.current.languageCode
        
        lanCode = "pt-BR"
        
        return true
    }

    func initFreshchatSDK() {
        let freshchatConfig : FreshchatConfig = FreshchatConfig.init(appID: "26afb2ef-2666-431b-bb64-6d3b3dbddb8d", andAppKey: "a94ea6b9-bef0-45d1-90df-363beed530c2")
        
//        let freshchatConfig : FreshchatConfig = FreshchatConfig.init(appID: "f391fcdc-8b65-4a7a-810b-3d77b3bc4628", andAppKey: "35a88418-d9a9-4dbc-b56f-813550bb1063")
        
        freshchatConfig.gallerySelectionEnabled = true; // set NO to disable picture selection for messaging via gallery
        freshchatConfig.cameraCaptureEnabled = true; // set NO to disable picture selection for messaging via camera
        freshchatConfig.showNotificationBanner = true; // set to NO if you don't want to show the in-app notification banner upon receiving a new message while the app is open
        
        freshchatConfig.themeName = "FCTheme.plist"
        Freshchat.sharedInstance().initWith(freshchatConfig)
        
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Freshchat.sharedInstance().setPushRegistrationToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if Freshchat.sharedInstance().isFreshchatNotification(userInfo) {
            Freshchat.sharedInstance().handleRemoteNotification(userInfo, andAppstate: application.applicationState)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if Freshchat.sharedInstance().isFreshchatNotification(notification.request.content.userInfo){
            Freshchat.sharedInstance().handleRemoteNotification(notification.request.content.userInfo, andAppstate: UIApplication.shared.applicationState)
        }else{
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if Freshchat.sharedInstance().isFreshchatNotification(response.notification.request.content.userInfo){
             Freshchat.sharedInstance().handleRemoteNotification(response.notification.request.content.userInfo, andAppstate: UIApplication.shared.applicationState) //Handled for freshchat notifications
        }else{
            completionHandler()//For other notifications
        }
    }
    func getUserDetails() -> NSMutableArray
    {
//        if defaults.value(forKey: keyarymain) != nil{
//            let userData = defaults.value(forKey: keyarymain) as! NSArray
//           let arySelected = NSMutableArray(array: userData)
//            return arySelected
//        }else{
//            return []
//        }
        if let userData = UserDefaults.standard.object(forKey: keyarymain) as? Data{
            let arySelect = NSKeyedUnarchiver.unarchiveObject(with: userData) as! NSArray
            let arySelected = NSMutableArray(array: arySelect)
            return arySelected

        }else{
            return []
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
        var freahchatUnreadCount = Int()
        Freshchat.sharedInstance().unreadCount { (unreadCount) in
            freahchatUnreadCount = unreadCount
        }
        UIApplication.shared.applicationIconBadgeNumber = freahchatUnreadCount;
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

