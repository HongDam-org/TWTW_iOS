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
    
    /// 탭버튼 코디네이터 4개
    var defaultGroupCoordinator: DefaultGroupCoordinator
    var defaultFriendsListCoordinator: DefaultFriendsListCoordinator
    var defaultNotificationCoordinator: DefaultNotificationCoordinator
    var defaultMyPageCoordinator: DefaultMyPageCoordinator
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
        
        /// 각 탭 코디네이터 초기화
        self.defaultGroupCoordinator = DefaultGroupCoordinator(navigationController: UINavigationController())
        self.defaultFriendsListCoordinator = DefaultFriendsListCoordinator(navigationController: UINavigationController())
        self.defaultNotificationCoordinator = DefaultNotificationCoordinator(navigationController: UINavigationController())
        self.defaultMyPageCoordinator = DefaultMyPageCoordinator(navigationController: UINavigationController())
        
        childCoordinators.append(contentsOf: [
            defaultGroupCoordinator as Coordinator,
            defaultFriendsListCoordinator as Coordinator,
            defaultNotificationCoordinator as Coordinator,
            defaultMyPageCoordinator as Coordinator
        ])
        
    }
    
    func start() {
        childCoordinators.forEach { $0.start() }
        
        let groupNavigationController = defaultGroupCoordinator.navigationController
        groupNavigationController.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "person"), selectedImage: nil)
        
        let friendsListNavgationController = defaultFriendsListCoordinator.navigationController
        friendsListNavgationController.tabBarItem = UITabBarItem(title: "친구목록", image: UIImage(systemName: "person"), selectedImage: nil)
        let notificationNavgationController = defaultNotificationCoordinator.navigationController
        notificationNavgationController.tabBarItem = UITabBarItem(title: "알림", image: UIImage(systemName: "person"), selectedImage: nil)
        let myPageNavgationController = defaultMyPageCoordinator.navigationController
        myPageNavgationController.tabBarItem = UITabBarItem(title: "마이페이지", image: UIImage(systemName: "person"), selectedImage: nil)
        
        tabBarController.viewControllers = childCoordinators.map { $0.navigationController }
        navigationController.viewControllers = [tabBarController]
    }
}
