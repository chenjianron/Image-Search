//
//  Helper.swift
//  SplitScreen
//
//  Created by  HavinZhu on 2020/8/17.
//  Copyright © 2020 HavinZhu. All rights reserved.
//

func inChina() -> Bool {
    let standard = UserDefaults.standard
    let allLanguages: [String] = standard.object(forKey: "AppleLanguages") as! [String]
    let currentLanguage = allLanguages.first ?? ""
    return currentLanguage.contains("zh")
}

func getRootViewController() -> UIViewController? {
    if let window = UIApplication.shared.delegate?.window {
        if let rootViewController = window?.rootViewController {
            return rootViewController
        }
    }
    return nil
}
