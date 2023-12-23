//
//  TabBarController.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/10.
//

import Foundation
import UIKit

final class TabBarController: UITabBarController {
    var tabCoordinators: [TabBar] = []
    var navigationControllers: UINavigationController
    
    init(navigationControllers: UINavigationController) {
        self.navigationControllers = navigationControllers
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setUI()
//        setupTabs()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showAlertPage(_:)),
                                               name: NSNotification.Name("showPage"), object: nil)
    }
    
//    /// 탭바 UI 속성
//    private func setUI() {
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = .white
//
//        tabBar.standardAppearance = appearance
//        tabBar.scrollEdgeAppearance = appearance
//
//        tabBar.tintColor = .black // 선택된 아이템
//        tabBar.unselectedItemTintColor = UIColor.gray // 선택하지 않은 아이템
//    }

    /// setupTabs
//    private func setupTabs() {
//        tabCoordinators = [
//            TabBar(title: "홈", icon: UIImage(systemName: "house"),
//                   coordinator: DefaultGroupCoordinator(navigationController: navigationControllers)),
//            TabBar(title: "친구목록", icon: UIImage(systemName: "person.2"),
//                   coordinator: DefaultFriendsListCoordinator(navigationController: navigationControllers)),
//            TabBar(title: "알림", icon: UIImage(systemName: "bell"),
//                   coordinator: DefaultNotificationCoordinator(navigationController: navigationControllers)),
//            TabBar(title: "마이페이지", icon: UIImage(systemName: "person"),
//                   coordinator: DefaultMyPageCoordinator(navigationController: navigationControllers))
//        ]
        
//        viewControllers = tabCoordinators.map { coordinator -> UIViewController in
//            coordinator.coordinator.start()
//            let tabBarItem = UITabBarItem(title: coordinator.title, image: coordinator.icon, selectedImage: nil)
//            
//            coordinator.coordinator.navigationController.tabBarItem = tabBarItem
//            return coordinator.coordinator.navigationController
//        }
//    }
    
    /// 알림 페이지로 넘어가는 함수
    @objc
    private func showAlertPage(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let index = userInfo["index"] as? Int {
                self.selectedIndex = index
            }
        }
    }
}
