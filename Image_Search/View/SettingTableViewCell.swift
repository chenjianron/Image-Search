//
//  settingTableViewCell.swift
//  Image_Search
//
//  Created by GC on 2021/8/4.
//


import UIKit

class SettingTableViewCell: UITableViewCell {
    
    lazy var titleLabel:UILabel = {
        let label = UILabel.init()
        label.font = UIFont(name: "Helvetica", size: 15)
        return label
    }()
    lazy var cellBack: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cell_arrow.png")
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layoutUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func layoutUI() {
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(cellBack)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(contentView).offset(16)
        }
        
        cellBack.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
        }

    }

    func addTitleString(title:String){
        self.titleLabel.text = title
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

