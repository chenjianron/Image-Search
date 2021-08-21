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
    let urlSearchEngineUrlPrefix = ["https://www.google.com.hk/searchbyimage?image_url=","https://yandex.com/images/search?family=yes&rpt=imageview&url=","https://pic.sogou.com/ris?query="]
    let keywordSearchEngineUrlPrefix = ["https://www.google.com/search?q=","&tbm=isch", "https://yandex.com/images/search?from=tabbar&text=","https://pic.sogou.com/pics?query=","https://cn.bing.com/images/search?q="]
    let googleUrlPrefix = "https://www.google.com.hk/searchbyimage?image_url="
    let yandexUrlPrefix = "https://yandex.com/images/search?family=yes&rpt=imageview&url="
    let sougouUrlPrefix = "https://pic.sogou.com/ris?query="
    
    var delegate:UIViewController?
    var firstUrl:String!
    var imageLink:String?
    var keyword:String!
    var observation: NSKeyValueObservation! = nil
    var isStop = false
    var isLoding = false
    
    lazy var myWebView :WKWebView = {
        var javascript = ""
        javascript += "document.documentElement.style.webkitTouchCallout='none';" //禁止长按
        let noneSelectScript = WKUserScript(source: javascript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let config = WKWebViewConfiguration()
        config.userContentController.addUserScript(noneSelectScript)
        let myWebView = WKWebView(frame: CGRect(x: 0, y: 0 , width: fullScreenSize.width, height: fullScreenSize.height - 83 ),configuration: config)
        myWebView.navigationDelegate = self
        myWebView.uiDelegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: nil)
        longPress.minimumPressDuration = 0.3
        longPress.numberOfTapsRequired = 1
        myWebView.addGestureRecognizer(longPress)
        return myWebView
    }()
    lazy var progressView: UIProgressView = {
        let  progressView: UIProgressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = UIColor.init(hex: 0x13A5FF, alpha: 1)
        progressView.progress = 0.05
        progressView.trackTintColor = UIColor.white
        return progressView
    }()
    lazy var myActivityIndicator:UIActivityIndicatorView = {
        let myActivityIndicator = UIActivityIndicatorView(style:.gray)
        myActivityIndicator.center = CGPoint(x: fullScreenSize.width * 0.5, y: fullScreenSize.height * 0.5)
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
    lazy var networkErrorImageView: UIImageView = {
        let searchImageView = UIImageView()
        searchImageView.image = UIImage(named: "network_error.png")
        return searchImageView
    }()
    lazy var networkErrorHint: UILabel = {
        let searchImageView = UILabel()
        searchImageView.text = __("网络超时，请重试")
        return searchImageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstrains()
    }
    
}

//MARK: - WebView
extension WebViewController: WKUIDelegate {
    
    @objc func startLongPress(pressSender: UILongPressGestureRecognizer) { if pressSender.state == .began {
        let touchPoint = pressSender.location(in: pressSender.view)
        let jsString = String(
            format: """
                            function getURLandRect(){\
                              var ele=document.elementFromPoint(%f, %f);\
                              var url=ele.src;\
                              var jsonString= `{"url":"${url}"}`;\
                              return(jsonString)} getURLandRect()
                            """, touchPoint.x, touchPoint.y)
        myWebView.evaluateJavaScript(jsString) { [self] result, error in
            let data = (result as! String).data(using: .utf8)
            var resultDic: [AnyHashable : Any]? = nil
            do {
                if let data = data {
                    resultDic = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable : Any]
                }
            } catch {
            }
            let imageURL = resultDic?["url"] as? String
            if (imageURL?.count ?? 0) == 0 || (imageURL == "undefined") {
                return
            }
            var imageData: Data? = nil
            if (imageURL?.hasPrefix("http")) ?? false {
                if let url = URL(string: imageURL ?? "") {
                    let semaphore = DispatchSemaphore(value: 0)
                    //imageData = try NSURLConnection.sendSynchronousRequest(URLRequest(url: url), returning: nil)
                    //创建 NSURLSession 对象
                    let session = URLSession.shared
                    let dataTask = session.dataTask(with: url) { data, response, error in
                        if error == nil {
                            imageData = data
                        }
                        semaphore.signal()
                    }
                    dataTask.resume()
                    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
                }
            } else {
                let dataString = imageURL?.components(separatedBy: ",").last
                //            imageData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
                imageData = Data(base64Encoded: dataString ?? "", options: .ignoreUnknownCharacters)
            }
            var image: UIImage? = nil
            if let imageData = imageData {
                image = UIImage(data: imageData)
            }
            if let image = image {
                let imageHandleAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let searchHandle = UIAlertAction(title: __("搜索图片"), style: .default) { (alertAction) in
                }
                let copyHandle = UIAlertAction(title: __("复制图片"), style: .default) { (alertAction) in
                    UIPasteboard.general.image = image
                    //                    self.successCopyPhoto()
                }
                let saveHandle = UIAlertAction(title: __("保存图片"), style: .default) { (alertAction) in
                    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
                    //                    self.successSavePhoto()
                }
                let cancleHandle = UIAlertAction(title: __("取消"), style: .cancel, handler: nil)
                imageHandleAlertController.addAction(searchHandle)
                imageHandleAlertController.addAction(copyHandle)
                imageHandleAlertController.addAction(saveHandle)
                imageHandleAlertController.addAction(cancleHandle)
                imageHandleAlertController.popoverPresentationController?.sourceView = myWebView
                let pressLocation = pressSender.location(in: myWebView)
                //                imageHandleAlertController.popoverPresentationController?.sourceRect =  CGRect(x: pressLocation.x, y: pressLocation.y - 44, width: alertView.size.width, height: alertView.size.height)// why -44?
                present(imageHandleAlertController, animated: true, completion: nil)
            }
        }
    }
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        print("didStartProvisionalNavigation")
        progressView.isHidden = false//展示
        self.isLoding = true
        self.myActivityIndicator.startAnimating()
        self.navigationItem.rightBarButtonItem = cancelRightBarBtn
        self.bottomLeftbutton.isEnabled = false
        self.bottomRightbutton.isEnabled = false
        self.bottomIndexbutton.isEnabled = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("didFinish")
        self.isLoding = false
        myActivityIndicator.stopAnimating()
        progressView.isHidden = true
        leftRightBtnState()
        self.navigationItem.rightBarButtonItem = refreshRightBarBtn
        bottomIndexbutton.isEnabled = true
        if isStop == true {
            isStop = false
        }
        // 更新網址列的內容
        if myWebView.url != nil {
            
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        print("didFail navigation")
        print(error)
        // 隱藏進度條
        self.isLoding = false
        myActivityIndicator.stopAnimating()
        progressView.isHidden = true
        self.navigationItem.rightBarButtonItem = refreshRightBarBtn
        leftRightBtnState()
        bottomIndexbutton.isEnabled = true
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        print("didFaiProvisionalNavigation")
        print(error)
        if self.isStop == false {
            self.navigationItem.rightBarButtonItem = refreshRightBarBtn
            // 隱藏進度條
            self.myActivityIndicator.stopAnimating()
            self.progressView.isHidden = true
            self.networkErrorImageView.isHidden = false
            self.networkErrorHint.isHidden = false
            self.myWebView.isHidden = true
            leftRightBtnState()
            self.bottomIndexbutton.isEnabled = true
        }
        self.isLoding = false
        self.isStop = false
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    }
}
// MARK: -
extension WebViewController {
    
    func leftRightBtnState(){
        
        if myWebView.canGoBack == false {
            print(myWebView.canGoBack)
            self.bottomLeftbutton.isEnabled = false
        } else {
            self.bottomLeftbutton.isEnabled = true
            
        }
        if myWebView.canGoForward == false {
            self.bottomRightbutton.isEnabled = false
        } else {
            self.bottomRightbutton.isEnabled = true
        }
    }
    
    @objc func back() {
        // 上一頁
        if self.myWebView.isHidden == true {
            self.myWebView.isHidden = false
            self.networkErrorImageView.isHidden = true
            self.networkErrorHint.isHidden = true
        }
        myWebView.goBack()
    }
    
    @objc func backToPrevious(){
        
        self.navigationController!.popViewController(animated: true)
    }
    
    @objc func forward() {
        // 下一頁
        if self.myWebView.isHidden {
            self.myWebView.isHidden = false
            self.networkErrorImageView.isHidden = true
            self.networkErrorHint.isHidden = true
        }
        myWebView.goForward()
    }
    
    @objc func reload() {
        // 重新讀取
        if self.myWebView.isHidden {
            self.myWebView.isHidden = false
            self.networkErrorImageView.isHidden = true
            self.networkErrorHint.isHidden = true
        }
        myWebView.reload()
    }
    
    @objc func stop() {
        
        myActivityIndicator.stopAnimating()
        self.navigationItem.rightBarButtonItem = refreshRightBarBtn
        leftRightBtnState()
        bottomIndexbutton.isEnabled = true
        progressView.isHidden = true
        isStop = true
        myWebView.stopLoading()
        
    }
    
    @objc func go() {
        // 隱藏鍵盤
        self.view.endEditing(true)
        if self.imageLink == nil {
            self.firstUrl = self.firstUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        }
        myWebView.load(URLRequest(url: URL(string: self.firstUrl)!))
        // 你也可以設置 HTML 內容到一個常數
        // 用來載入一個靜態的網頁內容
        // let content = "<html><body><h1>Hello World !</h1></body></html>"
        // myWebView.loadHTMLString(content, baseURL: nil)
    }
    
    @objc func goIndex(){
        if self.myWebView.isHidden {
            self.networkErrorImageView.isHidden = true
            self.networkErrorHint.isHidden = false
            self.myWebView.isHidden = false
        }
        myWebView.load(URLRequest(url: URL(string: self.firstUrl)!))
    }
    
    func setURL(url:String){
        imageLink = url
        firstUrl = "https://www.google.com.hk/searchbyimage?image_url=" + url
    }
    
    func setKeyword(keyword:String){
        self.keyword = keyword
        self.firstUrl =  keywordSearchEngineUrlPrefix[0] + self.keyword + keywordSearchEngineUrlPrefix[1]
        print(self.firstUrl)
    }
    
    @objc func selectUrlSearchEngine(){
        // 建立一個提示框
        let alertController = UIAlertController(
            title: __("请选择搜索引擎"), message: nil,
            preferredStyle: .actionSheet)
        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(
            title: __("取消"),
            style: .cancel,
            handler: nil)
        alertController.addAction(cancelAction)
        
        // 建立[確認]按鈕
        let google = UIAlertAction(
            title: "Google",
            style: .default,
            handler: {_ in
                self.networkErrorImageView.isHidden = true
                self.networkErrorHint.isHidden = false
                self.myWebView.isHidden = false
                self.firstUrl = self.googleUrlPrefix + self.imageLink!
                self.centerBarBtn.setText(title: "Google")
                if self.isLoding {
                    self.stop()
                }
                self.myWebView.load(URLRequest(url: URL(string: self.firstUrl)!))
            })
        alertController.addAction(google)
        
        let yandex = UIAlertAction(
            title: "Yandex",
            style: .default,
            handler: {_ in
                self.networkErrorImageView.isHidden = true
                self.networkErrorHint.isHidden = false
                self.myWebView.isHidden = false
                self.centerBarBtn.setText(title: "Yandex")
                self.firstUrl = self.yandexUrlPrefix + self.imageLink!
                if self.isLoding {
                    self.stop()
                }
                self.myWebView.load(URLRequest(url: URL(string: self.firstUrl)!))
            })
        alertController.addAction(yandex)
        
        let souGou = UIAlertAction(
            title: "Sougou",
            style: .default,
            handler: {_ in
                self.networkErrorImageView.isHidden = true
                self.networkErrorHint.isHidden = false
                self.myWebView.isHidden = false
                self.centerBarBtn.setText(title: "Sougou")
                self.firstUrl = self.sougouUrlPrefix + self.imageLink!
                if self.isLoding {
                    self.stop()
                }
                self.myWebView.load(URLRequest(url: URL(string: self.firstUrl)!))
            })
        alertController.addAction(souGou)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        //        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
        //
        //                    if let currentPopoverpresentioncontroller = alertController.popoverPresentationController{
        //                        currentPopoverpresentioncontroller.barButtonItem = sender as! UIBarButtonItem
        //                        currentPopoverpresentioncontroller.permittedArrowDirections = UIPopoverArrowDirection.down;
        //                        self.present(alertController, animated: true, completion: nil)
        //                    }
        //                }else{
        //                    self.present(alertController, animated: true, completion: nil)
        //                }
        
        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
    }
    
    @objc func selectKeywordUrlSearchEngine(){
        // 建立一個提示框
        let alertController = UIAlertController(
            title: __("请选择搜索引擎"), message: nil,
            preferredStyle: .actionSheet)
        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(
            title: __("取消"),
            style: .cancel,
            handler: nil)
        alertController.addAction(cancelAction)
        
        // 建立[確認]按鈕
        let google = UIAlertAction(
            title: "Google",
            style: .default,
            handler: {_ in
                self.networkErrorImageView.isHidden = true
                self.networkErrorHint.isHidden = false
                self.myWebView.isHidden = false
                self.firstUrl = self.keywordSearchEngineUrlPrefix[0] + self.keyword + self.keywordSearchEngineUrlPrefix[1]
                self.firstUrl = self.firstUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                self.centerBarBtn.setText(title: "Google")
                if self.isLoding {
                    self.stop()
                }
                self.myWebView.load(URLRequest(url: URL(string: self.firstUrl)!))
            })
        alertController.addAction(google)
        
        let yandex = UIAlertAction(
            title: "Yandex",
            style: .default,
            handler: {_ in
                self.networkErrorImageView.isHidden = true
                self.networkErrorHint.isHidden = false
                self.myWebView.isHidden = false
                self.centerBarBtn.setText(title: "Yandex")
                self.firstUrl = self.keywordSearchEngineUrlPrefix[2] + self.keyword
                self.firstUrl = self.firstUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                if self.isLoding {
                    self.stop()
                }
                self.myWebView.load(URLRequest(url: URL(string: self.firstUrl)!))
            })
        alertController.addAction(yandex)
        
        let souGou = UIAlertAction(
            title: "Sougou",
            style: .default,
            handler: {_ in
                self.networkErrorImageView.isHidden = true
                self.networkErrorHint.isHidden = false
                self.myWebView.isHidden = false
                self.centerBarBtn.setText(title: "Sougou")
                self.firstUrl = self.keywordSearchEngineUrlPrefix[3] + self.keyword
                self.firstUrl = self.firstUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                if self.isLoding {
                    self.stop()
                }
                self.myWebView.load(URLRequest(url: URL(string: self.firstUrl)!))
            })
        alertController.addAction(souGou)
        
        let bing = UIAlertAction(
            title: "Bing",
            style: .default,
            handler: {_ in
                self.networkErrorImageView.isHidden = true
                self.networkErrorHint.isHidden = false
                self.myWebView.isHidden = false
                self.centerBarBtn.setText(title: "Bing")
                self.firstUrl = self.keywordSearchEngineUrlPrefix[4] + self.keyword
                self.firstUrl = self.firstUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                if self.isLoding {
                    self.stop()
                }
                self.myWebView.load(URLRequest(url: URL(string: self.firstUrl)!))
            })
        alertController.addAction(bing)
        
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
        
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBarBtn
        if self.imageLink == nil {
            centerBarBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectKeywordUrlSearchEngine)))
        } else {
            centerBarBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectUrlSearchEngine)))
        }
        self.navigationItem.titleView = centerBarBtn
        self.view.addSubview(self.myWebView)
        self.view.addSubview(self.networkErrorImageView)
        self.view.addSubview(networkErrorHint)
        self.view.sendSubviewToBack(self.networkErrorImageView)
        self.view.bringSubviewToFront(self.myWebView)
        self.view.addSubview(myActivityIndicator);
        self.view.addSubview(bottomBackgroundLabel)
        self.myWebView.addSubview(progressView)
        bottomBackgroundLabel.addSubview(bottomLeftbutton)
        bottomBackgroundLabel.addSubview(bottomRightbutton)
        bottomBackgroundLabel.addSubview(bottomIndexbutton)
        observation = myWebView.observe(\.estimatedProgress, options: [.new]) { _, _ in
            self.progressView.progress = Float(self.myWebView.estimatedProgress)
        }
        self.networkErrorImageView.isHidden = true
        self.networkErrorHint.isHidden = true
        
        self.go()
    }
    
    func setupConstrains(){
        
        myWebView.snp.makeConstraints{(make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(bottomBackgroundLabel).offset(-83)
        }
        
        progressView.snp.makeConstraints{ (make) in
            make.top.equalTo(safeAreaTop).offset(0)
            make.height.equalTo(4)
            make.width.equalToSuperview()
        }
        
        networkErrorImageView.snp.makeConstraints{
            (make) in
            make.top.equalTo(safeAreaTop).offset(142)
            make.left.equalToSuperview().offset(46)
        }
        
        networkErrorHint.snp.makeConstraints{
            (make) in
            make.top.equalTo(safeAreaTop).offset(372)
            make.left.equalToSuperview().offset(132)
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
