//
//  WebWebViewController.swift
//  Image_Search
//
//  Created by GC on 2021/8/5.
//

import UIKit
import WebKit
import Alamofire
import Photos

class WebViewController: UIViewController,UITextFieldDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate{
        
    var delegate:UIViewController?
    var firstUrl:String!
    var imageLink:String?
    var keyword:String!
    var observation: NSKeyValueObservation! = nil
    var isStop = false
    var isLoding = false
    
    var bannerView: UIView? {
        return Marketing.shared.bannerView(.webBanner, rootViewController: self)
    }
    var bannerInset: CGFloat {
        if bannerView != nil {
            return Ad.default.adaptiveBannerHeight
        } else {
            return 0
        }
    }
    lazy var myWebView :WKWebView = {
        var javascript = ""
        javascript += "document.documentElement.style.webkitTouchCallout='none';" //禁止长按
        let noneSelectScript = WKUserScript(source: javascript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let config = WKWebViewConfiguration()
        config.userContentController.addUserScript(noneSelectScript)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(startLongPress(pressSender:)))
        longPress.delegate = self
        longPress.minimumPressDuration = 0.4
        longPress.numberOfTouchesRequired = 1
        longPress.cancelsTouchesInView = true
        
        let myWebView = WKWebView(frame: CGRect(x: 0, y: 0 , width: fullScreenSize.width, height: fullScreenSize.height - 49),configuration: config)
        myWebView.navigationDelegate = self
        myWebView.uiDelegate = self
        myWebView.addGestureRecognizer(longPress)
        
        return myWebView
    }()
    lazy var progressView: UIProgressView = {
        let progressView: UIProgressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = UIColor.init(hex: 0x13A5FF, alpha: 1)
        progressView.progress = 0.05
        progressView.trackTintColor = UIColor.white
        return progressView
    }()
    lazy var leftBarBtn:UIBarButtonItem = {
        let barBtn = UIBarButtonItem(image: UIImage(named: "back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backToPrevious))
        return barBtn
    }()
    lazy var centerBarBtn:TopButtonView = {
        let barBtn = TopButtonView()
        barBtn.setText(title: urlSearchEngineName[0])
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
        label.layer.shadowOffset = CGSize(width: -2, height: -3)
        label.layer.shadowOpacity = 0.1
        label.layer.shadowRadius = 1
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
        button.setImage(UIImage(named: "forward"), for: .normal)
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
    lazy var hintAlert:AlertView = {
        let alert = AlertView()
        return alert
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstrains()
        setupAdBannerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Statistics.beginLogPageView("搜索结果页")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Statistics.endLogPageView("搜索结果页")
    }
    
}

//MARK: - WKWebView
extension WebViewController: WKUIDelegate {
    
    @objc func startLongPress(pressSender: UILongPressGestureRecognizer) {
        if pressSender.state == .began {
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
                guard result != nil else {return }
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
                        Statistics.event(.SearchResultTap, label: "搜索图片")
                        let ctx = Ad.default.interstitialSignal(key: K.ParamName.SearchImageInterstitial)
                        ctx.didEndAction = { [self] _ in
                            let headers:HTTPHeaders = [
                                "Content-type": "text/html; charset=GBK"
                            ]
                            AF.upload(multipartFormData: { (multipartFormData) in
                                multipartFormData.append((( image as UIImage?)!.jpegData(compressionQuality: 0.8))! , withName: "source", fileName: "YourImageName"+".jpeg", mimeType: "image/jpeg")
                            },  to: "http://pic.sogou.com/pic/upload_pic.jsp?", method: .post, headers: headers).responseString { [self] (result) in
                                if let lastUrl = result.value{
                                        secondSearch(image, lastUrl)
                                } else {
                                    print(__("上传失败"))
                                    print(result.error?.errorDescription ?? " ")
                                    if result.error?.errorDescription == "URLSessionTask failed with error: \(__("似乎已断开与互联网的连接。"))" {
                                        showNetworkErrorAlert(self)
                                    }
                                }
                            }
                        }
                    }
                    let copyHandle = UIAlertAction(title: __("复制图片"), style: .default) { (alertAction) in
                        UIPasteboard.general.image = image
                        Statistics.event(.SearchResultTap, label: "复制图片")
                        self.setAlert(title: "已复制到粘贴板中", image: "ok_icon")
                    }
                    let saveHandle = UIAlertAction(title: __("保存图片"), style: .default) { (alertAction) in
                        Statistics.event(.SearchResultTap, label: "保存图片")
                        let ctx = Ad.default.interstitialSignal(key: K.ParamName.SaveImageInterstitial)
                        ctx.didEndAction = { [self] _ in
                            saveImage(image: image)
                        }
                    }
                    let cancleHandle = UIAlertAction(title: __("取消"), style: .cancel, handler: nil)
                    imageHandleAlertController.addAction(searchHandle)
                    imageHandleAlertController.addAction(copyHandle)
                    imageHandleAlertController.addAction(saveHandle)
                    imageHandleAlertController.addAction(cancleHandle)
                    // imageHandleAlertController.popoverPresentationController?.sourceView = webView
                    let pressLocation = pressSender.location(in: myWebView)
                    imageHandleAlertController.popoverPresentationController?.sourceRect =  CGRect(x: pressLocation.x, y: pressLocation.y - 44, width: fullScreenSize.width, height: fullScreenSize.height / 2 )// why -44?
                    present(imageHandleAlertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        print("didStartProvisionalNavigation")
        progressView.isHidden = false//展示
        self.isLoding = true
        self.navigationItem.rightBarButtonItem = cancelRightBarBtn
        self.bottomLeftbutton.isEnabled = false
        self.bottomRightbutton.isEnabled = false
        self.bottomIndexbutton.isEnabled = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("didFinish")
        self.isLoding = false
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

// MARK: -
extension WebViewController {
    
    func secondSearch(_ image:UIImage, _ lastUrl:String){
        imageLink = lastUrl
        SQL.insert(imagedata: (image as UIImage).jpegData(compressionQuality: 0.8)! as Data)
        if centerBarBtn.textLabel.text == "Bing"{
            myWebView.load(URLRequest(url: URL(string:(urlSearchEngineUrlPrefix[2]+lastUrl).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!))
        } else if centerBarBtn.textLabel.text == "Yandex" {
            if inChina() {
                myWebView.load(URLRequest(url: URL(string:(urlSearchEngineUrlPrefix[0] + lastUrl).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!))
            } else {
                myWebView.load(URLRequest(url: URL(string:(urlSearchEngineUrlPrefix[1] + lastUrl).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!))
            }
                
        } else if centerBarBtn.textLabel.text == "Google" {
            myWebView.load(URLRequest(url: URL(string:(urlSearchEngineUrlPrefix[0] + lastUrl).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!))
        } else if centerBarBtn.textLabel.text == "Sougou"{
            myWebView.load(URLRequest(url: URL(string:(urlSearchEngineUrlPrefix[1] + lastUrl).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!))
        }
    }
    
    func showNetworkErrorAlert(_ container: UIViewController){
        
        let alertController = UIAlertController(title: nil,message: __("网络超时，请重试"),preferredStyle: .alert)
        container.present(alertController,animated: true,completion: nil)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (ktimer) in
            container.dismiss(animated: true, completion: nil)
        }
    }

    
    func setAlert(title:String,image:String){
        hintAlert.dataSouce(title: __("\(title)"), image: image)
        hintAlert.isHidden = false
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (ktimer) in
            self.hintAlert.isHidden = true
        }
    }
    
    func saveImage(image: UIImage) {
        
        let ctx = Ad.default.interstitialSignal(key: K.ParamName.SaveImageInterstitial)
        ctx.didEndAction = { [self] _ in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { [weak self](isSuccess, error) in
                DispatchQueue.main.async { [self] in
                    if isSuccess {// 成功
                        self!.setAlert(title: __("已保存到相册"), image: "ok_icon")
                    } else {
                        self!.setAlert(title: __("保存失败"), image: "fail_icon")
                    }
                }
            })
        }
    }
    
    func leftRightBtnState(){
            self.bottomLeftbutton.isEnabled = myWebView.canGoBack
            self.bottomRightbutton.isEnabled = myWebView.canGoForward
    }
    
    @objc func back() {
        Statistics.event(.SearchResultTap, label: "上一页")
        // 上一頁
        if self.myWebView.isHidden == true {
            self.myWebView.isHidden = false
            self.networkErrorImageView.isHidden = true
            self.networkErrorHint.isHidden = true
        }
        myWebView.goBack()
    }
    
    @objc func backToPrevious(){
        Statistics.event(.SearchResultTap, label: "退出")
        self.navigationController!.popViewController(animated: true)
    }
    
    @objc func forward() {
        Statistics.event(.SearchResultTap, label: "下一页")
        // 下一頁
        if self.myWebView.isHidden {
            self.myWebView.isHidden = false
            self.networkErrorImageView.isHidden = true
            self.networkErrorHint.isHidden = true
        }
        myWebView.goForward()
    }
    
    @objc func reload() {
        Statistics.event(.SearchResultTap, label: "刷新")
        // 重新讀取
        if self.myWebView.isHidden {
            self.myWebView.isHidden = false
            self.networkErrorImageView.isHidden = true
            self.networkErrorHint.isHidden = true
        }
        myWebView.reload()
    }
    
    @objc func stop() {
        Statistics.event(.SearchResultTap, label: "取消刷新")
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
        self.firstUrl = self.firstUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        myWebView.load(URLRequest(url: URL(string: self.firstUrl)!))
        // 你也可以設置 HTML 內容到一個常數
        // 用來載入一個靜態的網頁內容
        // let content = "<html><body><h1>Hello World !</h1></body></html>"
        // myWebView.loadHTMLString(content, baseURL: nil)
    }
    
    @objc func goIndex(){
        Statistics.event(.SearchResultTap, label: "主页")
        if centerBarBtn.textLabel.text == "Bing"{
                myWebView.load(URLRequest(url: URL(string:"https://www.bing.com/")!))
        } else if centerBarBtn.textLabel.text == "Yandex" {
                myWebView.load(URLRequest(url: URL(string:"https://yandex.com/")!))
        } else if centerBarBtn.textLabel.text == "Google" {
            myWebView.load(URLRequest(url: URL(string:"https://www.google.com/")!))
        } else if centerBarBtn.textLabel.text == "Sougou"{
            myWebView.load(URLRequest(url: URL(string:"https://www.sogou.com/")!))
        }
    }
    
    func setURL(url:String){
        imageLink = url
        firstUrl = urlSearchEngineUrlPrefix[0] + imageLink!
        
    }
    
    func setKeyword(keyword:String){
        Statistics.event(.SearchResultTap, label: "搜索引擎")
        self.keyword = keyword
        if inChina() {
            self.firstUrl =  keywordSearchEngineUrlPrefix[0] + self.keyword
        } else {
            self.firstUrl =  keywordSearchEngineUrlPrefix[0] + self.keyword + keywordSearchEngineUrlPrefix[1]
        }
        
    }
    
    @objc func selectUrlSearchEngine(){
        Statistics.event(.SearchResultTap, label: "搜索引擎")
        // 建立一個提示框
        let alertController = UIAlertController(title: __("请选择搜索引擎"), message: nil,preferredStyle: .actionSheet)
        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(title: __("取消"), style: .cancel, handler: { _ in
            Statistics.event(.SearchEngineTap, label: "取消")
        })
        alertController.addAction(cancelAction)
        
        // 建立[確認]按鈕
        let first = UIAlertAction(title: urlSearchEngineName[0],style: .default,
            handler: {_ in
                Statistics.event(.SearchEngineTap, label:urlSearchEngineName[0])
                self.networkErrorImageView.isHidden = true
                self.networkErrorHint.isHidden = false
                self.myWebView.isHidden = false
                self.firstUrl = urlSearchEngineUrlPrefix[0] + self.imageLink!
                self.firstUrl = self.firstUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                self.centerBarBtn.setText(title: urlSearchEngineName[0])
                if self.isLoding {
                    self.stop()
                }
                self.myWebView.load(URLRequest(url: URL(string: self.firstUrl)!))
            })
        alertController.addAction(first)
        
        let second = UIAlertAction(title: urlSearchEngineName[1],style: .default,
            handler: {_ in
                Statistics.event(.SearchEngineTap, label: urlSearchEngineName[1])
                self.networkErrorImageView.isHidden = true
                self.networkErrorHint.isHidden = false
                self.myWebView.isHidden = false
                self.centerBarBtn.setText(title: urlSearchEngineName[1])
                self.firstUrl = urlSearchEngineUrlPrefix[1] + self.imageLink!
                self.firstUrl = self.firstUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                if self.isLoding {
                    self.stop()
                }
                self.myWebView.load(URLRequest(url: URL(string: self.firstUrl)!))
            })
        alertController.addAction(second)
        
        let third = UIAlertAction(title: urlSearchEngineName[2],style: .default,
            handler: {_ in
                Statistics.event(.SearchEngineTap, label: "Sougou")
                self.networkErrorImageView.isHidden = true
                self.networkErrorHint.isHidden = false
                self.myWebView.isHidden = false
                self.centerBarBtn.setText(title: urlSearchEngineName[2])
                self.firstUrl = urlSearchEngineUrlPrefix[2] + self.imageLink!
                self.firstUrl = self.firstUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                if self.isLoding {
                    self.stop()
                }
                self.myWebView.load(URLRequest(url: URL(string: self.firstUrl)!))
            })
        alertController.addAction(third)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        // 顯示提示框
        self.present(alertController,animated: true,completion: nil)
    }
    
    @objc func selectKeywordUrlSearchEngine(){
        Statistics.event(.SearchResultTap, label: "搜索引擎")
        // 建立一個提示框
        let alertController = UIAlertController(title: __("请选择搜索引擎"), message: nil,preferredStyle: .actionSheet)
        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(title: __("取消"),style: .cancel,handler: {_ in
            Statistics.event(.SearchEngineTap, label: "取消")
        })
        alertController.addAction(cancelAction)
        
        // 建立[確認]按鈕
        let first = UIAlertAction(title: keywordSearchEngineUrlName[0],style: .default,
            handler: {_ in
                Statistics.event(.SearchEngineTap, label: "Google")
                self.networkErrorImageView.isHidden = true
                self.networkErrorHint.isHidden = false
                self.myWebView.isHidden = false
                if inChina() {
                    self.firstUrl = keywordSearchEngineUrlPrefix[0] + self.keyword
                    self.firstUrl = self.firstUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                } else {
                    self.firstUrl = keywordSearchEngineUrlPrefix[0] + self.keyword + keywordSearchEngineUrlPrefix[1]
                    self.firstUrl = self.firstUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                }
                self.centerBarBtn.setText(title: keywordSearchEngineUrlName[0])
                if self.isLoding {
                    self.stop()
                }
                self.myWebView.load(URLRequest(url: URL(string: self.firstUrl)!))
            })
        alertController.addAction(first)
        
        let second = UIAlertAction(title: keywordSearchEngineUrlName[1],style: .default,
            handler: {_ in
                Statistics.event(.SearchEngineTap, label: "Yandex")
                self.networkErrorImageView.isHidden = true
                self.networkErrorHint.isHidden = false
                self.myWebView.isHidden = false
                self.centerBarBtn.setText(title: keywordSearchEngineUrlName[1])
                if inChina() {
                    self.firstUrl = keywordSearchEngineUrlPrefix[1] + self.keyword
                    self.firstUrl = self.firstUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                } else {
                    self.firstUrl = keywordSearchEngineUrlPrefix[2] + self.keyword
                    self.firstUrl = self.firstUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                }
                if self.isLoding {
                    self.stop()
                }
                self.myWebView.load(URLRequest(url: URL(string: self.firstUrl)!))
            })
        alertController.addAction(second)
        
        let third = UIAlertAction(title: keywordSearchEngineUrlName[2],style: .default,
            handler: {_ in
                Statistics.event(.SearchEngineTap, label: "Sougou")
                self.networkErrorImageView.isHidden = true
                self.networkErrorHint.isHidden = false
                self.myWebView.isHidden = false
                self.centerBarBtn.setText(title: keywordSearchEngineUrlName[2])
                if inChina() {
                    self.firstUrl = keywordSearchEngineUrlPrefix[2] + self.keyword
                    self.firstUrl = self.firstUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                } else {
                    self.firstUrl = keywordSearchEngineUrlPrefix[3] + self.keyword
                    self.firstUrl = self.firstUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                }
                if self.isLoding {
                    self.stop()
                }
                self.myWebView.load(URLRequest(url: URL(string: self.firstUrl)!))
            })
        alertController.addAction(third)
    
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
    }
    
}

// MARK: - UI
extension WebViewController {
    
    func setupAdBannerView() {
        
        if let bannerView = self.bannerView {
            view.addSubview(bannerView)
            bannerView.snp.makeConstraints { make in
                make.top.equalTo(safeAreaTop).offset(4)
                make.left.right.equalToSuperview()
                make.height.equalTo(Ad.default.adaptiveBannerHeight)
            }
            myWebView.snp.remakeConstraints{ make in
                make.width.equalTo(fullScreenSize.width)
//                make.height.equalTo(fullScreenSize.height - 49 - 44  - 4 - CGFloat(bannerInset))
                make.centerX.equalToSuperview()
                make.top.equalTo(safeAreaTop).offset(Float(bannerInset + 4))
                make.bottom.equalTo(bottomBackgroundLabel.snp.top).offset(0)
            }
        }
    }
    
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
        self.view.addSubview(myWebView)
        self.view.addSubview(networkErrorImageView)
        self.view.addSubview(networkErrorHint)
        self.view.sendSubviewToBack(networkErrorImageView)
        self.view.bringSubviewToFront(myWebView)
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
        
        self.view.addSubview(hintAlert)
        hintAlert.isHidden = true
        
        self.go()
    }
    
    func setupConstrains(){
        
        myWebView.snp.makeConstraints{(make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(bottomBackgroundLabel.snp.top).offset(0)
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
            make.centerX.equalToSuperview()
        }
        
        bottomBackgroundLabel.snp.makeConstraints{(make) in
            make.height.equalTo(49)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(safeAreaBottom).offset(0)
        }
        
        bottomLeftbutton.snp.makeConstraints{(make) in
            make.left.equalTo(bottomBackgroundLabel.snp.left).offset(52)
            make.top.equalTo(bottomBackgroundLabel.snp.top).offset(12)
        }
        
        bottomRightbutton.snp.makeConstraints{(make) in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(124)
        }
        
        bottomIndexbutton.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-54)
        }
        
        hintAlert.snp.makeConstraints{
            make in
            make.left.equalToSuperview().offset(Float(fullScreenSize.width) / 2 - GetWidthHeight.share.getWidth(width: 60))
            make.top.equalTo(safeTop).offset(GetWidthHeight.share.getHeight(height: 270))
        }
    }
}
