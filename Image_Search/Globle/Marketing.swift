//
//  Marketing.swift
//  Remote
//
//  Created by Coloring C on 2021/3/23.
//

import Foundation
import StoreKit
import SwiftyJSON
import AdLib
import MarketingHelper

class BannerWrap {
    let presetKey: String
    let homeKey: String
    var view: UIView?
    
    init(presetKey: String, homeKey: String) {
        self.presetKey = presetKey
        self.homeKey = homeKey
    }
}

enum Banner {
    case homeBanner
    case settingBanner
    case searchRecordBanner
    case webBanner
}



class Marketing {
    
    static let shared = Marketing()
    
    private var bannerViews: [Banner : BannerWrap] = [:]

    
    func setup() {
        
        UMConfigure.initWithAppkey(K.IDs.UMengKey, channel: "App Store")
        RT.default.setup(appID: K.IDs.AppID)
        
        JSON.setupPMs(id: K.IDs.SSID,
                      key: K.IDs.SSKey ,
                      region: K.IDs.SSRG,
                      secret: K.IDs.Secret)

        Preset.default.setup(defaults: [
                                        K.ParamName.IDFA_Count: 0,
                                        K.ParamName.IDFA_Time: 72,
                                        
                                        K.ParamName.HomePageBanner : 1,
                                        K.ParamName.SettingPageBanner : 1,
                                        K.ParamName.SearchRecordBanner : 1,
                                        K.ParamName.WebBanner:1,
                                        
                                        K.ParamName.LaunchInterstitial : 5,
                                        K.ParamName.SwitchInterstitial : 5,
                                        K.ParamName.PickerInterstitial : 10,
                                        K.ParamName.CameraInterstitial: 10,
                                        K.ParamName.URLInterstitial: 10,
                                        K.ParamName.KeywordInterstitial: 10,
                                        K.ParamName.SaveImageInterstitial:10,
                                        K.ParamName.DeleteImageInterstitial:10,
                                        K.ParamName.SearchImageInterstitial:10,
                                        
                                        K.ParamName.ShareRT: 1,
                                        K.ParamName.ImagePickerRT: 5,
                                        K.ParamName.LauchAPPRT: 2,
       ])
        
        MarketingHelper.presentUpdateAlert()

        Ad.default.setup(bannerUnitID: K.IDs.BannerUnitID, interstitialUnitID: K.IDs.InterstitialUnitID, openAdUnitID: nil, rewardAdUnitID: nil, isEnabled: true)

        
        let view = SimpleLoadingView(logo: UIImage.icon)
        view.backgroundColor = .white
        view.logoImageView.snp.remakeConstraints { (make) in
            let width = min(UIScreen.main.bounds.size.width * 0.25, 120)
            make.width.height.equalTo(Util.isIPad ? width : 72)
            make.center.equalToSuperview()
        }
        view.logoImageView.layer.cornerRadius = 16
        view.loadingLabel.text = nil
        Ad.default.setupLaunchInterstitial(launchKey: K.ParamName.LaunchInterstitial, enterForegroundKey: K.ParamName.SwitchInterstitial, loadingView: view)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didLaunchOrEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        didLaunchOrEnterForeground()
        
        bannerViews[.homeBanner] = .init(presetKey: K.ParamName.HomePageBanner, homeKey: K.ParamName.HomePageBanner)
        bannerViews[.settingBanner] = .init(presetKey: K.ParamName.SettingPageBanner, homeKey: K.ParamName.SettingPageBanner)
        bannerViews[.searchRecordBanner] = .init(presetKey: K.ParamName.SearchRecordBanner, homeKey: K.ParamName.SearchRecordBanner)
        bannerViews[.webBanner] = .init(presetKey: K.ParamName.WebBanner, homeKey: K.ParamName.WebBanner)
    }
    
    
    func bannerView(_ type: Banner, rootViewController: UIViewController) -> UIView? {
        guard let wrap: BannerWrap = bannerViews[type] else { return nil }
        if wrap.view == nil && Preset.named(wrap.presetKey).boolValue {
            wrap.view = Ad.default.createBannerView(rootViewController: rootViewController, houseAdID: wrap.homeKey)
        }
        return wrap.view
    }
}

extension Marketing {
    
    func showNotificationIfNeed() {
        
        let counter = Counter.find(key: K.ParamName.pushAlertDays)
        counter.increase()
        if counter.hitsMax && Preset.default.named(K.ParamName.pushAlertDays)["title"].stringValue.count > 0 {
            showNotifcationAlert(from: Util.topViewController(), data: Preset.named(K.ParamName.pushAlertDays))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let d = Preset.named(K.ParamName.pushAlertDays).intValue
            let interval = 24 * 60 * 60 * d
            counter.limitsHitsMaxUntilDate = Date().addingTimeInterval(TimeInterval(interval))
        }
    }
    
    // MARK: - 评论
    @objc func didLaunchOrEnterForeground() {

        let rtCounter = Counter.find(key: K.ParamName.EnterRT)
        rtCounter.increase()
        
        if !RT.default.hasUserRTed && rtCounter.hitsMax {
            SKStoreReviewController.requestReview()
            rtCounter.limitsHitsMaxUntilDate = Date().addingTimeInterval(TimeInterval(60 * 60 * Preset.named(K.ParamName.RTTime).intValue))
        }
    }

    
    func didShareRT() {
        let rtCounter = Counter.find(key: K.ParamName.ShareRT)
        rtCounter.increase()
        
        if !RT.default.hasUserRTed && rtCounter.hitsMax {
            SKStoreReviewController.requestReview()
            rtCounter.limitsHitsMaxUntilDate = Date().addingTimeInterval(TimeInterval(60 * 60 * Preset.named(K.ParamName.RTTime).intValue))
        }
    }
    
    func didImagePickerRT() {
        let rtCounter = Counter.find(key: K.ParamName.ImagePickerRT)
        rtCounter.increase()
        
        if !RT.default.hasUserRTed && rtCounter.hitsMax {
            SKStoreReviewController.requestReview()
            rtCounter.limitsHitsMaxUntilDate = Date().addingTimeInterval(TimeInterval(60 * 60 * Preset.named(K.ParamName.RTTime).intValue))
        }
    }
    
    
    @objc func didLauchAPPRT() {
        let rtCounter = Counter.find(key: K.ParamName.LauchAPPRT)
        rtCounter.increase()
        
        if !RT.default.hasUserRTed && rtCounter.hitsMax {
            SKStoreReviewController.requestReview()
            rtCounter.limitsHitsMaxUntilDate = Date().addingTimeInterval(TimeInterval(60 * 60 * Preset.named(K.ParamName.RTTime).intValue))
        }
    }
    

    
    
}

// MARK: - helper
extension Marketing {
    
    public func showNotifcationAlert(from controller: UIViewController, data: JSON) {
        
        let title = data["title"].stringValue
        
        let appName = Util.appName()
        let messageFormat = data["message"].stringValue
        let message = String.init(format: messageFormat, appName, appName, appName, appName, appName)
        
        let ok = data["ok"].stringValue
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let cancel = data["cancel"].string {
            alert.addAction(UIAlertAction(title: cancel, style: .cancel, handler: { (action) in
                
            }))
        }
        
        alert.addAction(UIAlertAction(title: ok, style: .default, handler: { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString){
                if (UIApplication.shared.canOpenURL(url)){
                    UIApplication.shared.open(url, options: [:]) { (success) in}
                }
            }
        }))
        
        controller.present(alert, animated: true, completion: nil)
    }
}
