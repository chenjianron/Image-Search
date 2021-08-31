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

func showNetworkErrorAlert(_ container: UIViewController){
    let alertController = UIAlertController(title: nil,message: __("网络超时，请重试"),preferredStyle: .alert)
    container.present(alertController,animated: true,completion: nil)
    
    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (ktimer) in
        container.dismiss(animated: true, completion: nil)
    }
}

func showActivityIndicatory(containView: UIView,loadingView: UIView){
//    let container: UIView = UIView()
//    container.frame = CGRect(x: 0, y: 0, width: fullScreenSize.width, height: fullScreenSize.height)
//    container.center = container.center
//    container.backgroundColor = UIColor(hex: 0xffffff, alpha: 0.4)
    loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
    loadingView.center = containView.center
    loadingView.backgroundColor = UIColor(hex: 0x444444, alpha: 0.7)
    loadingView.clipsToBounds = true
    loadingView.layer.cornerRadius = 10
    
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
    actInd.style =
        UIActivityIndicatorView.Style.whiteLarge
    actInd.center = CGPoint(x: loadingView.frame.size.width / 2,
                            y: loadingView.frame.size.height / 2);
    
    loadingView.addSubview(actInd)
//    container.addSubview(loadingView)
    loadingView.isHidden = false
    containView.addSubview(loadingView)
//    containView.addSubview(container)
    actInd.startAnimating()
}
