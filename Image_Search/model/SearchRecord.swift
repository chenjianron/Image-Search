//
//  SearchRecord.swift
//  Image_Search
//
//  Created by GC on 2021/8/16.
//

import SQLite3
import UIKit

class SearchRecord {
    var id:Int?
    var image:Data?
    var keyword:String?
    var date:String
    init(id:Int, image:Data, keyword:String, date:String) {
        self.id = id
        self.image = image
        self.keyword = keyword
        self.date = date
    }
}
