//
//  SearchRecordViewController.swift
//  Image_Search
//
//  Created by GC on 2021/8/15.
//

import UIKit
import SQLite3
import Alamofire
import Photos

class  SearchRecordViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    let fullScreenSize = UIScreen.main.bounds.size
    let dformatter = DateFormatter()
    
    var resourceData = [SearchRecord]()
    var collectionView:UICollectionView!
    var loadingView: UIView!
    
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
    lazy var leftBarBtn:UIBarButtonItem = {
        let leftBarBtn = UIBarButtonItem(image: UIImage(named: "back.png")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backToPrevious))
        return leftBarBtn
    }()
    lazy var rightButton: UIBarButtonItem = {
        // 導覽列左邊按鈕
        let rightButton = UIBarButtonItem(
            title:__("清空"),
            style:.plain ,
            target:self ,
            action: #selector(SearchRecordViewController.deleteAlert))
        rightButton.tintColor = UIColor.red
        return rightButton
    }()
    lazy var layout : UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        return layout
    }()
    lazy var emptySearchRecordImageView: UIImageView = {
        let searchImageView = UIImageView()
        searchImageView.image = UIImage(named: "empty_image.png")
        return searchImageView
    }()
    lazy var emptySearchRecordHint: UILabel = {
        let searchImageView = UILabel()
        searchImageView.text = __("暂无搜索记录")
        return searchImageView
    }()
    lazy var hintAlert:AlertView = {
        let alert = AlertView()
        return alert
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupResourceData()
        setupUI()
        setupConstraints()
        setupAdBannerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        collectionView.reloadData()
        Statistics.beginLogPageView("搜索记录页")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Statistics.endLogPageView("搜索记录页")
    }
    
    
}

// MARK: -
extension SearchRecordViewController {
    
    func showNetworkErrorAlert(_ container: UIViewController){
        
        let alertController = UIAlertController(title: nil,message: __("网络超时，请重试"),preferredStyle: .alert)
        container.present(alertController,animated: true,completion: nil)
        
        self.loadingView.isHidden = true
        
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (ktimer) in
            container.dismiss(animated: true, completion: nil)
        }
    }
    
    func showActivityIndicatory(uiView: UICollectionView) {
        //     var container: UIView = UIView()
        //     container.frame = uiView.frame
        //     container.center = uiView.center
        //        container.backgroundColor = UIColor(hex: 0xffffff, alpha: 0.3)
        loadingView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = CGPoint(x: uiView.center.x, y: view.center.x + uiView.contentOffset.y)
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
        loadingView.isHidden = false
        uiView.addSubview(loadingView)
        actInd.startAnimating()
    }
    
    @objc func disappear(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func setAlert(title:String,image:String){
        hintAlert.dataSouce(title: __("\(title)"), image: image)
        hintAlert.isHidden = false
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (ktimer) in
            self.hintAlert.isHidden = true
        }
    }
    
    private func saveImage(image: UIImage) {
        let ctx = Ad.default.interstitialSignal(key: K.ParamName.SaveImageInterstitial)
        ctx.didEndAction = { [self] _ in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { [weak self](isSuccess, error) in
                DispatchQueue.main.async { [self] in
                    if isSuccess {// 成功
                        self!.setAlert(title: "已保存到相册", image: "ok_icon")
                        
                    } else {
                        self!.setAlert(title: "保存失败", image: "fail_icon")
                    }
                }
            })
        }
    }
    
    func searchKeyword(row:Int){
        // 建立一個提示框
        let alertController = UIAlertController(title: __("编辑"), message: nil,preferredStyle: .actionSheet)
        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(title: __("取消"),style: .cancel,handler: nil)
        alertController.addAction(cancelAction)
        let searchKeywordAction = UIAlertAction(title: __("搜索关键字"),style: .default,
            handler: {_ in
                let ctx = Ad.default.interstitialSignal(key: K.ParamName.SearchImageInterstitial)
                ctx.didEndAction = { [self] _ in
                    Statistics.event(.SearchRecordTap, label: "搜索关键字")
                    self.dismiss(animated: true, completion: nil)
                    let webViewController = WebViewController()
                    webViewController.delegate = self
                    webViewController.setKeyword(keyword: self.resourceData[row].keyword!)
                    self.navigationController!.pushViewController(webViewController,animated: false)
                    SQL.delete(id: self.resourceData[row].id!)
                    SQL.insert(keyword: self.resourceData[row].keyword!)
                    self.resourceData = []
                    SQL.find(resourceData: &self.resourceData)
                    self.collectionView.reloadData()

                }
                //                if self.resourceData.count == 0 {
                //                    self.emptySearchRecordImageView.isHidden = false
                //                    self.emptySearchRecordHint.isHidden = false
                //                    self.collectionView.isHidden = true
                //                    self.leftBarBtn.isEnabled = false
                //                }
            })
        alertController.addAction(searchKeywordAction)
        let deleteAction = UIAlertAction(title: __("删除"),style: .destructive,
            handler: { [self]_ in
                let ctx = Ad.default.interstitialSignal(key: K.ParamName.DeleteImageInterstitial)
                ctx.didEndAction = { [self] _ in
                    SQL.delete(id: self.resourceData[row].id!)
                    resourceData = []
                    SQL.find(resourceData: &self.resourceData)
                    self.collectionView.reloadData()
                    if resourceData.count == 0 {
                        emptySearchRecordImageView.isHidden = false
                        emptySearchRecordHint.isHidden = false
                        collectionView.isHidden = true
                        rightButton.isEnabled = false
                    }
                }
        })
        alertController.addAction(deleteAction)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(
            alertController,
            animated: true,
            completion: nil)
    }
    
    func selectImage(row:Int){
        // 建立一個提示框
        let alertController = UIAlertController(title: __("编辑"), message: nil,preferredStyle: .actionSheet)
        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(title: __("取消"),style: .cancel,handler: nil)
        alertController.addAction(cancelAction)
        // 建立[確認]按鈕
        let searchImageBtn = UIAlertAction(title: __("搜索图片"),style: .default,
            handler: {_ in
                Statistics.event(.SearchRecordTap, label: "搜索图片")
                let ctx = Ad.default.interstitialSignal(key: K.ParamName.SearchImageInterstitial)
                ctx.didEndAction = { [self] _ in
                    let headers: HTTPHeaders =  [
                        "Content-type": "text/html; charset=GBK"
                    ]
                    self.dismiss(animated: true, completion: nil)
                    self.showActivityIndicatory(uiView: self.collectionView)
                    IsolatedInteraction.shared.showAnimate(vc: self)
                    AF.upload(multipartFormData: { (multipartFormData) in
                        multipartFormData.append( self.resourceData[row].image!, withName: "source", fileName: "YourImageName"+".jpeg", mimeType: "image/png")
                    }, to: "http://pic.sogou.com/pic/upload_pic.jsp?", method: .post, headers: headers).responseString { [self] (result) in
                        if let lastUrl = result.value{
                            SQL.delete(id: resourceData[row].id!)
                            SQL.insert(imagedata: self.resourceData[row].image!)
                            self.resourceData = []
                            SQL.find(resourceData: &self.resourceData)
                            collectionView.reloadData()
                            self.loadingView.isHidden = true
                            if self.resourceData.count == 0 {
                                self.emptySearchRecordImageView.isHidden = false
                                self.emptySearchRecordHint.isHidden = false
                                self.collectionView.isHidden = true
                            }
                            loadingView.isHidden = true
                            IsolatedInteraction.shared.dismissAnimate(vc: self, complete: {
                                let webViewController = WebViewController()
                                webViewController.delegate = self
                                webViewController.setURL(url: lastUrl)
                                self.navigationController!.pushViewController(webViewController,animated: false)
                            })
                        } else {
                            print("图片上传转链接失败")
                            print(result.error?.errorDescription ?? "")
                            if result.error?.errorDescription == "URLSessionTask failed with error: \(__("似乎已断开与互联网的连接。"))" {
                                showNetworkErrorAlert(self)
                            }
                        }
                    }
                }
                
            })
        alertController.addAction(searchImageBtn)
        let saveImageBtn = UIAlertAction(title: __("保存到相册"),style: .default,handler: {_ in
                // UIImageWriteToSavedPhotosAlbum(UIImage(data: self.resourceData[row].image!)! ,self,nil, nil)
            Statistics.event(.SearchRecordTap, label: "保存到相册")
            let ctx = Ad.default.interstitialSignal(key: K.ParamName.SaveImageInterstitial)
            ctx.didEndAction = { [self] _ in
                    switch PHPhotoLibrary.authorizationStatus(){
                    case .authorized:
                        self.saveImage(image: UIImage(data:self.resourceData[row].image!)!)
                    case .notDetermined:
                        PHPhotoLibrary.requestAuthorization { [weak self](status) in
                            if status == .authorized {
                                self?.saveImage(image: UIImage(data:self!.resourceData[row].image!)!)
                            } else {
                                print("User denied")
                            }
                        }
                    case .restricted, .denied:
                        if let url = URL.init(string: UIApplication.openSettingsURLString) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.openURL(url)
                            }
                        }
                    case .limited:
                        break
                    @unknown default:
                        break
                    }
            }
        })
        alertController.addAction(saveImageBtn)
        
        let deleteAction = UIAlertAction(title: __("删除"),style: .destructive,
            handler: { [self]_ in
                Statistics.event(.SearchRecordTap, label: "删除")
                let ctx = Ad.default.interstitialSignal(key: K.ParamName.DeleteImageInterstitial)
                ctx.didEndAction = { [self] _ in
                    SQL.delete(id: self.resourceData[row].id!)
                    self.resourceData = []
                    SQL.find(resourceData: &self.resourceData)
                    self.collectionView.reloadData()
                    if self.resourceData.count == 0 {
                        self.emptySearchRecordImageView.isHidden = false
                        self.emptySearchRecordHint.isHidden = false
                        self.collectionView.isHidden = true
                        self.rightButton.isEnabled = false
                    }
                }
            })
        alertController.addAction(deleteAction)
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
    
    @objc func backToPrevious(){
        Statistics.event(.SearchRecordTap, label: "返回")
        self.navigationController!.popViewController(animated: true)
    }
    
    @objc func deleteAlert(){
        
        let alertController = UIAlertController()
        let cancelAction = UIAlertAction(title: __("取消"),style: .cancel,handler: nil)
        alertController.addAction(cancelAction)
        let deleteAction = UIAlertAction(title: __("清空"),style: .destructive,
            handler: {_ in
                Statistics.event(.SearchEngineTap, label: "清空")
                if SQL.deleteAll() {
                    self.resourceData = []
                    self.collectionView.reloadData()
                    self.emptySearchRecordImageView.isHidden = false
                    self.emptySearchRecordHint.isHidden = false
                    self.collectionView.isHidden = true
                    self.rightButton.isEnabled = false
                }
            })
        alertController.addAction(deleteAction)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(alertController,animated: true,completion: nil)
        // 建立[確認]按鈕
    }
}

extension SearchRecordViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resourceData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if resourceData[indexPath.row].keyword == "" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
            cell.imageView.image = UIImage(data:resourceData[indexPath.row].image!)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "keywordCell", for: indexPath) as! KeywordCollectionViewCell
            cell.label.text = resourceData[indexPath.row].keyword
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if resourceData[indexPath.row].keyword == "" {
            selectImage(row: indexPath.row)
        } else {
            searchKeyword(row: indexPath.row)
        }
        
    }
}


// MARK: -UI
extension SearchRecordViewController {
    
    func setupAdBannerView() {
        
        if let bannerView = self.bannerView {
            view.addSubview(bannerView)
            bannerView.snp.makeConstraints { make in
                make.top.equalTo(safeAreaTop)
                make.left.right.equalToSuperview()
                make.height.equalTo(Ad.default.adaptiveBannerHeight)
            }
            collectionView.snp.remakeConstraints{make in
                make.centerX.equalToSuperview()
                make.width.equalTo(fullScreenSize.width)
                make.height.equalTo(fullScreenSize.height - 44 - CGFloat(bannerInset))
                make.top.equalTo(safeAreaTop).offset(Float(bannerInset))
            }
            
        }
    }
    
    func setupUI(){
        
        self.view.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = leftBarBtn
        self.navigationItem.title = __("搜索记录")
        self.navigationItem.rightBarButtonItem = rightButton
        //        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        layout.sectionInset = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.itemSize = CGSize(width: (fullScreenSize.width - 1) / 2 , height: (fullScreenSize.width - 1) / 2 )
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0,width: fullScreenSize.width, height: fullScreenSize.height - 20),collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(KeywordCollectionViewCell.self, forCellWithReuseIdentifier: "keywordCell")
        //        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,withReuseIdentifier: "Header")
        //        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,withReuseIdentifier: "Footer")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.view.addSubview(collectionView)
        self.view.addSubview(self.emptySearchRecordImageView)
        self.view.addSubview(self.emptySearchRecordHint)
        self.emptySearchRecordImageView.isHidden = true
        self.emptySearchRecordHint.isHidden = true
        self.view.addSubview(hintAlert)
        hintAlert.isHidden = true
        if resourceData.count == 0 {
            self.emptySearchRecordImageView.isHidden = false
            self.emptySearchRecordHint.isHidden = false
            self.collectionView.isHidden = true
            self.rightButton.isEnabled = false
        }
    }
    
    func setupConstraints(){
    
        collectionView.snp.makeConstraints{ (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(fullScreenSize.width)
            make.height.equalToSuperview().multipliedBy(1)
        }
        emptySearchRecordImageView.snp.makeConstraints{
            (make) in
            make.top.equalTo(safeAreaTop).offset(142)
//            make.left.equalToSuperview().offset(46)
            make.centerX.equalToSuperview()
        }
        emptySearchRecordHint.snp.makeConstraints{
            (make) in
            make.top.equalTo(safeAreaTop).offset(372)
//            make.left.equalToSuperview().offset(132)
            make.centerX.equalToSuperview()
        }
        hintAlert.snp.makeConstraints{
            make in
            make.left.equalToSuperview().offset(Float(fullScreenSize.width) / 2 - GetWidthHeight.share.getWidth(width: 60))
            make.top.equalTo(safeTop).offset(GetWidthHeight.share.getHeight(height: 270))
        }
    }
    
    func setupResourceData(){
        resourceData = []
        SQL.find(resourceData: &resourceData)
    }
}
