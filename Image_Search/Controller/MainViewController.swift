//
//  ViewController.swift
//  Image_Search
//
//  Created by GC on 2021/8/2.
//

import UIKit
import SnapKit
import Alamofire
import Toolkit
import WebKit
import Foundation

class MainViewController: UIViewController,UIGestureRecognizerDelegate, UINavigationControllerDelegate{
    
    let fullScreenSize = UIScreen.main.bounds.size
    
    var bannerView: UIView? {
        return Marketing.shared.bannerView(.homeBanner, rootViewController: self)
    }
    var bannerInset: CGFloat {
        if bannerView != nil {
            return Ad.default.adaptiveBannerHeight
        } else {
            return 0
        }
    }
    var headers: HTTPHeaders = [:]
    var isSelect = false
    
    var imagePicker:UIImagePickerController!
    var cameraPicker:UIImagePickerController!
    var loadingView: UIView!
    var image:Any!
    var isImage:Bool!
    
    lazy var dformatter:DateFormatter = {
        let dformatter = DateFormatter()
        dformatter.dateFormat = "MM-dd hh:mm:ss"
        return dformatter
    }()
    lazy var settingButton: UIBarButtonItem = {
        let settingButton = UIBarButtonItem(
            image: UIImage(named: "setting_icon_image")?.withRenderingMode(.alwaysOriginal),
            style:.plain ,
            target:self ,
            action: #selector(MainViewController.setting))
        return settingButton
    }()
    lazy var topBackgroundImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "background.png")
        return image
    }()
    lazy var searchImageView: UIImageView = {
        let searchImageView = UIImageView()
        searchImageView.image = UIImage(named: "index_search")
        return searchImageView
    }()
    lazy var appTitle: UILabel = {
        let appTitle = UILabel()
        appTitle.text = __("按图搜索")
        appTitle.font = UIFont(name: "Helvetica", size: 20)
        appTitle.textColor = UIColor.white
        return appTitle
    }()
    lazy var bottomBackgroundLabel: UIView = {
        let label = UIView()
        label.layer.cornerRadius = fullScreenSize.width / 20
        label.layer.masksToBounds = false
        label.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        if #available(iOS 13.0, *) {
            label.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
            // Fallback on earlier versions
        }
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.shadowOpacity = 0.3
        label.layer.shadowRadius = 8
        return label
    }()
    lazy var hintTitle: UILabel = {
        let hintTitle = UILabel()
        hintTitle.text = __("选择图片")
        hintTitle.font = UIFont(name: "Helvetica", size: 16)
        hintTitle.font = UIFont.boldSystemFont(ofSize: 16)
        return hintTitle
    }()
    lazy var imageSearchButton: ButtonView = {
        let searchButton = ButtonView()
        searchButton.dataSouce(title: __("图片"), image: "index_imageSearch")
        return searchButton
    }()
    lazy var cameraSearchButton: ButtonView = {
        let searchButton = ButtonView()
        searchButton.dataSouce(title: __("相机"), image: "index_cameraSearch")
        return searchButton
    }()
    lazy var fileSearchButton: ButtonView = {
        let searchButton = ButtonView()
        searchButton.dataSouce(title: __("文件"), image: "index_fileSearch")
        return searchButton
    }()
    lazy var urlSearchButton: ButtonView = {
        let searchButton = ButtonView()
        searchButton.dataSouce(title: __("图片url"), image: "index_imageUrlSearch")
        return searchButton
    }()
    lazy var keywordSearchButton: ButtonView = {
        let searchButton = ButtonView()
        searchButton.dataSouce(title: __("关键词"), image: "index_keywordSearch")
        return searchButton
    }()
    lazy var recordSearchButton: ButtonView = {
        let searchButton = ButtonView()
        searchButton.dataSouce(title: __("搜索记录"), image: "index_searchRecord")
        return searchButton
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupConstraints()
        self.setupAdBannerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Statistics.beginLogPageView("首页")
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 19/255, green: 165/255, blue: 255/255, alpha: 1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Statistics.endLogPageView("首页")
        super.viewWillDisappear(animated)
    }
}

//MARK: -
extension MainViewController {
    
    func showAnimate() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            UIView.animate(withDuration: 0.3) {
                //                self.view.backgroundColor = UIColor.init(hex: 0x000000, alpha: 0.3)
                let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
                alertController.modalPresentationStyle = .fullScreen
                alertController.view.isHidden = true
                self.present(alertController, animated: false, completion: nil)
            }
        }
    }
    
    func dismissAnimate(complete: @escaping () -> Void) {
        self.dismiss(animated: false, completion: complete)
    }
    
    func showNetworkErrorAlert(_ container: UIViewController){
        let alertController = UIAlertController(title: nil,message: __("网络超时，请重试"),preferredStyle: .alert)
        container.present(alertController,animated: true,completion: nil)
        
        self.loadingView.isHidden = true
        
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (ktimer) in
            container.dismiss(animated: true, completion: nil)
        }
    }
    
    func showActivityIndicatory(uiView: UIView) {
        //     var container: UIView = UIView()
        //     container.frame = uiView.frame
        //     container.center = uiView.center
        //        container.backgroundColor = UIColor(hex: 0xffffff, alpha: 0.3)
        loadingView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = uiView.center
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
        self.loadingView.isHidden = false
        uiView.addSubview(loadingView)
        actInd.startAnimating()
    }
    
    func cancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func setting(){
        self.navigationController?.pushViewController(SettingViewController(),animated: false)
    }
    
    @objc func imageSearch(){
        Statistics.beginLogPageView("相册页")
        Statistics.event(.HomePageTap, label: "图片")
        let ctx = Ad.default.interstitialSignal(key: K.ParamName.PickerInterstitial)
        ctx.didEndAction = { [self] _ in
            isImage = true
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.modalPresentationStyle = .fullScreen
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.isToolbarHidden = true
            present(self.imagePicker, animated: false, completion: nil)
        }
        
    }
    
    
    @objc func cameraSearch(){
        Statistics.beginLogPageView("拍照页")
        Statistics.event(.HomePageTap, label: "相机")
        let ctx = Ad.default.interstitialSignal(key: K.ParamName.CameraInterstitial)
        ctx.didEndAction = { [self] _ in
            isImage = false
            cameraPicker = UIImagePickerController()
            cameraPicker.delegate = self
            cameraPicker.modalPresentationStyle = .fullScreen
            cameraPicker.sourceType = UIImagePickerController.SourceType.camera
            cameraPicker.isToolbarHidden = true
            self.present(cameraPicker, animated: false, completion: nil)
        }
    }
    
    @objc func fileSearch(){
        Statistics.beginLogPageView("文件页")
        Statistics.event(.HomePageTap, label: "文件")
        let ctx = Ad.default.interstitialSignal(key: K.ParamName.PickerInterstitial)
        ctx.didEndAction = { [self] _ in
            let letdocumentTypes = ["public.PNG","public.JPEG"]
            let documentPicker = UIDocumentPickerViewController.init(documentTypes: letdocumentTypes, in: .open)
            documentPicker.modalPresentationStyle = .fullScreen
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
        }
    }
    
    @objc func urlSearch(){
        Statistics.event(.HomePageTap, label: "图片url")
        let urlEditWindowViewController = UrlViewController()
        urlEditWindowViewController.setType(type: "url")
        urlEditWindowViewController.setDelegate(delegate: self)
        self.present(urlEditWindowViewController, animated: false, completion: nil)
    }
    
    @objc func keywordSearch(){
        Statistics.event(.HomePageTap, label: "关键词")
        let keywordEditWindowViewController = UrlViewController()
        keywordEditWindowViewController.setType(type: __("关键词"))
        keywordEditWindowViewController.setDelegate(delegate: self)
        self.present(keywordEditWindowViewController, animated: false, completion: nil)
    }
    
    @objc func recordSearch(){
        Statistics.event(.HomePageTap, label: "搜索记录")
        self.navigationController?.pushViewController(SearchRecordViewController(),animated: false)
    }
    
    func goWebViewControllerFromUrlViewController(webViewController:WebViewController){
        self.navigationController?.pushViewController(webViewController,animated: false)
    }
    
    func camera(){
        headers = [
            "Content-type": "text/html; charset=GBK"
        ]
        if !isSelect {
            // 顯示進度條
            isSelect = true
            self.showActivityIndicatory(uiView: cameraPicker.view)
            IsolatedInteraction.shared.showAnimate(vc: cameraPicker)
            AF.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(((self.image as! UIImage?)!.jpegData(compressionQuality: 0.8))! , withName: "source", fileName: "search"+".jpeg", mimeType: "image/png")
            },  to: "http://pic.sogou.com/pic/upload_pic.jsp?", method: .post, headers: headers).responseString (){ [self] (result) in
                if let lastUrl = result.value{
                    Statistics.endLogPageView("拍照页")
                    SQL.insert(imagedata: (self.image as! UIImage?)!.jpegData(compressionQuality: 0.8)! as Data)
                    isSelect = false
                    IsolatedInteraction.shared.dismissAnimate(vc: cameraPicker) {
                        self.dismiss(animated: true, completion: nil)
                        let webViewController = WebViewController()
                        webViewController.delegate = self
                        webViewController.setURL(url: lastUrl)
                        self.loadingView.isHidden = true
                        self.navigationController!.pushViewController(webViewController,animated: false)
                    }
                } else {
                    print(__("图片上传转链接失败"))
                    print(result.error?.errorDescription ?? "")
                    //                    if result.error?.errorDescription == "URLSessionTask failed with error: \(__("似乎已断开与互联网的连接。"))" {
                    //
                    //                    }
                    showNetworkErrorAlert(cameraPicker)
                    isSelect = false
                }
            }
        }
    }
    
    func images(){
        headers = [
            "Content-type": "text/html; charset=GBK"
        ]
        if !isSelect {
            isSelect = true
            showActivityIndicatory(uiView: imagePicker.view)
            IsolatedInteraction.shared.showAnimate(vc: imagePicker)
            AF.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(((self.image as! UIImage?)!.jpegData(compressionQuality: 0.8))! , withName: "source", fileName: "YourImageName"+".jpeg", mimeType: "image/png")
            },  to: "http://pic.sogou.com/pic/upload_pic.jsp?", method: .post, headers: headers).responseString { [self] (result) in
                if let lastUrl = result.value{
                    Statistics.endLogPageView("拍照页")
                    SQL.insert(imagedata: (self.image as! UIImage?)!.jpegData(compressionQuality: 0.8)! as Data)
                    self.loadingView.isHidden = true
                    isSelect = false
                    IsolatedInteraction.shared.dismissAnimate(vc: imagePicker) {
                        self.dismiss(animated: true, completion: nil)
                        let webViewController = WebViewController()
                        webViewController.delegate = self
                        webViewController.setURL(url: lastUrl)
                        self.navigationController!.pushViewController(webViewController,animated: false)
                    }
                    
                    
                } else {
                    print(__("图片上传转链接失败"))
                    print(result.error?.errorDescription ?? " ")
                    //                    if result.error?.errorDescription == "URLSessionTask failed with error: \(__("似乎已断开与互联网的连接。"))" {
                    //                       showNetworkErrorAlert(imagePicker)
                    //                    }
                    showNetworkErrorAlert(imagePicker)
                    isSelect = false
                }
            }
        }
    }
}

//MARK: - UIImagePickerController
extension MainViewController:UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)]
        if isImage {
            images()
        } else {
            camera()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        if isImage {
            Statistics.endLogPageView("相册页")
            
        } else {
            Statistics.endLogPageView("拍照页")
        }
    }
}

//MARK: - UIDocumentPickerController
extension MainViewController:UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController,didPickDocumentAt url: URL) {
        
        CFURLStartAccessingSecurityScopedResource(url as CFURL)
        let imgData = try! Data.init(contentsOf: url)
        CFURLStopAccessingSecurityScopedResource(url as CFURL)
        headers = [
            "Content-type": "text/html; charset=GBK"
        ]
        self.showActivityIndicatory(uiView:self.view)
        if !isSelect {
            // 顯示進度條显
            isSelect = true
            IsolatedInteraction.shared.showAnimate(vc: self)
            AF.upload(multipartFormData: { (multipartFormData) in
                guard let _ = UIImage(data: imgData) else { return  }
                multipartFormData.append(((UIImage(data: imgData)!).jpegData(compressionQuality: 0.8)!), withName: "source", fileName: "YourImageName"+".jpeg", mimeType: "image/png")
            },  to: "http://pic.sogou.com/pic/upload_pic.jsp?", method: .post, headers: headers).responseString { [self] (result) in
                if let lastUrl = result.value{
                    print(lastUrl)
                    SQL.insert(imagedata: imgData)
                    self.loadingView.isHidden = true
                    Statistics.endLogPageView("文件页")
                    IsolatedInteraction.shared.dismissAnimate(vc: self, complete: {
                        let webViewController = WebViewController()
                        webViewController.delegate = self
                        webViewController.setURL(url: lastUrl)
                        self.navigationController!.pushViewController(webViewController,animated: false)
                    })
                    isSelect = false
                } else {
                    print(__("图片上传转链接失败"))
                    print(result.error?.errorDescription ?? "")
                    dismissAnimate{
                        self.loadingView.isHidden = true
                        showNetworkErrorAlert(self)
                        isSelect = false
                    }
                }
            }
        }
    }
    
    func documentPickerWasCancelled(_: UIDocumentPickerViewController){
        self.dismiss(animated: true, completion: nil)
        Statistics.endLogPageView("文件页")
    }
    
}


//MARK: - UI
extension MainViewController {
    
    func setupAdBannerView() {
        if let bannerView = self.bannerView {
            view.addSubview(bannerView)
            bannerView.snp.makeConstraints { make in
                make.top.equalTo(safeAreaTop)
                make.left.right.equalToSuperview()
                make.height.equalTo(Ad.default.adaptiveBannerHeight)
            }
            searchImageView.snp.remakeConstraints{make in
                make.top.equalTo(safeAreaTop).offset(GetWidthHeight.share.getHeight(height: 32 + Float(Ad.default.adaptiveBannerHeight)))
                make.centerX.equalToSuperview()
            }
        }
    }
    
    func setupUI() {
        // 底色
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        // 導覽列底色
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 19/255, green: 165/255, blue: 255/255, alpha: 1)
        // 導覽列是否半透明
        self.navigationController?.navigationBar.isTranslucent = false
        //        self.navigationController?.navigationBar.clipsToBounds = true
        // 加到導覽列中
        self.navigationItem.rightBarButtonItem = settingButton
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.view.addSubview(topBackgroundImage)
        
        self.view.addSubview(searchImageView)
        
        self.view.addSubview(appTitle)
        
        self.view.addSubview(bottomBackgroundLabel)
        
        
        SQL.createTable()
        
        bottomBackgroundLabel.addSubview(hintTitle)
        bottomBackgroundLabel.isUserInteractionEnabled = true
        
        imageSearchButton.isUserInteractionEnabled = true
        imageSearchButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageSearch)))
        bottomBackgroundLabel.addSubview(imageSearchButton)
        
        cameraSearchButton.isUserInteractionEnabled = true
        cameraSearchButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cameraSearch)))
        bottomBackgroundLabel.addSubview(cameraSearchButton)
        
        fileSearchButton.isUserInteractionEnabled = true
        fileSearchButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fileSearch)))
        bottomBackgroundLabel.addSubview(fileSearchButton)
        
        urlSearchButton.isUserInteractionEnabled = true
        urlSearchButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(urlSearch)))
        bottomBackgroundLabel.addSubview(urlSearchButton)
        
        keywordSearchButton.isUserInteractionEnabled = true
        keywordSearchButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(keywordSearch)))
        bottomBackgroundLabel.addSubview(keywordSearchButton)
        
        recordSearchButton.isUserInteractionEnabled = true
        recordSearchButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(recordSearch)))
        bottomBackgroundLabel.addSubview(recordSearchButton)
    }
    
    func setupConstraints() { 
        
        topBackgroundImage.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        searchImageView.snp.makeConstraints { make in
            //            make.top.equalTo(safeAreaTop).offset(32)
            make.top.equalTo(safeAreaTop).offset(GetWidthHeight.share.getHeight(height: 32))
            make.centerX.equalToSuperview()
        }
        
        appTitle.snp.makeConstraints{ make in
            //            make.top.equalTo(safeAreaTop).offset(136)
            make.top.equalTo(searchImageView.snp.bottom).offset(GetWidthHeight.share.getHeight(height: 10))
            make.centerX.equalToSuperview()
        }
        
        hintTitle.snp.makeConstraints{ (make) in
            //            make.top.equalTo(safeAreaTop).offset(248)
            make.top.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(24)
        }
        
        bottomBackgroundLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(safeAreaBottom).offset(-24)
            make.height.equalToSuperview().multipliedBy(0.6)
            make.left.equalToSuperview().offset(GetWidthHeight.share.getWidth(width: 20))
            make.right.equalToSuperview().offset(-GetWidthHeight.share.getWidth(width: 20))
            
        }
        
        imageSearchButton.snp.makeConstraints { (make) in
            make.width.equalTo(136)
            make.top.equalToSuperview().offset(GetWidthHeight.share.getHeight(height: 80))
            make.left.equalToSuperview().offset(GetWidthHeight.share.getWidth(width: 24))
//            if Util.hasTopNotch {
//                
//            }
        }
        
        cameraSearchButton.snp.makeConstraints{(make) in
            make.width.equalTo(136)
            make.top.equalToSuperview().offset(GetWidthHeight.share.getHeight(height: 80))
            make.right.equalToSuperview().offset(-GetWidthHeight.share.getWidth(width: 24))
        }
        
        fileSearchButton.snp.makeConstraints{(make) in
            make.height.equalTo(imageSearchButton)
            make.width.equalTo(136)
            //            make.center.equalToSuperview()
            make.top.equalTo(imageSearchButton.snp.bottom).offset(24)
            make.top.equalToSuperview().offset(GetWidthHeight.share.getHeight(height: 196))
            make.left.equalToSuperview().offset(GetWidthHeight.share.getWidth(width: 24))
        }
        
        urlSearchButton.snp.makeConstraints{(make) in
            make.height.equalTo(cameraSearchButton)
            make.width.equalTo(136)
            make.top.equalTo(cameraSearchButton.snp.bottom).offset(GetWidthHeight.share.getHeight(height: 24))
            //            make.center.equalToSuperview()
            make.top.equalToSuperview().offset(GetWidthHeight.share.getHeight(height: 196))
            make.right.equalToSuperview().offset(-GetWidthHeight.share.getWidth(width: 24))
        }
        
        keywordSearchButton.snp.makeConstraints{(make) in
            make.height.equalTo(fileSearchButton)
            make.width.equalTo(136)
            make.top.equalTo(fileSearchButton.snp.bottom).offset(GetWidthHeight.share.getHeight(height: 24))
            make.top.equalToSuperview().offset(GetWidthHeight.share.getHeight(height: 312))
            make.left.equalToSuperview().offset(GetWidthHeight.share.getWidth(width: 24))
        }
        
        recordSearchButton.snp.makeConstraints{(make) in
            make.height.equalTo(urlSearchButton)
            make.width.equalTo(keywordSearchButton)
            make.top.equalTo(urlSearchButton.snp.bottom).offset(GetWidthHeight.share.getHeight(height: 24))
            make.top.equalToSuperview().offset(GetWidthHeight.share.getHeight(height: 312))
            make.right.equalToSuperview().offset(-GetWidthHeight.share.getWidth(width: 24))
        }
    }
}
