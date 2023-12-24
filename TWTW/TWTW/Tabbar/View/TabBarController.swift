//
//  TabBarController.swift
//  TWTW
//
//  Created by 정호진 on 12/24/23.
//

import Foundation
import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showAlertPage(_:)),
                                               name: NSNotification.Name("showPage"), object: nil)
    }
    
    /// 알림 페이지로 넘어가는 함수
    @objc
    private func showAlertPage(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let index = userInfo["index"] as? Int {
                switch index {
                case TabBarItemType.home.toInt():
                    selectedIndex = TabBarItemType.home.toInt()
                    NotificationCenter.default.post(name: Notification.Name("moveMain"), object: nil)
                case TabBarItemType.notification.toInt():
                    selectedIndex = TabBarItemType.notification.toInt()
                default:
                    print("wrong")
                }
            }
        }
    }
}
