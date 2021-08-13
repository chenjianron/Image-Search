//
//  ViewController.swift
//  Image_Search
//
//  Created by GC on 2021/8/2.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    let fullScreenSize = UIScreen.main.bounds.size
    
    lazy var settingButton: UIBarButtonItem = {
        let settingButton = UIBarButtonItem(
            image: UIImage(named: "setting_icon_image")?.withRenderingMode(.alwaysOriginal),
            style:.plain ,
            target:self ,
            action: #selector(MainViewController.setting))
        return settingButton
    }()
    lazy var settingViewController:SettingViewController = {
        return SettingViewController()
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
        appTitle.text = "按图搜索"
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
        hintTitle.text = "选择图片"
        hintTitle.font = UIFont(name: "Helvetica", size: 16)
        hintTitle.font = UIFont.boldSystemFont(ofSize: 16)
        return hintTitle
    }()
    lazy var imageSearchButton: ButtonView = {
        let searchButton = ButtonView()
        searchButton.dataSouce(title: "图片", image: "image_search.png")
        return searchButton
    }()
    lazy var cameraSearchButton: ButtonView = {
        let searchButton = ButtonView()
        searchButton.dataSouce(title: "相机", image: "camera_search.png")
        return searchButton
    }()
    lazy var fileSearchButton: ButtonView = {
        let searchButton = ButtonView()
        searchButton.dataSouce(title: "文件", image: "file_search.png")
        return searchButton
    }()
    lazy var urlSearchButton: ButtonView = {
        let searchButton = ButtonView()
        searchButton.dataSouce(title: "图片url", image: "url_search.png")
        return searchButton
    }()
    lazy var keywordSearchButton: ButtonView = {
        let searchButton = ButtonView()
        searchButton.dataSouce(title: "关键词", image: "keyword_search.png")
        return searchButton
    }()
    lazy var recordSearchButton: ButtonView = {
        let searchButton = ButtonView()
        searchButton.dataSouce(title: "搜索记录", image: "record_search.png")
        return searchButton
    }()
    lazy var urlEditWindowViewController:UrlViewController = {
       let editViewController = UrlViewController()
        if #available(iOS 13.0, *) {
            editViewController.modalPresentationStyle = .overFullScreen
        } else {
            // Fallback on earlier versions
        }
        return editViewController
    }()
    
    lazy var keywordEditWindowViewController:UrlViewController = {
       let editViewController = UrlViewController()
        if #available(iOS 13.0, *) {
            editViewController.modalPresentationStyle = .overFullScreen
        } else {
            // Fallback on earlier versions
        }
        return editViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 19/255, green: 165/255, blue: 255/255, alpha: 1)
    }
}

//MARK: -
extension MainViewController {
    
    @objc func setting(){
        print("setting")
        self.navigationController?.pushViewController(settingViewController,animated: false)
    }
    
    @objc func search(){
        print("search")
    }
    
    @objc func imageSearch(){
        print("imageSearch")
        self.navigationController?.pushViewController(ImagePickerViewController(),animated: false)
    }
    
    @objc func cameraSearch(){
        print("cameraSearch")
        self.navigationController?.pushViewController(CameraViewController(),animated: false)
    }
    
    @objc func fileSearch(){
        print("fileSearch")
        self.navigationController?.pushViewController(DocumentPickerViewController(),animated: false)
    }
    
    @objc func urlSearch(){
        print("urlSearch")
        self.present(urlEditWindowViewController, animated: true, completion: nil)
        
    }
    
    func goWebViewControllerFromUrlViewController(webViewController:WebViewController){
        self.navigationController?.pushViewController(webViewController,animated: false)
        
    }
    
    @objc func keywordSearch(){
        print("keywordSearch")
        self.present(keywordEditWindowViewController, animated: true, completion: nil)
    }
    
    @objc func recordSearch(){
        print("recordSearch")
    }
    
    func cancel(){
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UI
extension MainViewController {
    
    func setupUI() {
        // 底色
        self.view.backgroundColor = UIColor.white
        navigationController?.navigationBar.shadowImage = UIImage()
        // 導覽列底色
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 19/255, green: 165/255, blue: 255/255, alpha: 1)
        // 導覽列是否半透明
        self.navigationController?.navigationBar.isTranslucent = false
        //        self.navigationController?.navigationBar.clipsToBounds = true
        // 加到導覽列中
        self.navigationItem.rightBarButtonItem = settingButton
        
        self.view.addSubview(topBackgroundImage)
        
        self.view.addSubview(searchImageView)
        
        self.view.addSubview(appTitle)
        
        self.view.addSubview(bottomBackgroundLabel)
        
        urlEditWindowViewController.setType(type: "url")
        urlEditWindowViewController.setDelegate(delegate: self)
        
        keywordEditWindowViewController.setType(type: "关键词")
        keywordEditWindowViewController.setDelegate(delegate: self)
        
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
            make.top.equalTo(safeAreaTop).offset(32)
            make.centerX.equalToSuperview()
        }
        
        appTitle.snp.makeConstraints{ make in
            make.top.equalTo(safeAreaTop).offset(136)
            make.centerX.equalToSuperview()
        }
        
        hintTitle.snp.makeConstraints{ (make) in
            make.top.equalTo(safeAreaTop).offset(248)
            make.left.equalToSuperview().offset(24)
        }
        
        bottomBackgroundLabel.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaTop).offset(218)
            //            make.left.equalToSuperview().offset(20)
            //            make.right.equalToSuperview().offset(20)
            make.height.equalToSuperview().multipliedBy(0.6)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            
        }
        
        imageSearchButton.snp.makeConstraints { (make) in
            make.height.equalTo(fullScreenSize.height / 9 )
            make.width.equalTo((fullScreenSize.width / 10 ) * 9)
            //            make.center.equalToSuperview()
            make.top.equalToSuperview().offset(80)
            make.left.equalToSuperview().offset(24)
        }
        
        cameraSearchButton.snp.makeConstraints{(make) in
            make.height.equalTo(fullScreenSize.height / 9 )
            make.width.equalTo((fullScreenSize.width / 10 ) * 9)
            //            make.center.equalToSuperview()
            make.top.equalToSuperview().offset(80)
            make.left.equalToSuperview().offset(175)
        }
        
        fileSearchButton.snp.makeConstraints{(make) in
            make.height.equalTo(fullScreenSize.height / 9 )
            make.width.equalTo((fullScreenSize.width / 10 ) * 9)
            //            make.center.equalToSuperview()
            make.top.equalToSuperview().offset(196)
            make.left.equalToSuperview().offset(24)
        }
        
        urlSearchButton.snp.makeConstraints{(make) in
            make.height.equalTo(fullScreenSize.height / 9 )
            make.width.equalTo((fullScreenSize.width / 10 ) * 9)
            //            make.center.equalToSuperview()
            make.top.equalToSuperview().offset(196)
            make.left.equalToSuperview().offset(175)
        }
        
        keywordSearchButton.snp.makeConstraints{(make) in
            make.height.equalTo(fullScreenSize.height / 9 )
            make.width.equalTo((fullScreenSize.width / 10 ) * 9)
            //            make.center.equalToSuperview()
            make.top.equalToSuperview().offset(312)
            make.left.equalToSuperview().offset(24)
        }
        
        recordSearchButton.snp.makeConstraints{(make) in
            make.height.equalTo(fullScreenSize.height / 9 )
            make.width.equalTo((fullScreenSize.width / 10 ) * 9)
            //            make.center.equalToSuperview()
            make.top.equalToSuperview().offset(312)
            make.left.equalToSuperview().offset(175)
        }
    }
}
