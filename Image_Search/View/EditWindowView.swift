//
//  EditWindow.swift
//  Image_Search
//
//  Created by GC on 2021/8/11.
//

import UIKit

class EditWindowView:UIView {
    
    let fullScreenSize = UIScreen.main.bounds.size
    var delegate:MainViewController!
    var type:String!
    
    lazy var backgroundBoard:UIView = {
        let view = UIView()
        view.layer.cornerRadius = fullScreenSize.width / 30
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
        return button
    }()
    lazy var titleLable:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica", size: 17)
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
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.backgroundColor = UIColor.white
        return textField
    }()
    lazy var searchBtn:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "searchButtonImage"), for: .normal)
                
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setType(type:String){
        self.type = type
        if self.type == "url" {
            titleLable.text = __("输入图片URL")
        }
    }
    
    func setDelegate(delegate:MainViewController){
        self.delegate = delegate
    }
    
    func setupUI() {
        
        addSubview(backgroundBoard)
        backgroundBoard.snp.makeConstraints{ (make) in
            make.width.equalTo(335)
            make.height.equalTo(204)
            make.top.equalToSuperview().offset(114)
            make.left.equalToSuperview().offset(20)
        }
        
        backgroundBoard.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints{ (make) in
            make.width.equalTo(24)
            make.height.equalTo(24)
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(291)
        }
        
        backgroundBoard.addSubview(titleLable)
        titleLable.snp.makeConstraints{ (make) in
            make.width.equalTo(103)
            make.height.equalTo(24)
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(116)
            
        }
        
        backgroundBoard.addSubview(hintTitle)
        hintTitle.snp.makeConstraints{ (make) in
            make.width.equalTo(125)
            make.height.equalTo(20)
            make.top.equalToSuperview().offset(52)
            make.left.equalToSuperview().offset(105)
        }
        
        backgroundBoard.addSubview(inputTextField)
        inputTextField.snp.makeConstraints{ (make) in
            make.width.equalTo(295)
            make.height.equalTo(38)
            make.top.equalToSuperview().offset(76)
            make.left.equalToSuperview().offset(20)
        }
        
        backgroundBoard.addSubview(searchBtn)
        searchBtn.snp.makeConstraints{ (make) in
            make.width.equalTo(152)
            make.height.equalTo(38)
            make.top.equalToSuperview().offset(138)
            make.left.equalToSuperview().offset(92)
            
        }
    }
    
}
