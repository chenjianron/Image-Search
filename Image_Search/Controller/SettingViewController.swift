//
//  SettingViewController.swift
//  Image_Search
//
//  Created by GC on 2021/8/3.
//

import UIKit
import SnapKit
import Toolkit
import SafariServices
import MessageUI

class SettingViewController: UIViewController {
    
    let fullScreenSize = UIScreen.main.bounds.size
    let titles = [[__("意见反馈")],[__("分享给好友"), __("给个评价"),__("隐私政策"), __("用户协议")]]
    
    var bannerView: UIView? {
        return Marketing.shared.bannerView(.settingBanner, rootViewController: self)
    }
    var bannerInset: CGFloat {
        if bannerView != nil {
            return Ad.default.adaptiveBannerHeight
        } else {
            return 0
        }
    }
    var delegate:MainViewController?
    
    lazy var leftBarBtn:UIBarButtonItem = {
        let leftBarBtn = UIBarButtonItem(image: UIImage(named: "back.png")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backToPrevious))
        return leftBarBtn
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x:0,y:21,width: fullScreenSize.width,height: fullScreenSize.height-200-(UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!),style:.plain)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        //        tableView.tableHeaderView = UIView()
        //        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(SettingTableViewCell.classForCoder(), forCellReuseIdentifier: "SettingTableViewCell")
        return tableView
    }()
    lazy var appsView: UIView = SettingsFeaturedApps.createAppsView(width: self.view.width)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setupConstrains()
        setupAdBannerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        Statistics.beginLogPageView("设置页")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Pro.shared.addLongPressGesture(to: tableView.cellForRow(at: IndexPath(row: 0, section: 0)))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Statistics.endLogPageView("设置页")
    }
    
}

//MARK: -
extension SettingViewController{
    
    func getLanguageType() -> String {
        let def = UserDefaults.standard
        let allLanguages: [String] = def.object(forKey: "AppleLanguages") as! [String]
        let chooseLanguage = allLanguages.first
        return chooseLanguage ?? "en"
    }
    
    func sendEMail () {
        if MFMailComposeViewController.canSendMail() {
            FeedbackMailMaker.shared.presentMailComposeViewController(from: self, recipient: K.Share.Email)
        } else {
            let alert = UIAlertController(title: __("未设置邮箱账户"), message: __("要发送电子邮件，请设置电子邮件账户"), preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: __("确认"), style: .default, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func backToPrevious(){
        Statistics.event(.SettingsTap, label: "返回")
        self.navigationController!.popViewController(animated: true)
    }
    
    func setDelegate(delegate:MainViewController){
        self.delegate = delegate
    }
}

//MARK: - UI
extension SettingViewController {
    
    func setupAdBannerView() {
        if let bannerView = self.bannerView {
            view.addSubview(bannerView)
            bannerView.snp.makeConstraints { make in
                make.bottom.equalTo(safeAreaBottom)
                make.left.right.equalToSuperview()
                make.height.equalTo(Ad.default.adaptiveBannerHeight)
            }
        }
    }
    
    func setUpUI(){
        //        navigationController?.navigationBar.barStyle = .black
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBarBtn
        self.navigationItem.title = __("设置")
        self.view.addSubview(tableView)
    }
    
    func setupConstrains(){
        
    }
}

//MARK: - TableView
extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            Statistics.event(.SettingsTap, label: "意见反馈")
            sendEMail()
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                Statistics.event(.SettingsTap, label: "分享给好友")
                let content = K.Share.normalContent.toURL()
                let activityVC = UIActivityViewController(activityItems: [content as Any], applicationActivities: nil)
                if UIDevice.current.userInterfaceIdiom == .pad {
                    if let popVC = activityVC.popoverPresentationController {
                        if let cell = self.tableView.cellForRow(at: indexPath) as? SettingTableViewCell {
                            popVC.sourceView = cell.titleLabel
                        }
                    }
                }
                activityVC.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
                    if completed {
                        Marketing.shared.didShareRT()
                    }
                }
                present(activityVC, animated: true, completion: nil)
            case 1:
                 Statistics.event(.SettingsTap, label: "给个评价")
                let urlString = "itms-apps://itunes.apple.com/app/id\(K.IDs.AppID)?action=write-review"
                if let url = URL(string: urlString) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:],
                                                  completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            case 2:
                 Statistics.event(.SettingsTap, label: "隐私政策")
                 guard let url = Util.webURL(urlStr: K.Website.PrivacyPolicy) else { return }
                 let vc = SFSafariViewController(url: url)
                vc.modalPresentationStyle = .fullScreen
                 self.present(vc, animated: true, completion: nil)
            case 3:
                 Statistics.event(.SettingsTap, label: "用户协议")
                 guard let url = Util.webURL(urlStr: K.Website.UserAgreement) else { return }
                 let vc = SFSafariViewController(url: url)
                 self.present(vc, animated: true, completion: nil)
            default:
                break
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles[section].count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        let label = UILabel()
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 12)
        headerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        if section == 0 {
            label.text = __("帮助与反馈")
        } else {
            label.text = __("关于我们")
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        if indexPath.row == 0 {
        //            let cell:SwitchCell = tableView.dequeueReusableCell(withIdentifier: switchCellIdentifier, for: indexPath) as! SwitchCell
        //            cell.addTitleString(title: titles[indexPath.row], image: images[indexPath.row])
        //            return cell
        //        }
        let cell:SettingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
        cell.addTitleString(title: titles[indexPath.section][indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        let title = section == 0 ? __("帮助与反馈") : __("关于我们")
        return title
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
}

extension Util {
    static func webURL(urlStr: String) -> URL? {
        if var urlComponents = URLComponents(string: urlStr) {
            var queryItems = [URLQueryItem]()
            queryItems.append(URLQueryItem(name: "lang", value: Util.languageCode()))
            queryItems.append(URLQueryItem(name: "version", value: Util.appVersion()))
            urlComponents.queryItems = queryItems
            if let url = urlComponents.url {
                return url
            }
        }
        return nil
    }
}
