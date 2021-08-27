//
//  AppDelegate.swift
//  Image_Search
//
//  Created by GC on 2021/8/2.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate { 

    var window:UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame:
          UIScreen.main.bounds)
        // 設置底色
        self.window!.backgroundColor = UIColor(red: 19/255, green: 165/255, blue: 255/255, alpha: 1)
        // 設置根視圖控制器
        let nav = UINavigationController(
          rootViewController: MainViewController())
//        let nav = CCNavigationController(rootViewController: MainViewController())
        self.window!.rootViewController = nav
        // 將 UIWindow 設置為可見的
        self.window!.makeKeyAndVisible()
        Marketing.shared.setup()
        AppTracking.shared.requestIDFA()
        setupNotification(launchOptions: launchOptions)
        return true
    }

}

// MARk: -友盟推送

extension AppDelegate {
    
    func setupNotification(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        UIApplication.shared.applicationIconBadgeNumber = 0
   
        let entity = UMessageRegisterEntity()
        entity.types = Int(UMessageAuthorizationOptions.alert.rawValue)
               | Int(UMessageAuthorizationOptions.sound.rawValue)
               | Int(UMessageAuthorizationOptions.badge.rawValue)
           
        UMessage.registerForRemoteNotifications(launchOptions: launchOptions, entity: entity, completionHandler: { (granted, error) in
            LLog("推送: ", granted)
            if let error = error {
                LLog(error.localizedDescription)
           }
        })
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       UMessage.registerDeviceToken(deviceToken)
       
       #if DEBUG
       print(#function, "deviceToken", NotificationHandler.deviceToken(deviceToken) ?? "")
       #endif
   }
   
   func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        LLog(error)
    }
   
   func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationHandler.process(userInfo: userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NotificationHandler.process(userInfo: userInfo)
    }
}

