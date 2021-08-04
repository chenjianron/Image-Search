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
    let titles = [["意见反馈"],["分享给好友", "给个评价","隐私政策", "用户协议"]]
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        print("viewWillDisappear")
       
    }
    
//    override func awakeFromNib() {
//        print("awakeFromNib")
//    }
//
//    override func loadView() {
//        super.loadView()
//        print("loadView")
//    }
//
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
//
//    override func viewWillLayoutSubviews() {
//        print("viewWillLayoutSubviews")
//    }
////
//    override func viewDidAppear(_ animated: Bool) {
//
//    }
//    override func viewDidDisappear(_ animated: Bool) {
//
//    }
//
//    override func didReceiveMemoryWarning() {
//        print("didReceiveMemoryWarning")
//    }
}

//MARK: -
extension SettingViewController{
    @objc func backToPrevious(){
        self.navigationController!.popViewController(animated: true)
    }
    
    func setDelegate(delegate:MainViewController){
        self.delegate = delegate
    }
    
    func setTextView(text:String){
      
    }
}

//MARK: - UI
extension SettingViewController {
    func setUpUI(){
//        navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        view.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = leftBarBtn
        self.navigationItem.title = "设置"
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
                break
            case 1:
                // Statistics.event(.setting_tap, label: "隐私政策")
//                sendEMail()
                break
            case 2:
//                Statistics.event(.setting_tap, label: "分享给好友")
                break
            case 3:
//                Statistics.event(.setting_tap, label: "评价")
                break
            case 4:
//                Statistics.event(.setting_tap, label: "隐私政策")
                break
            case 5:
//                Statistics.event(.setting_tap, label: "用户协议")
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
//        headerView.snp.makeConstraints{ make in
//            make.top.equalToSuperview().offset(10)
//        }
        if section == 0 {
            label.text = "帮助与反馈"
        } else {
            label.text = "关于我们"
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
        let title = section == 0 ? "帮助与反馈" : "关于我们"
        return title
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
//    func tableView(_ tableView: UITableView,viewForFooterInSection section:Int) -> UIView? {
//        return UIView()
//    }
    
//    func tableView(_ tableView:UITableView,heightForFooterInSection section :Int)-> CGFloat {
//        return 18
//    }
}


