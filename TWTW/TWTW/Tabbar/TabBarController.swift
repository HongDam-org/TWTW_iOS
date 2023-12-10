//
//  TabBarController.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/10.
//

import Foundation
import UIKit

final class TabBarController: UITabBarController {
    var tabCoordinators: [TabCoordinator] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {

        tabCoordinators = [
            TabCoordinator(title: "홈", icon: UIImage(systemName: "house"),
                           coordinator: DefaultGroupCoordinator(navigationController: UINavigationController())),
            TabCoordinator(title: "친구목록", icon: UIImage(systemName: "person.2"),
                           coordinator: DefaultFriendsListCoordinator(navigationController: UINavigationController())),
            TabCoordinator(title: "알림", icon: UIImage(systemName: "bell"),
                           coordinator: DefaultNotificationCoordinator(navigationController: UINavigationController())),
            TabCoordinator(title: "마이페이지", icon: UIImage(systemName: "person"),
                           coordinator: DefaultMyPageCoordinator(navigationController: UINavigationController()))
        ]

        viewControllers = tabCoordinators.map { coordinator -> UIViewController in
            coordinator.coordinator.start()
            
            let tabBarItem = UITabBarItem(title: coordinator.title, image: coordinator.icon, selectedImage: nil)
            
            coordinator.coordinator.navigationController.tabBarItem = tabBarItem
            return coordinator.coordinator.navigationController
        }
    }
}
