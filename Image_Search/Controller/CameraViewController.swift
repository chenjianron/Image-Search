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

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    // 取得螢幕的尺寸
    let fullScreenSize = UIScreen.main.bounds.size
    
    var headers: HTTPHeaders = [:]
    var isFromWebViewController = false
    var isSelect = false
    var delegate:MainViewController?
    
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
        myActivityIndicator.color = .white
        myActivityIndicator.backgroundColor = .gray
        return myActivityIndicator
    }()
    var imagePicker:UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.isToolbarHidden = true
        return imagePicker
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
            self.present(imagePicker, animated: false, completion:nil)
            isFromWebViewController = false
        }
    }
}

//MARK: -
extension CameraViewController{
    
    @objc func backToPrevious(){
        self.navigationController!.popViewController(animated: true)
    }
    
    func setDelegate(delegate:MainViewController){
        self.delegate = delegate
    }
}

//MARK: - UI
extension CameraViewController {
    
    func setUpUI(){
        
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBarBtn
        
        myActivityIndicator.center = CGPoint(x: fullScreenSize.width * 0.5, y: fullScreenSize.height * 0.5)
        imagePicker.delegate = self
        imagePicker.view.addSubview(myActivityIndicator)
        self.present(imagePicker, animated: false, completion:nil)

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
}

//MARK: - UIImagePickerController
extension CameraViewController {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        let image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)]
        headers = [
            "Content-type": "text/html; charset=GBK"
        ]
        if !isSelect {
            // 顯示進度條
            isSelect = true
            myActivityIndicator.startAnimating()
            AF.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(((image as! UIImage?)!.jpegData(compressionQuality: 1.0))! , withName: "source", fileName: "YourImageName"+".jpeg", mimeType: "image/png")
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
                    print(result.error?.errorDescription)
                    if result.error?.errorDescription == "URLSessionTask failed with error: The Internet connection appears to be offline." {
                        let alertController = UIAlertController(
                            title: nil,
                            message: "网络超时，请重试",
                            preferredStyle: .alert)
                        self.imagePicker.present(
                            alertController,
                            animated: true,
                            completion: nil)
                        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (ktimer) in
                            self.imagePicker.dismiss(animated: true, completion: nil)
                        }
                    }
                    myActivityIndicator.stopAnimating()
                    isSelect = false
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
}

