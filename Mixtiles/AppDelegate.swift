//
//  AppDelegate.swift
//  Mixtiles
//
//  Created by viprak-Dipak on 27/08/18.
//  Copyright © 2018 viprak-Dipak. All rights reserved.
//  25_10_2018_Dipak last all issues fix

import UIKit
import IQKeyboardManagerSwift
import UserNotifications
import Firebase
import FBSDKCoreKit
import AppseeAnalytics
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate,OSSubscriptionObserver {

    var window: UIWindow?

     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKSettings.setAutoLogAppEventsEnabled(true)
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        Appsee.start()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses = [UIScrollView.self, UIView.self]
        initFreshchatSDK()
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "e3e84384-8ad6-41f0-b93f-15f60c33c1eb",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        OneSignal.add(self as OSSubscriptionObserver)
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
                
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        application.registerForRemoteNotifications()
        lanCode = "pt-BR"
        
        return true
    }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            UserDefaults.standard.setValue(stateChanges.to.userId, forKey: "onesignalUID")
            print(stateChanges.to.userId)
        }
    }

    func initFreshchatSDK() {
        //Dharmik
//        let freshchatConfig : FreshchatConfig = FreshchatConfig.init(appID: "2f0f6aae-9d46-4a4b-be31-90f1565ded44", andAppKey: "bd0ba7f4-fc75-47b2-8af7-571a3bc0934f")
        
        let freshchatConfig : FreshchatConfig = FreshchatConfig.init(appID: "26afb2ef-2666-431b-bb64-6d3b3dbddb8d", andAppKey: "a94ea6b9-bef0-45d1-90df-363beed530c2")
        
        freshchatConfig.gallerySelectionEnabled = true;
        freshchatConfig.cameraCaptureEnabled = true;
        freshchatConfig.teamMemberInfoVisible = true;
        freshchatConfig.showNotificationBanner = true;
        freshchatConfig.themeName = "FCTheme.plist"
        freshchatConfig.stringsBundle = "FCCustomLocalization"
        Freshchat.sharedInstance().initWith(freshchatConfig)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("APNs device token: \(deviceTokenString)")
        
        Freshchat.sharedInstance().setPushRegistrationToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if Freshchat.sharedInstance().isFreshchatNotification(userInfo) {
            Freshchat.sharedInstance().handleRemoteNotification(userInfo, andAppstate: application.applicationState)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        if Freshchat.sharedInstance().isFreshchatNotification(notification.request.content.userInfo) {
            Freshchat.sharedInstance().handleRemoteNotification(notification.request.content.userInfo, andAppstate: UIApplication.shared.applicationState)
        }
        else{
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if Freshchat.sharedInstance().isFreshchatNotification(response.notification.request.content.userInfo){
             Freshchat.sharedInstance().handleRemoteNotification(response.notification.request.content.userInfo, andAppstate: UIApplication.shared.applicationState) //Handled for freshchat notifications
        }
        else{
            completionHandler()//For other notifications
        }
    }
    
    class NotificationService: UNNotificationServiceExtension {
        
        var contentHandler: ((UNNotificationContent) -> Void)?
        var receivedRequest: UNNotificationRequest!
        var bestAttemptContent: UNMutableNotificationContent?
        
        override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
            self.receivedRequest = request;
            self.contentHandler = contentHandler
            bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
            
            if let bestAttemptContent = bestAttemptContent {
                OneSignal.didReceiveNotificationExtensionRequest(self.receivedRequest, with: self.bestAttemptContent)
                contentHandler(bestAttemptContent)
            }
        }
        
        override func serviceExtensionTimeWillExpire() {
            // Called just before the extension will be terminated by the system.
            // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
            if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
                OneSignal.serviceExtensionTimeWillExpireRequest(self.receivedRequest, with: self.bestAttemptContent)
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    func getUserDetails() -> NSMutableArray {
        
        if let userData = UserDefaults.standard.object(forKey: keyarymain) as? Data{
            let arySelect = NSKeyedUnarchiver.unarchiveObject(with: userData) as! NSArray
            let arySelected = NSMutableArray(array: arySelect)
            return arySelected
        }
        else {
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
        NotificationCenter.default.post(name: Notification.Name("UserLoggedIn"), object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
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

