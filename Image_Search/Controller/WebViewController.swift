//
//  WebWebViewController.swift
//  Image_Search
//
//  Created by GC on 2021/8/5.
//

import UIKit
import WebKit
import Alamofire

class WebViewController: UIViewController,UITextFieldDelegate, WKNavigationDelegate {
    // 取得螢幕的尺寸
    let fullScreenSize = UIScreen.main.bounds.size
    let googleUrlPrefix = "https://www.google.com.hk/searchbyimage?image_url="
    let yandexUrlPrefix = "https://yandex.com/images/search?family=yes&rpt=imageview&url="
    let sougouUrlPrefix = "https://pic.sogou.com/ris?query="
    
    var delegate:UIViewController?
    var firstlUrl:String!
    var imageLink:String!
    
    lazy var myWebView :WKWebView = {
        let myWebView = WKWebView(frame: CGRect(x: 0, y: 0 , width: fullScreenSize.width, height: fullScreenSize.height - 83 ))
        myWebView.navigationDelegate = self
        return myWebView
    }()
    lazy var myActivityIndicator:UIActivityIndicatorView = {
        let myActivityIndicator = UIActivityIndicatorView(style:.gray)
        return myActivityIndicator
    }()
    lazy var leftBarBtn:UIBarButtonItem = {
        let barBtn = UIBarButtonItem(image: UIImage(named: "back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backToPrevious))
        return barBtn
    }()
    lazy var centerBarBtn:TopButtonView = {
        let barBtn = TopButtonView()
        barBtn.setText(title: "Google")
        barBtn.isUserInteractionEnabled = true
        barBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectSearchEngine)))
        return barBtn
    }()
    lazy var cancelRightBarBtn:UIBarButtonItem = {
        let barBtn = UIBarButtonItem(image: UIImage(named: "cancel.png")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(stop))
        return barBtn
    }()
    lazy var refreshRightBarBtn:UIBarButtonItem = {
        let barBtn = UIBarButtonItem(image: UIImage(named: "refresh")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(reload))
        return barBtn
    }()
    lazy var bottomBackgroundLabel: UIView = {
        let label = UIView()
//        label.layer.cornerRadius = fullScreenSize.width / 20
//        label.layer.masksToBounds = false
//        label.bounds.size.width = fullScreenSize.width
//        label.bounds.size.height = fullScreenSize.height/2
        label.backgroundColor = UIColor.white
        if #available(iOS 13.0, *) {
            label.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
            // Fallback on earlier versions
        }
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.shadowOpacity = 0.3
        label.layer.shadowRadius = 3
        return label
    }()
    lazy var bottomLeftbutton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "back.png"), for: .normal)
        button.addTarget(self, action: #selector(WebViewController.back), for: .touchUpInside)
        return button
    }()
    lazy var bottomRightbutton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "forward.png"), for: .normal)
        button.addTarget(self, action: #selector(WebViewController.forward), for: .touchUpInside)
        return button
    }()
    lazy var bottomIndexbutton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "index.png"), for: .normal)
        button.addTarget(self, action: #selector(WebViewController.goIndex), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstrains()
    }
   
}

//MARK: - WebView
extension WebViewController {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // 顯示進度條
        self.navigationItem.rightBarButtonItem = cancelRightBarBtn
        myActivityIndicator.startAnimating()
        bottomLeftbutton.isEnabled = false
        bottomRightbutton.isEnabled = false
        bottomIndexbutton.isEnabled = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 隱藏進度條
        self.navigationItem.rightBarButtonItem = refreshRightBarBtn
        myActivityIndicator.stopAnimating()
        bottomLeftbutton.isEnabled = true
        bottomRightbutton.isEnabled = true
        bottomIndexbutton.isEnabled = true
        // 更新網址列的內容
        if let currentURL = myWebView.url {
        
        }
    }
}

// MARK: -
extension WebViewController {
    
    @objc func back() {
        // 上一頁
        myWebView.goBack()
    }
    
    @objc func backToPrevious(){
        self.navigationController!.popViewController(animated: true)
    }
    
    @objc func forward() {
        // 下一頁
        myWebView.goForward()
    }
    
    @objc func reload() {
        // 重新讀取
        myWebView.reload()
    }
    
    @objc func stop() {
        // 取消讀取
        myWebView.stopLoading()
        // 隱藏環狀進度條
        myActivityIndicator.stopAnimating()
        self.navigationItem.rightBarButtonItem = refreshRightBarBtn
        bottomLeftbutton.isEnabled = true
        bottomRightbutton.isEnabled = true
        bottomIndexbutton.isEnabled = true
    }
    
    @objc func go() {
        // 隱藏鍵盤
        self.view.endEditing(true)
        myWebView.load(URLRequest(url: URL(string: firstlUrl)!))
        // 你也可以設置 HTML 內容到一個常數
        // 用來載入一個靜態的網頁內容
        // let content = "<html><body><h1>Hello World !</h1></body></html>"
        // myWebView.loadHTMLString(content, baseURL: nil)
    }
    
    @objc func goIndex(){
        myWebView.load(URLRequest(url: URL(string: firstlUrl)!))
    }
    
    func setURL(url:String){
        imageLink = url
        firstlUrl = "https://www.google.com.hk/searchbyimage?image_url=" + url
        print(firstlUrl)
    }
    
    func goole() {
        
    }
    
    @objc func selectSearchEngine(){
        print("selectEngine")
        // 建立一個提示框
        let alertController = UIAlertController(
            title: "请选择搜索引擎", message: nil,
            preferredStyle: .actionSheet)
        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(
          title: "取消",
          style: .cancel,
          handler: nil)
        alertController.addAction(cancelAction)
        
        // 建立[確認]按鈕
        let google = UIAlertAction(
          title: "Google",
          style: .default,
            handler: {_ in
                self.firstlUrl = self.googleUrlPrefix + self.imageLink
                self.myWebView.load(URLRequest(url: URL(string: self.firstlUrl)!))
                self.centerBarBtn.setText(title: "Google")
          })
        alertController.addAction(google)
        
        let yandex = UIAlertAction(
          title: "Yandex",
          style: .default,
          handler: {_ in
            self.centerBarBtn.setText(title: "Yandex")
            self.firstlUrl = self.yandexUrlPrefix + self.imageLink
            self.myWebView.load(URLRequest(url: URL(string: self.firstlUrl)!))
      })
        alertController.addAction(yandex)
        
        let souGou = UIAlertAction(
          title: "Sougou",
          style: .default,
          handler: {_ in
            self.centerBarBtn.setText(title: "Sougo")
            self.firstlUrl = self.sougouUrlPrefix + self.imageLink
            self.myWebView.load(URLRequest(url: URL(string: self.firstlUrl)!))
      })
        alertController.addAction(souGou)
        
        // 顯示提示框
        self.present(
          alertController,
          animated: true,
          completion: nil)
    }
    
}

// MARK: - UI
extension WebViewController {
    
    func setupUI(){
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.view.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = leftBarBtn
        self.navigationItem.titleView = centerBarBtn
        self.view.addSubview(self.myWebView)
        myActivityIndicator.center = CGPoint(x: fullScreenSize.width * 0.5, y: fullScreenSize.height * 0.5)
        self.view.addSubview(myActivityIndicator);
        self.view.addSubview(bottomBackgroundLabel)
        bottomBackgroundLabel.addSubview(bottomLeftbutton)
        bottomBackgroundLabel.addSubview(bottomRightbutton)
        bottomBackgroundLabel.addSubview(bottomIndexbutton)
        self.go()
    }
    
    func setupConstrains(){
        
        myWebView.snp.makeConstraints{(make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(bottomBackgroundLabel).offset(-83)
        }
        
        myActivityIndicator.snp.makeConstraints{(make) in
            make.bottom.equalToSuperview().multipliedBy(0.4)
            make.centerX.equalToSuperview()
        }
        
        bottomBackgroundLabel.snp.makeConstraints{(make) in
            make.height.equalTo(83)
            make.bottom.left.right.equalToSuperview()
        }
        
        bottomLeftbutton.snp.makeConstraints{(make) in
            make.bottom.equalToSuperview().offset(-47)
            make.left.equalToSuperview().offset(52)
        }
        
        bottomRightbutton.snp.makeConstraints{(make) in
            make.bottom.equalToSuperview().offset(-42)
            make.left.equalToSuperview().offset(124)
        }
        
        bottomIndexbutton.snp.makeConstraints{ (make) in
            make.bottom.equalToSuperview().offset(-49)
            make.right.equalToSuperview().offset(-54)
        }
    }
}
