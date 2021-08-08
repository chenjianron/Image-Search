//
//  ImagePickerController.swift
//  Image_Search
//
//  Created by GC on 2021/8/4.
//

import UIKit
import SnapKit
import Alamofire
import Toolkit
import WebKit

class ImagePickerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,WKNavigationDelegate{
    
    // 取得螢幕的尺寸
    let fullScreenSize = UIScreen.main.bounds.size
    
    var headers: HTTPHeaders = [:]
    var isFromWebViewController = false
    var delegate:MainViewController?
    var imagePicker:UIImagePickerController?
    var myActivityIndicator:UIActivityIndicatorView!
    
    lazy var leftBarBtn:UIBarButtonItem = {
        let leftBarBtn = UIBarButtonItem()
        return leftBarBtn
    }()
//    lazy var leftBarBtn:UIBarButtonItem = {
//        let leftBarBtn = UIBarButtonItem(image: UIImage(named: "back.png")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backToPrevious))
//        return leftBarBtn
//    }()
    lazy var selectImage:UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        setUpUI()
        setupConstrains()
        setupDataSource()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        print("viewWillDisappear")
//    }
//    
//    override func awakeFromNib() {
//        print("awakeFromNib")
//    }
//
//    override func loadView() {
//        super.loadView()
//        print("loadView")
//    }

    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        if isFromWebViewController {
            self.present(imagePicker!, animated: false, completion:nil)
            isFromWebViewController = false
        }
//        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }

//    override func viewWillLayoutSubviews() {
//        print("viewWillLayoutSubviews")
//    }
//
//    override func viewDidLayoutSubviews() {
//        print("viewDidLayoutSubviews")
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        print("viewDidAppear")
//    }
//    override func viewDidDisappear(_ animated: Bool) {
//        print("viewDidDisappear")
//    }
//
//    override func didReceiveMemoryWarning() {
//        print("didReceiveMemoryWarning")
//    }
}

//MARK: -
extension ImagePickerViewController{
    @objc func backToPrevious(){
        self.navigationController!.popViewController(animated: true)
    }
    
    func setUIImagePickerController(){
        imagePicker = UIImagePickerController()
        imagePicker!.modalPresentationStyle = .fullScreen
        imagePicker!.sourceType = UIImagePickerController.SourceType.photoLibrary
//        ic.isNavigationBarHidden = true
        imagePicker!.isToolbarHidden = true
//        ic.sourceType = UIImagePickerController.SourceType.camera
//        ic.cameraCaptureMode = UIImagePickerController.CameraCaptureMode.photo
//        ic.showsCameraControls = false
        imagePicker!.delegate = self
        imagePicker!.view.addSubview(myActivityIndicator)
        self.present(imagePicker!, animated: false, completion:nil)
    }
    
    func setDelegate(delegate:MainViewController){
        self.delegate = delegate
    }
}

//MARK: - UI
extension ImagePickerViewController {
    func setUpUI(){
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.view.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = leftBarBtn
        // 建立環狀進度條
        myActivityIndicator = UIActivityIndicatorView(style:.gray)
        myActivityIndicator.center = CGPoint(x: fullScreenSize.width * 0.5, y: fullScreenSize.height * 0.5)
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
extension ImagePickerViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        let image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)]
        headers = [
            "Content-type": "text/html; charset=GBK"
        ]
        // 顯示進度條
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
            } else {
                print("上传失败")
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
  }
