//
//  topButtonView.swift
//  Image_Search
//
//  Created by GC on 2021/8/6.
//

import UIKit

class TopButtonView :UIView {
    
    lazy var backgroundLabel: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "top_rectangle.png")
        return imageView
    }()
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "triangle.png")
        return imageView
    }()
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica", size: 14)
        label.textAlignment = .center
        label.backgroundColor = UIColor(red: 251/255, green: 251/255, blue: 251/255, alpha: 1)
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    func setText(title:String) {
        textLabel.text = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        addSubview(backgroundLabel)
        backgroundLabel.snp.makeConstraints{ (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        backgroundLabel.addSubview(imageView)
        backgroundLabel.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(20)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(13)
        }
    }
}

