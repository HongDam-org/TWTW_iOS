//
//  DefaultTabBarCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/09.
//

import Foundation
import RxSwift
import UIKit

final class DefaultTabBarCoordinator: TabBarCoordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var tabBarController: UITabBarController
    
    var tabCoordinators: [TabCoordinator]
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
        
        // 각 탭 코디네이터 초기화
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
        childCoordinators.append(contentsOf: tabCoordinators.map { $0.coordinator })
    }
    
    func start() {
        tabCoordinators.forEach { tabCoordinator in
            let navigationController = tabCoordinator.coordinator.navigationController
            navigationController.tabBarItem = UITabBarItem(title: tabCoordinator.title, image: tabCoordinator.icon, selectedImage: nil)
            tabCoordinator.coordinator.start()
        }
        
        tabBarController.viewControllers = childCoordinators.map { $0.navigationController }
        navigationController.viewControllers = [tabBarController]
    }
}
