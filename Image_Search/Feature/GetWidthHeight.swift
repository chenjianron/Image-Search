//
//  GetWidthHeight.swift
//  Image_Search
//
//  Created by GC on 2021/8/18.
//

import Foundation
import UIKit

class GetWidthHeight {
    
    static let share = GetWidthHeight()
    
    let fullScreenSize = UIScreen.main.bounds.size
    let IPhone11ProWidth = 375
    let IPhone11ProHeigth = 812
    
    func getWidth(width:Float) -> Float{
        return Float(fullScreenSize.width) * (width / Float(IPhone11ProWidth))
    }
    
    func getHeight(height:Float) -> Float {
        return Float(fullScreenSize.height) * ( height / Float(IPhone11ProHeigth))
    }
}
