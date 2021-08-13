//
//  EditWindowViewController.swift
//  Image_Search
//
//  Created by GC on 2021/8/11.
//

import UIKit
import Alamofire

class UrlViewController:UIViewController {
    
    let fullScreenSize = UIScreen.main.bounds.size
    var delegate:MainViewController!
    var type:String!
    
    lazy var leftBarBtn:UIBarButtonItem = {
        let leftBarBtn = UIBarButtonItem()
        return leftBarBtn
    }()
    lazy var backgroundBoard:UIView = {
        let view = UIView()
        view.layer.cornerRadius = fullScreenSize.width / 25
        view.layer.masksToBounds = false
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        if #available(iOS 13.0, *) {
            view.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
            // Fallback on earlier versions
        }
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 8
        return view
    }()
    lazy var cancelBtn:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close_image"), for: .normal)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()
    lazy var titleLable:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica", size: 16)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    lazy var hintTitle: UILabel = {
        let hintTitle = UILabel()
        hintTitle.font = UIFont(name: "Helvetica", size: 14)
        hintTitle.textColor = UIColor.red
        return hintTitle
    }()
    lazy var inputTextField:UITextField = {
        let textField = UITextField()
        var frame = textField.frame
        frame.size.width = 10 // 距离左侧的距离
        let leftview = UIView(frame: frame ?? CGRect.zero)
        textField.leftView = leftview
        textField.leftViewMode = UITextField.ViewMode.always
        //        textField.borderStyle = .roundedRect
        //        textField.clipsToBounds = true
        textField.layer.cornerRadius = 19
        textField.layer.masksToBounds = true
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.backgroundColor = UIColor.clear
        textField.keyboardType = .default
        textField.textAlignment = .left
        textField.delegate = self
        return textField
    }()
    lazy var hintLabel:UILabel = {
        let hintLabel = UILabel()
        hintLabel.font = UIFont(name: "Helvetica", size: 15)
        hintLabel.textColor = UIColor.lightGray
        return hintLabel
    }()
    lazy var searchBtn:UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "searchButtonImage"), for: .normal)
        button.addTarget(self, action: #selector(search), for: .touchUpInside )
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        setupConstrains()
    }
}

// MARK: -
extension UrlViewController {
    
    func urlNetwordRequest(){
        if self.verifyUrl(urlString: self.inputTextField.text) {
            AF.request(self.inputTextField.text!).response{ response in
                print(response.response?.statusCode ?? "")
                if response.error?.errorDescription == "URLSessionTask failed with error: The Internet connection appears to be offline." {
                    self.hintTitle.text = "请连接网络后重试！"
                } else if response.error?.errorDescription == "URLSessionTask failed with error: Could not connect to the server." {
                    self.hintTitle.text = "请输入有效链接！"
                } else if response.response?.statusCode == 404 {
                    self.hintTitle.text = "请输入有效链接！"
                } else {
                    let webViewController = WebViewController()
                    webViewController.delegate = self
                    webViewController.setURL(url: self.inputTextField.text!)
                    self.dismiss(animated: true, completion: nil)
                    self.delegate.goWebViewControllerFromUrlViewController(webViewController: webViewController)
                }
            }
        } else {
            self.hintTitle.text = "请输入合法链接！"
        }
    }
    
    func keywordNetwordRequest(){
        AF.request("https://www.google.com/search?q=" + self.inputTextField.text! + "&tbm=isch").response{ response in
            if response.error?.errorDescription == "URLSessionTask failed with error: The Internet connection appears to be offline." {
                self.hintTitle.text = "请连接网络后重试！"
            } else  {
                let webViewController = WebViewController()
                webViewController.delegate = self
                webViewController.setKeyword(keyword: self.inputTextField.text!)
                self.dismiss(animated: true, completion: nil)
                self.delegate.goWebViewControllerFromUrlViewController(webViewController: webViewController)
            }
        }
    }
    
    @objc func search(){
        
        if self.type == "url" {
            urlNetwordRequest()
        } else {
            keywordNetwordRequest()
        }
        
    }
    
    func verifyUrl(urlString: String?) -> Bool {
        //Check for nil
        print(urlString ?? "")
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    func setType(type:String){
        
        self.type = type
        if self.type == "url" {
            self.titleLable.text = "输入图片URL"
            self.searchBtn.setTitle("导入", for: .normal)
            hintLabel.text = "URL..."
        } else {
            self.titleLable.text = "输入关键词"
            self.searchBtn.setTitle("搜索", for: .normal)
            hintLabel.text = "关键词"
        }
    }
    
    func setDelegate(delegate:MainViewController){
        self.delegate = delegate
    }
    
    @objc func cancel(){
        self.delegate.cancel()
    }
}


//MARK: - TextView
extension UrlViewController:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        print("textFieldDidEndEditing")
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print("textFieldDidChangeSelection")
        if self.hintTitle.text?.count != 0 {
            self.hintTitle.text = ""
        }
        let len = inputTextField.text?.count
        if len! > 0 && !hintTitle.isHidden{
            hintLabel.isHidden = true
        } else if len == 0 {
            hintLabel.isHidden = false
        }
    }
}

// MARK: - UI
extension UrlViewController {
    
    func setupUI() {
        
        self.view.addSubview(backgroundBoard)
        
        backgroundBoard.addSubview(cancelBtn)
        
        backgroundBoard.addSubview(titleLable)
        
        backgroundBoard.addSubview(hintTitle)
        
        backgroundBoard.addSubview(inputTextField)
        
        backgroundBoard.addSubview(searchBtn)
        
        backgroundBoard.addSubview(hintLabel)
        //        self.delegate.view.backgroundColor = .gray
        //        self.delegate.view.alpha = 0.6
    }
    
    func setupConstrains(){
        
        backgroundBoard.snp.makeConstraints{ (make) in
            make.width.equalTo(335)
            make.height.equalTo(204)
            make.top.equalToSuperview().offset(202)
            make.left.equalToSuperview().offset(20)
        }
        
        cancelBtn.snp.makeConstraints{ (make) in
            make.width.equalTo(24)
            make.height.equalTo(24)
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(291)
        }
        
        titleLable.snp.makeConstraints{ (make) in
            make.width.equalTo(103)
            make.height.equalTo(24)
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(116)
            
        }
        
        hintTitle.snp.makeConstraints{ (make) in
            make.width.equalTo(140)
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(52)
            make.left.equalToSuperview().offset(105)
        }
        
        inputTextField.snp.makeConstraints{ (make) in
            make.width.equalTo(295)
            make.height.equalTo(38)
            make.top.equalToSuperview().offset(76)
            make.left.equalToSuperview().offset(20)
        }
        
        hintLabel.snp.makeConstraints{ (make) in
            make.width.equalTo(60)
            make.height.equalTo(21)
            make.top.equalToSuperview().offset(84)
            make.left.equalToSuperview().offset(32)
        }
        
        searchBtn.snp.makeConstraints{ (make) in
            make.width.equalTo(152)
            make.height.equalTo(38)
            make.top.equalToSuperview().offset(138)
            make.left.equalToSuperview().offset(92)
        }
        
    }
}
