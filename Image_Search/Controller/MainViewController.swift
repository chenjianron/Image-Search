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
        searchImageView.image = UIImage(named: "search_icon.png")
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
        //        label.bounds.size.width = fullScreenSize.width
        //        label.bounds.size.height = fullScreenSize.height/2
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
        searchButton.dataSouce(title: __("图片"), image: "image_search.png")
        return searchButton
    }()
    lazy var cameraSearchButton: ButtonView = {
        let searchButton = ButtonView()
        searchButton.dataSouce(title: __("相机"), image: "camera_search.png")
        return searchButton
    }()
    lazy var fileSearchButton: ButtonView = {
        let searchButton = ButtonView()
        searchButton.dataSouce(title: __("文件"), image: "file_search.png")
        return searchButton
    }()
    lazy var urlSearchButton: ButtonView = {
        let searchButton = ButtonView()
        searchButton.dataSouce(title: __("图片url"), image: "url_search.png")
        return searchButton
    }()
    lazy var keywordSearchButton: ButtonView = {
        let searchButton = ButtonView()
        searchButton.dataSouce(title: __("关键词"), image: "keyword_search.png")
        return searchButton
    }()
    lazy var recordSearchButton: ButtonView = {
        let searchButton = ButtonView()
        searchButton.dataSouce(title: __("搜索记录"), image: "record_search.png")
        return searchButton
    }()
   
    lazy var myActivityIndicator:UIActivityIndicatorView = {
        let myActivityIndicator = UIActivityIndicatorView(style:.gray)
        myActivityIndicator.color = .black
        myActivityIndicator.backgroundColor = .gray
        if #available(iOS 13.0, *) {
            myActivityIndicator.style = .medium
        } else {
            // Fallback on earlier versions
        }
        return myActivityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Statistics.beginLogPageView("首页")
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 19/255, green: 165/255, blue: 255/255, alpha: 1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Statistics.endLogPageView("首页")
    }
}

//MARK: -
extension MainViewController {
    
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

     var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
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
    
    @objc func setting(){
        print("setting")
        //        var settingViewController = SettingViewController()
        self.navigationController?.pushViewController(SettingViewController(),animated: false)
    }
    
    func startUIActivityIndicatorView(){
        self.myActivityIndicator.startAnimating()
    }
    
    func stopUIActivityIndicatorView(){
        self.myActivityIndicator.stopAnimating()
    }
        
    @objc func imageSearch(){
        isImage = true
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.isToolbarHidden = true
        imagePicker.view.addSubview(myActivityIndicator)
        myActivityIndicator.snp.makeConstraints{ (make) in
            make.top.equalTo(fullScreenSize.height / 2 - 44)
            make.left.equalTo(fullScreenSize.width / 2)
        }
        self.present(imagePicker, animated: false, completion: nil)
    }
    
    @objc func cameraSearch(){
        isImage = false
        cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.modalPresentationStyle = .fullScreen
        cameraPicker.sourceType = UIImagePickerController.SourceType.camera
        cameraPicker.isToolbarHidden = true
        cameraPicker.view.addSubview(myActivityIndicator)
        myActivityIndicator.snp.makeConstraints{ (make) in
            make.top.equalTo(fullScreenSize.height / 2 - 44)
            make.left.equalTo(fullScreenSize.width / 2)
        }
        self.present(cameraPicker, animated: false, completion: nil)
    }
    
    @objc func fileSearch(){
        print("fileSearch")
        let letdocumentTypes = ["public.image"]
        var documentPicker = UIDocumentPickerViewController.init(documentTypes: letdocumentTypes, in: .open)
        documentPicker.modalPresentationStyle = .fullScreen
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    @objc func urlSearch(){
        print("urlSearch")
        var urlEditWindowViewController = UrlViewController()
        urlEditWindowViewController.setType(type: "url")
        urlEditWindowViewController.setDelegate(delegate: self)
        self.present(urlEditWindowViewController, animated: false, completion: nil)
    }
    
    func goWebViewControllerFromUrlViewController(webViewController:WebViewController){
        self.navigationController?.pushViewController(webViewController,animated: false)
    }
    
    @objc func keywordSearch(){
        print("keywordSearch")
        var keywordEditWindowViewController = UrlViewController()
        keywordEditWindowViewController.setType(type: __("关键词"))
        keywordEditWindowViewController.setDelegate(delegate: self)
        self.present(keywordEditWindowViewController, animated: false, completion: nil)
    }
    
    @objc func recordSearch(){
        print("recordSearch")
        //        var searchRecordViewController = SearchRecordViewController()
        self.navigationController?.pushViewController(SearchRecordViewController(),animated: false)
    }
    
    func cancel(){
        self.dismiss(animated: false, completion: nil)
    }
    
    func camera(){
        headers = [
            "Content-type": "text/html; charset=GBK"
        ]
        if !isSelect {
            // 顯示進度條
            isSelect = true
            self.showActivityIndicatory(uiView: cameraPicker.view)
            AF.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(((self.image as! UIImage?)!.jpegData(compressionQuality: 0.8))! , withName: "source", fileName: "search"+".jpeg", mimeType: "image/png")
            },  to: "http://pic.sogou.com/pic/upload_pic.jsp?", method: .post, headers: headers).responseString (){ [self] (result) in
                if let lastUrl = result.value{
                    print(lastUrl)
                    SQL.insert(imagedata: (self.image as! UIImage?)!.jpegData(compressionQuality: 0.8)! as Data)
                    self.dismiss(animated: true, completion: nil)
                    let webViewController = WebViewController()
                    webViewController.delegate = self
                    webViewController.setURL(url: lastUrl)
                    self.loadingView.isHidden = true
                    self.navigationController!.pushViewController(webViewController,animated: false)
                    isSelect = false
                } else {
                    print(__("上传失败"))
                    print(result.error?.errorDescription ?? "")
                    if result.error?.errorDescription == "URLSessionTask failed with error: The Internet connection appears to be offline." {
                        let alertController = UIAlertController(
                            title: nil,
                            message: __("网络超时，请重试"),
                            preferredStyle: .alert)
                        self.cameraPicker.present(
                            alertController,
                            animated: true,
                            completion: nil)
                        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (ktimer) in
                            self.cameraPicker.dismiss(animated: true, completion: nil)
                        }
                    }
                    isSelect = false
                }
            }
        }
    }
    
    func images(){
        headers = [
            "Content-type": "text/html; charset=GBK"
        ]
        self.imagePicker.view.isUserInteractionEnabled = false
        if !isSelect {
            isSelect = true
            showActivityIndicatory(uiView: imagePicker.view)
            AF.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(((self.image as! UIImage?)!.jpegData(compressionQuality: 0.8))! , withName: "source", fileName: "YourImageName"+".jpeg", mimeType: "image/png")
            },  to: "http://pic.sogou.com/pic/upload_pic.jsp?", method: .post, headers: headers).responseString { [self] (result) in
                if let lastUrl = result.value{
                    SQL.insert(imagedata: (self.image as! UIImage?)!.jpegData(compressionQuality: 0.8)! as Data)
                    self.loadingView.isHidden = true
                    self.imagePicker.view.isUserInteractionEnabled = true
                    self.dismiss(animated: true, completion: nil)
                    let webViewController = WebViewController()
                    webViewController.delegate = self
                    webViewController.setURL(url: lastUrl)
                    self.navigationController!.pushViewController(webViewController,animated: false)
                    isSelect = false
                } else {
                    print(__("上传失败"))
                    print(result.error?.errorDescription ?? " ")
                    if result.error?.errorDescription == "URLSessionTask failed with error: The Internet connection appears to be offline." {
                        let alertController = UIAlertController(
                            title: nil,
                            message: __("网络超时，请重试"),
                            preferredStyle: .alert)
                        self.imagePicker.present(
                            alertController,
                            animated: true,
                            completion: nil)
                        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (ktimer) in
                            self.imagePicker.view.isUserInteractionEnabled = true
                            self.imagePicker.dismiss(animated: true, completion: nil)
                        }
                    }
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
        self.dismiss(animated: true, completion: nil)
        self.showActivityIndicatory(uiView: self.view)
        if !isSelect {
            // 顯示進度條显
            isSelect = true
            AF.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(((UIImage(data: imgData) as! UIImage?)!.jpegData(compressionQuality: 0.8))! , withName: "source", fileName: "YourImageName"+".jpeg", mimeType: "image/png")
            },  to: "http://pic.sogou.com/pic/upload_pic.jsp?", method: .post, headers: headers).responseString { [self] (result) in
                if let lastUrl = result.value{
                    print(lastUrl)
                    SQL.insert(imagedata: imgData)
                    self.loadingView.isHidden = true
                    let webViewController = WebViewController()
                    webViewController.delegate = self
                    webViewController.setURL(url: lastUrl)
                    self.navigationController!.pushViewController(webViewController,animated: false)
                    isSelect = false
                } else {
                    print(__("上传失败"))
                    print(result.error?.errorDescription ?? "")
                    if result.error?.errorDescription == "URLSessionTask failed with error: The Internet connection appears to be offline." {
                        let alertController = UIAlertController(
                            title: nil,
                            message: __("网络超时，请重试"),
                            preferredStyle: .alert)
                        self.present(
                            alertController,
                            animated: true,
                            completion: nil)
                        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (ktimer) in
                            self.dismiss(animated: true, completion: nil)

                        }
                    }
                    isSelect = false
                }
            }
        }
    }
    
    func documentPickerWasCancelled(_: UIDocumentPickerViewController){
        self.dismiss(animated: true, completion: nil)
    }
    
}


//MARK: - UI
extension MainViewController {
    
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
        
        self.view.addSubview(myActivityIndicator)
        
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
        
        myActivityIndicator.snp.makeConstraints{ (make) in
            make.top.equalTo(fullScreenSize.height / 2 - 44)
            make.left.equalTo(fullScreenSize.width / 2)
        }
        
        topBackgroundImage.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        searchImageView.snp.makeConstraints { make in
//            make.top.equalTo(safeAreaTop).offset(32)
            make.top.equalTo(safeAreaTop).offset(GetWidthHeight.getHeight(height: 32))
            make.centerX.equalToSuperview()
        }
        
        appTitle.snp.makeConstraints{ make in
//            make.top.equalTo(safeAreaTop).offset(136)
            make.top.equalTo(searchImageView.snp.bottom).offset(GetWidthHeight.getHeight(height: 12))
            make.centerX.equalToSuperview()
        }
        
        hintTitle.snp.makeConstraints{ (make) in
//            make.top.equalTo(safeAreaTop).offset(248)
            make.top.equalTo(safeAreaTop).offset(GetWidthHeight.getHeight(height: 248))
            make.left.equalToSuperview().offset(GetWidthHeight.getWidth(width: 24))
        }
        
        bottomBackgroundLabel.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaTop).offset(GetWidthHeight.getHeight(height: 218))
            //            make.left.equalToSuperview().offset(20)
            //            make.right.equalToSuperview().offset(20)
            make.height.equalToSuperview().multipliedBy(0.6)
            make.left.equalToSuperview().offset(GetWidthHeight.getWidth(width: 20))
            make.right.equalToSuperview().offset(-GetWidthHeight.getWidth(width: 20))
            
        }
        
        imageSearchButton.snp.makeConstraints { (make) in
            make.height.equalTo(92 )
            make.width.equalTo(136)
            //            make.center.equalToSuperview()
            make.top.equalToSuperview().offset(GetWidthHeight.getHeight(height: 80))
            make.left.equalToSuperview().offset(GetWidthHeight.getWidth(width: 24))
        }
        
        cameraSearchButton.snp.makeConstraints{(make) in
            make.height.equalTo(92 )
            make.width.equalTo(136)
            //            make.center.equalToSuperview()
            make.top.equalToSuperview().offset(GetWidthHeight.getHeight(height: 80))
            make.left.equalToSuperview().offset(GetWidthHeight.getWidth(width: 175))
        }
        
        fileSearchButton.snp.makeConstraints{(make) in
            make.height.equalTo(92 )
            make.width.equalTo(136)
            //            make.center.equalToSuperview()
            make.top.equalToSuperview().offset(GetWidthHeight.getHeight(height: 196))
            make.left.equalToSuperview().offset(GetWidthHeight.getWidth(width: 24))
        }
        
        urlSearchButton.snp.makeConstraints{(make) in
            make.height.equalTo(92 )
            make.width.equalTo(136)
            //            make.center.equalToSuperview()
            make.top.equalToSuperview().offset(GetWidthHeight.getHeight(height: 196))
            make.left.equalToSuperview().offset(GetWidthHeight.getWidth(width: 175))
        }
        
        keywordSearchButton.snp.makeConstraints{(make) in
            make.height.equalTo(92 )
            make.width.equalTo(136)
            //            make.center.equalToSuperview()
            make.top.equalToSuperview().offset(GetWidthHeight.getHeight(height: 312))
            make.left.equalToSuperview().offset(GetWidthHeight.getWidth(width: 24))
        }
        
        recordSearchButton.snp.makeConstraints{(make) in
            make.height.equalTo(92)
            make.width.equalTo(keywordSearchButton)
//            make.width.equalTo(136)
            //            make.center.equalToSuperview()
            make.top.equalToSuperview().offset(GetWidthHeight.getHeight(height: 312))
            make.left.equalToSuperview().offset(GetWidthHeight.getWidth(width: 175))
        }
    }
    
}
