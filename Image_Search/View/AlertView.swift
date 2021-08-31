//
//  AlertView.swift
//  Image_Search
//
//  Created by GC on 2021/8/19.
//

import UIKit

class AlertView: UIView{
    
    lazy var backgroundLabel: UIView = {
        let loadingView = UIView()
        loadingView.backgroundColor = UIColor(hex: 0x383838, alpha: 0.8)
        loadingView.layer.cornerRadius = 10
        loadingView.clipsToBounds = true
        return loadingView
    }()
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func dataSouce(title:String, image:String) {
        imageView.image = UIImage(named: image)
        textLabel.text = __(title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        addSubview(backgroundLabel)
        backgroundLabel.snp.makeConstraints{ (make) in
            make.width.equalTo(130)
            make.height.equalTo(97)
        }
        backgroundLabel.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.width.equalTo(32)
            make.height.equalTo(32)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(17)
        }
        backgroundLabel.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-18)
        }
    }
}


