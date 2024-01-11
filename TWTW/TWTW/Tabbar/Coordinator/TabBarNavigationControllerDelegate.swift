//
//  TabBarNavigationControllerDelegate.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/10.
//

import Foundation
import UIKit

final class TabBarNavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // 메인 탭 화면 중 하나이면 탭 바 표시, 그 외에는 숨김
        if viewController is GroupViewController ||
            viewController is FriendsListViewController ||
            viewController is MyPageViewController {
            navigationController.tabBarController?.tabBar.isHidden = false
        } else {
            navigationController.tabBarController?.tabBar.isHidden = true
        }
    }
}
