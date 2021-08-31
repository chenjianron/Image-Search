//
//  KeywordCollectionViewCell.swift
//  Image_Search
//
//  Created by GC on 2021/8/17.
//

import UIKit

class KeywordCollectionViewCell: UICollectionViewCell {
    
    lazy var imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "keyword_background.jpg")
        return imageView
    }()
    lazy var label:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        
        self.addSubview(imageView)
        imageView.addSubview(label)
        
        imageView.snp.makeConstraints{ (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        label.snp.makeConstraints{ (make) in
            make.width.equalTo(GetWidthHeight.share.getWidth(width: 85))
            make.height.equalTo(GetWidthHeight.share.getHeight(height: 60))
            make.top.equalToSuperview().offset(GetWidthHeight.share.getWidth(width: 68))
            make.left.equalToSuperview().offset(GetWidthHeight.share.getWidth(width: 51))
        }
    }
}

