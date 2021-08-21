//
//  CollectionViewCell.swift
//  Image_Search
//
//  Created by GC on 2021/8/15.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    let fullScreenSize = UIScreen.main.bounds.size
    
    lazy var imageView:UIImageView = {
        let imageView = UIImageView()
//        imageView.image = UIImage(named: "search_icon.png")
        return imageView
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
        
        imageView.snp.makeConstraints{ (make) in
            make.width.equalTo(fullScreenSize.width / 2)
            make.height.equalTo(fullScreenSize.width / 2)
//            make.left.equalToSuperview()
//            make.top.equalToSuperview()
        }
        
    }
}
