//
//  ButtonView.swift
//  Image_Search
//
//  Created by GC on 2021/8/22.
//

import UIKit

class ButtonView :UIView {
    
    lazy var backgroundLabel: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(hex: 0xFFFFFF, alpha: 0.9)
        view.layer.cornerRadius = 13
        view.layer.masksToBounds = false
        if #available(iOS 13.0, *) {
            view.layer.shadowColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
            // Fallback on earlier versions
        }
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 3
        return view
    }()
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica", size: 14)
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dataSouce(title:String, image:String){
        imageView.image = UIImage(named: image)
        textLabel.text = title
    }

    func setupUI() {
        addSubview(backgroundLabel)
        backgroundLabel.snp.makeConstraints{ (make) in
            make.width.equalTo(136)
            make.height.equalTo(92)
        }
        backgroundLabel.addSubview(imageView)
        backgroundLabel.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(56)
            make.height.equalTo(20)
        }
        imageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
    }
}


