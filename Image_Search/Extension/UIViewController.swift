//
//  UIViewController.swift
//  ZIP
//
//  Created by  HavinZhu on 2021/2/22.
//

import SnapKit
import Toolkit
import UIKit

extension UIViewController {

    var safeTop: CGFloat {
        get {
            if #available(iOS 11.0, *) {
                return view.safeAreaLayoutGuide.layoutFrame.minY
            } else {
                return topLayoutGuide.length
            }
        }
    }
    
    var safeBottom: CGFloat {
        get {
            if #available(iOS 11.0, *) {
                return view.height - safeTop - view.safeAreaLayoutGuide.layoutFrame.height
            } else {
                return bottomLayoutGuide.length
            }
        }
    }
    
    var safeAreaTop: ConstraintItem {
        get {
            if #available(iOS 11.0, *) {
                return self.view.safeAreaLayoutGuide.snp.top
            } else {
                return self.topLayoutGuide.snp.top
            }
        }
    }
    
    var safeAreaBottom: ConstraintItem {
        get {
            if #available(iOS 11.0, *) {
                return self.view.safeAreaLayoutGuide.snp.bottom
            } else {
                return self.bottomLayoutGuide.snp.bottom
            }
        }
    }
    
    var safeAreaHeight: CGFloat {
        get {
            return self.view.height - safeTop - safeBottom
        }
    }
    
}
