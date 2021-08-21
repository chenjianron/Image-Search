//
//  GetWidthHeight.swift
//  Image_Search
//
//  Created by GC on 2021/8/18.
//

import Foundation
import UIKit

class GetWidthHeight {
    
    static let fullScreenSize = UIScreen.main.bounds.size
    static let IPhone11ProWidth = 375
    static let IPhone11ProHeigth = 812 
    
    static func getWidth(width:Float) -> Float{
        return Float(fullScreenSize.width) * (width / Float(IPhone11ProWidth))
    }
    
    static func getHeight(height:Float) -> Float {
        return Float(fullScreenSize.height) * ( height / Float(IPhone11ProHeigth))
    }
}
