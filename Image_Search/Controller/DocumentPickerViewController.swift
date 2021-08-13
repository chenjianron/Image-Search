//
//  DocumentPickerViewController.swift
//  Image_Search
//
//  Created by GC on 2021/8/10.
//

//
//  CameraViewController.swift
//  Image_Search
//
//  Created by GC on 2021/8/9.
//

import UIKit
import SnapKit
import Alamofire
import Toolkit
import WebKit

class DocumentPickerViewController: UIViewController, UIDocumentPickerDelegate, UINavigationControllerDelegate{
    
    // 取得螢幕的尺寸
    let fullScreenSize = UIScreen.main.bounds.size
    
    var headers: HTTPHeaders = [:]
    var isFromWebViewController = false
    var isSelect = false
    var delegate:MainViewController?
    var documentPicker:UIDocumentPickerViewController!
    
    lazy var leftBarBtn:UIBarButtonItem = {
        let leftBarBtn = UIBarButtonItem()
        return leftBarBtn
    }()
    lazy var selectImage:UIImageView = {
        let image = UIImageView()
        return image
    }()
    var myActivityIndicator:UIActivityIndicatorView = {
       let myActivityIndicator = UIActivityIndicatorView(style:.gray)
        myActivityIndicator.color = .gray
        return myActivityIndicator
    }()
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        setUpUI()
        setupConstrains()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        if isFromWebViewController {
            self.present(documentPicker!, animated: false, completion:nil)
            isFromWebViewController = false
        }
    }
}

//MARK: -
extension DocumentPickerViewController{
    
    @objc func backToPrevious(){
        self.navigationController!.popViewController(animated: true)
    }
    
    func setUIImagePickerController(){
        
        let letdocumentTypes = ["public.image"]
        documentPicker = UIDocumentPickerViewController.init(documentTypes: letdocumentTypes, in: .open)
        documentPicker?.modalPresentationStyle = .fullScreen
        documentPicker!.delegate = self
        self.view.addSubview(myActivityIndicator)
        self.present(documentPicker!, animated: false, completion:nil)
//        self.navigationController?.pushViewController(documentPicker!, animated: false)
    }
}

//MARK: - UI
extension DocumentPickerViewController {
    
    func setUpUI(){
        
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBarBtn
        myActivityIndicator.center = CGPoint(x: fullScreenSize.width * 0.5, y: fullScreenSize.height * 0.35)
        self.setUIImagePickerController()
        //        self.view.addSubview(selectImage)
        //        let alertController = UIAlertController(
        //            title: "确认刪除",
        //            message: "我们需要访问照片以搜索图片的来源",
        //            preferredStyle: .alert)
        //        // 建立选择照片按鈕
        //        let selectAction = UIAlertAction(
        //          title: "选择照片...",
        //            style: .default,
        //          handler: { _ in
        //            self.setUIImagePickerController()
        //          })
        //        alertController.addAction(selectAction)
        //        // 建立允许访问所有照片按鈕
        //        let permitAction = UIAlertAction(
        //            title: "允许访问所有照片",
        //            style: .default,
        //            handler: {_ in
        ////      let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options:     nil) as? PHFetchResult
        //                self.setUIImagePickerController()
        //        })
        //        alertController.addAction(permitAction)
        //
        //        let forbidAction = UIAlertAction(
        //            title: "不允许",
        //            style: .cancel,
        //            handler: {_ in
        //                self.backToPrevious()
        //        })
        //        alertController.addAction(forbidAction)
        //        // 顯示提示框
        //        self.present(
        //            alertController,
        //            animated: true,
        //            completion: nil)
    }
    func setupConstrains(){
        
    }
    
    func setupDataSource(){
    }
}

//MARK: - UIImagePickerController
extension DocumentPickerViewController {
    func documentPicker(_ controller: UIDocumentPickerViewController,didPickDocumentAt url: URL) {
        
        let imgData = try! Data.init(contentsOf: url)
        headers = [
            "Content-type": "text/html; charset=GBK"
        ]
        myActivityIndicator.startAnimating()
        if !isSelect {
            // 顯示進度條
            isSelect = true
            myActivityIndicator.startAnimating()
            AF.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(((UIImage(data: imgData) as! UIImage?)!.jpegData(compressionQuality: 1.0))! , withName: "source", fileName: "YourImageName"+".jpeg", mimeType: "image/png")
            },  to: "http://pic.sogou.com/pic/upload_pic.jsp?", method: .post, headers: headers).responseString { [self] (result) in
                if let lastUrl = result.value{
                    print(lastUrl)
                    self.dismiss(animated: true, completion: nil)
                    let webViewController = WebViewController()
                    webViewController.delegate = self
                    webViewController.setURL(url: lastUrl)
                    self.isFromWebViewController = true
                    myActivityIndicator.stopAnimating()
                    self.navigationController!.pushViewController(webViewController,animated: false)
                    isSelect = false
                } else {
                    print("上传失败")
                    print(result.error?.errorDescription ?? "")
                    if result.error?.errorDescription == "URLSessionTask failed with error: The Internet connection appears to be offline." {
                        let alertController = UIAlertController(
                            title: nil,
                            message: "网络超时，请重试",
                            preferredStyle: .alert)
                        self.present(
                            alertController,
                            animated: true,
                            completion: nil)
                        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (ktimer) in
                            self.dismiss(animated: true, completion: nil)
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    myActivityIndicator.stopAnimating()
                    isSelect = false
                }
            }
        }
        
    }
    
    func documentPickerWasCancelled(_: UIDocumentPickerViewController){
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
}


