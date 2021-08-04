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
        // Override point for customization after application launch.
        //         建立一個 UIWindow
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

        return true
    }


}

