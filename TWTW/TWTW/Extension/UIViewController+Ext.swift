//
//  UIViewController+Ext.swift
//  TWTW
//
//  Created by 박다미 on 2023/09/18.
//

import Foundation
import SwiftUI

#if DEBUG
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }
    
    func toPreview() -> some View {
        Preview(viewController: self)
    }
    
}
#endif

extension UIViewController {
    typealias AlertOKCallback = (UIAlertAction) -> Void

    func showErrorAlert(message: String, completion handler: AlertOKCallback? = nil) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))

        present(alertVC, animated: true)
    }
}
