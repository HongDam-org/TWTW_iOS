//
//  TabbarCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/13.
//

import Foundation
import UIKit

class TabBarCoordinator: Coordinator{
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var tabBarController: UITabBarController
    
    init(tabBarController: UITabBarController){
        self.tabBarController = tabBarController
        self.navigationController = UINavigationController()
        self.tabBarController.viewControllers = []
        
        
    }
    func start() {
    
        let previousAppointmentCoordinator = PreviousAppointmentsCoordinator(navigationController: navigationController)
        let friendsListCoordinator = FriendsCoordinator(navigationController: navigationController)
        let notificationCoordinator = NotificationCoordinator(navigationController: navigationController)
        let callCoordinator = CallCoordinator(navigationController: navigationController)
        
        // Coordinator를 childCoordinators에 추가
        childCoordinators.append(previousAppointmentCoordinator)
        childCoordinators.append(friendsListCoordinator)
        childCoordinators.append(notificationCoordinator)
        childCoordinators.append(callCoordinator)
        
        // 탭 바 아이템을 생성
        
    }
    // 탭바와 뷰컨트롤러 연결
    private func setTabbar() {
        // 각 탭 아이템 생성
        let tabItems: [TabItem] = [
            TabItem(title: "홈", imageName: "house"),
            TabItem(title: "일정", imageName: "calendar"),
            TabItem(title: "친구 목록", imageName: "person.2"),
            TabItem(title: "알림", imageName: "bell"),
            TabItem(title: "전화", imageName: "phone")
        ]
        
//        viewControllers = [
//            PreviousAppointmentsViewController(),
//            PreviousAppointmentsViewController(),
//            FriendsListViewController(),
//            NotificationViewController(),
//            CallViewController()
//        ]
//        tabItemsRelay.accept(tabItems)
        
//        addSubViews()
//        bindTabItems()
    }
}
