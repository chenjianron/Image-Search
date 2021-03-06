//
//  Constants.swift
//  PasteKeyboard
//
//  Created by Coloring C on 2021/6/7.
//

import Foundation

let fullScreenSize = UIScreen.main.bounds.size


var urlSearchEngineUrlPrefix: [String]{
    if inChina(){
        return
            ["https://yandex.com/images/search?family=yes&rpt=imageview&url=",
            "https://pic.sogou.com/ris?query=",
            "https://www.bing.com/images/search?view=detailv2&iss=sbi&form=SBIHMP&sbisrc=UrlPaste&q=imgurl:"
            ]
    } else {
        return ["https://www.google.com.hk/searchbyimage?image_url=",
                "https://yandex.com/images/search?family=yes&rpt=imageview&url=",
                "https://www.bing.com/images/search?view=detailv2&iss=sbi&form=SBIHMP&sbisrc=UrlPaste&q=imgurl:",
                ]
    }
}
var urlSearchEngineName:[String]{
    if inChina() {
        return ["Yandex","Sougou","Bing"]
    } else {
        return ["Google","Yandex","Bing"]
    }
}
var urlSearchEngineSource :[String] {
    if inChina() {
        return [ "https://yandex.com/","https://www.sogou.com/","https://www.bing.com/" ]
    } else {
        return [
            "https://yandex.com/","https://www.bing.com/" ,"https://www.google.com/"
        ]
    }
}
var keywordSearchEngineUrlPrefix :[String] {
    if inChina() {
        return ["https://yandex.com/images/search?from=tabbar&text=",
                "https://pic.sogou.com/pic/searchList.jsp?uID=&v=5&statref=index_form_1&spver=0&rcer=&keyword=",
                "https://cn.bing.com/images/search?q="
            ]
    } else {
        return ["https://www.google.com/search?q=","&tbm=isch",
                "https://yandex.com/images/search?from=tabbar&text=",
                "https://cn.bing.com/images/search?q="
        ]
    }
}
var keywordSearchEngineUrlName:[String] {
    if inChina(){
        return ["Yandex","Sougou","Bing"]
    }else {
        return ["Google","Yandex","Bing"]
    }
}
var keywordSearchEngineSource :[String] {
    if inChina() {
        return [ "https://yandex.com/","https://www.sogou.com/","https://www.bing.com/" ]
    } else {
        return [
            "https://yandex.com/","https://www.bing.com/" ,"https://www.google.com/"
        ]
    }
}

struct K {
    struct IDs {
        
        static let AppID = "1571453641"
        //        static let GroupName = "group.com.softin.ScreenRecorder3"
        static let UMengKey = "60c069791568bb08a5be664b"
        
        static let SSID = "a4nrtddq1cw64lr8"
        static let SSKey = "obcqxzk6dtsardn4"
        static let SSRG = "oss-cn-hongkong"
        
        static let Secret = "ImageSearch/\(Util.appVersion())/meto.otf"
        static let adMobAppId = "ca-app-pub-1526777558889812~7180568285"
        
        //        #if DEBUG
        //        static let BannerUnitID = "ca-app-pub-1526777558889812/1928241607"
        //        static let InterstitialUnitID = "ca-app-pub-1526777558889812/3463016257"
        //        static let InterstitialTransferUnitID = "ca-app-pub-1526777558889812/7318786197"
        //        static let RewardUnitID = "ca-app-pub-3940256099942544/1712485313"
        
        //        #else
        //        static let BannerUnitID = "ca-app-pub-1526777558889812/1928241607"
        //        static let InterstitialUnitID = "ca-app-pub-1526777558889812/3463016257"
        //        static let InterstitialSaveUnitID = "ca-app-pub-1526777558889812/2930324944"
        //        static let InterstitialTransferUnitID = "ca-app-pub-1526777558889812/7318786197"
        //        static let RewardUnitID = "ca-app-pub-1526777558889812/5423421726"
        //        #endif
        
        //        #if DEBUG
        static let BannerUnitID = "ca-app-pub-3940256099942544/2934735716"
        static let InterstitialUnitID = "ca-app-pub-3940256099942544/4411468910"
        static let InterstitialTransferUnitID = "ca-app-pub-3940256099942544/4411468910"
        static let RewardUnitID = "ca-app-pub-3940256099942544/1712485313"
        //        #else
        //           static let BannerUnitID = "ca-app-pub-1526777558889812/7898692549"
        //           static let InterstitialUnitID = "ca-app-pub-1526777558889812/4626549998"
        //           static let InterstitialSaveUnitID = "ca-app-pub-1526777558889812/2930324944"
        //           static let InterstitialTransferUnitID = "ca-app-pub-1526777558889812/5423421726"
        //    //        static let RewardUnitID = "ca-app-pub-1526777558889812/5423421726"
        //        #endif
        
        
        
    }
    
    struct Share {
        static let normalContent = String(format: "https://itunes.apple.com/cn/app/id%@?mt=8&l=%@", K.IDs.AppID, Util.languageCode())
        static let Email = "Image_Search_feedback@outlook.com"
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
        
        static let IDFA_Time = "S.Ad.??????????????????????????????"
        static let IDFA_Count = "S.Ad.??????????????????????????????"
        
        static let HomePageBanner = "S.Ad.??????" // ???????????????????????????
        static let SettingPageBanner = "S.Ad.?????????" // ??????????????????????????????
        static let SearchRecordBanner = "S.Ad.???????????????" // ????????????????????????????????????
        static let WebBanner = "S.Ad.????????????" //???????????????????????????????????????
        
        static let LaunchInterstitial = "p1-1" // ???N???????????????????????????
        static let SwitchInterstitial = "p1-2" // ???N?????????????????????????????????
        static let PickerInterstitial = "p1-3"
        static let CameraInterstitial = "p1-4"
        static let URLInterstitial = "p1-5"
        static let KeywordInterstitial = "p1-7"
        static let SaveImageInterstitial = "p1-8"
        static let DeleteImageInterstitial = "p1-9"
        static let SearchImageInterstitial = "p1-10"
        
        static let ShareRT = "p2-1" //??????????????????????????????
        static let ImagePickerRT = "p2-2" //???????????????
        static let LauchAPPRT = "p2-3" //??????/??????????????????
        
        static let pushAlertDays = "p3-1" // ????????????????????????????????????N????????????????????????
        static let RTTime = "p3-0"  //??????????????????
        //        static let saveRT = "p3-2" //???????????????
        static let EnterRT = "p3-3" //??????/??????????????????
        
    }
}
