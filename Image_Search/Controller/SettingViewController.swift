//
//  SettingViewController.swift
//  Image_Search
//
//  Created by GC on 2021/8/3.
//

import UIKit
import SnapKit

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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Statistics.endLogPageView("设置页")
    }
    
}

//MARK: -
extension SettingViewController{
    
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
        switch indexPath.row {
        case 0:
            Statistics.event(.SettingsTap, label: "意见反馈")
            break
        case 1:
             Statistics.event(.SettingsTap, label: "分享给好友")
            // sendEMail()
            break
        case 2:
             Statistics.event(.SettingsTap, label: "给个评价")
            break
        case 3:
             Statistics.event(.SettingsTap, label: "隐私政策")
            break
        case 4:
             Statistics.event(.SettingsTap, label: "用户协议")
            break
        default:
            ()
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
