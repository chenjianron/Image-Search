//
//  Constants.swift
//  PasteKeyboard
//
//  Created by Coloring C on 2021/6/7.
//

import Foundation

struct K {
    struct IDs {
        static let AppID = "1571453641"
        
//        static let GroupName = "group.com.softin.ScreenRecorder3"
        
        static let UMengKey = "60c069791568bb08a5be664b"
        
        static let SSID = "a4nrtddq1cw64lr8"
        static let SSKey = "obcqxzk6dtsardn4"
        static let SSRG = "oss-cn-hongkong"
        static let Secret = "ImageSearch/\(Util.appVersion())/meto.otf"


        
        
        static let adMobAppId = "ca-app-pub-1526777558889812~4626302572"
        
//        #if DEBUG
        static let BannerUnitID = "ca-app-pub-3940256099942544/2934735716"
        static let InterstitialUnitID = "ca-app-pub-3940256099942544/4411468910"
        static let InterstitialTransferUnitID = "ca-app-pub-3940256099942544/4411468910"
//        static let RewardUnitID = "ca-app-pub-3940256099942544/1712485313"
//        #else
//        static let BannerUnitID = "ca-app-pub-1526777558889812/7898692549"
//        static let InterstitialUnitID = "ca-app-pub-1526777558889812/4626549998"
//        static let InterstitialSaveUnitID = "ca-app-pub-1526777558889812/2930324944"
//        static let InterstitialTransferUnitID = "ca-app-pub-1526777558889812/5423421726"
////        static let RewardUnitID = "ca-app-pub-1526777558889812/5423421726"
//        #endif
        

    }
    
    struct Share {
        static let normalContent = String(format: "https://itunes.apple.com/cn/app/id%@?mt=8&l=%@", K.IDs.AppID, Util.languageCode())
        static let Email = "pastekeyboard_feedback@outlook.com"
    }
    
    struct Website {
        static let PrivacyPolicy = "https://websprints.github.io/PasteKeyboard/PrivacyPolicy.html"
        static let UserAgreement = "https://websprints.github.io/PasteKeyboard/UserAgreement.html"
    }
    
    struct Color {
        static let Black222222 = UIColor(hex: 0x222222)
        static let Black181818 = UIColor(hex: 0x181818)
        static let Gray666666 = UIColor(hex: 0x666666)
        static let GrayBBBBBB = UIColor(hex: 0xBBBBBB)
        static let GrayF5F5F5 = UIColor(hex: 0xF5F5F5)
        static let Blue3F84F9 = UIColor(hex: 0x3F84F9)
    }
    
    struct ParamName {
        
        static let EnterForegroundInterstitial = "p1-2" // 每N次进入前台弹出插屏广告
        
        static let saveInterstitial = "p1-3" //每N次连接成功插屏
        static let deleteInterstitial = "p1-4"  // 每N次分享插屏


        static let pushAlertDays = "p2-1" // 用户未允许通知提醒，每隔N天后弹出通知提醒
        
        static let RTTime = "p3-0"  //评论间隔小时
        static let saveRT = "p3-2" //保存后弹窗
        static let EnterRT = "p3-3" //启动/返回应用弹窗
        
        static let IDFA_Time = "S.Ad.广告跟踪二次弹窗时间"
        static let IDFA_Count = "S.Ad.广告跟踪二次弹窗次数"
        
        static let HomePageBanner = "S.Ad.首页" // 首页广告栏控制开关
        static let SettingPageBanner = "S.Ad.设置页" // 设置页广告栏控制开关
        static let SearchRecordBanner = "S.Ad.搜索记录页" // 搜索记录页广告栏控制开关
        static let WebBanner = "S.Ad.浏览器页" //浏览器网页面广告栏控制开关
        
        static let LaunchInterstitial = "p1-1" // 每N次启动弹出插屏广告
        static let SwitchInterstitial = "p1-2" // 每N次进入前台弹出插屏广告
        
        static let PickerInterstitial = "p1-3"
        static let CameraInterstitial = "p1-4"
        static let URLInterstitial = "p1-5"
        static let KeywordInterstitial = "p1-7"
        static let SaveImageInterstitial = "p1-8"
        static let DeleteImageInterstitial = "p1-9"
        static let SearchImageInterstitial = "p1-10"
        
        static let ShareRT = "p2-1" //分享后返回设置页弹窗
        static let ImagePickerRT = "p2-2" //保存后弹窗
        static let LauchAPPRT = "p2-3" //启动/返回应用弹窗
        
    }
}
