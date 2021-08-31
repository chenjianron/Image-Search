//
//  IsolatedInteraction.swift
//  Image_Search
//
//  Created by GC on 2021/8/26.
//

class IsolatedInteraction {
    
    static let shared = IsolatedInteraction()
    
    func showAnimate(vc:UIViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            UIView.animate(withDuration: 0.3) {
//                self.view.backgroundColor = UIColor.init(hex: 0x000000, alpha: 0.3)
                let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
                alertController.modalPresentationStyle = .fullScreen
                alertController.view.isHidden = true
                vc.present(alertController, animated: false, completion: nil)
            }
        }
    }
    
    func dismissAnimate(vc:UIViewController,complete: @escaping () -> Void) {
        vc.dismiss(animated: false, completion: complete)
    }
}
