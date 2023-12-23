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
    var tabBarController: UITabBarController
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
//    var type: CoordinatorType

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
//        self.type = CoordinatorType.tab
        // 탭바 생성
        self.tabBarController = UITabBarController()
    }
    
    /// 탭바 설정 함수들의 흐름 조정
    func start() {
        // 1. 탭바 아이템 리스트 생성
        let pages: [TabBarItemType] = TabBarItemType.allCases
        // 2. 탭바 아이템 생성
        let tabBarItems: [UITabBarItem] = pages.map { self.createTabBarItem(of: $0) }
        // 3. 탭바별 navigation controller 생성
        let controllers: [UINavigationController] = tabBarItems.map { createTabNavigationController(tabBarItem: $0) }
        // 4. 탭바별로 코디네이터 생성하기
        _ = controllers.map { startTabCoordinator(tabNavigationController: $0) }
        // 5. 탭바 스타일 지정 및 VC 연결
        configureTabBarController(tabNavigationControllers: controllers)
        // 6. 탭바 화면에 붙이기
        addTabBarController()
    }

    // MARK: - TabBarController 설정 메소드
    
    /// 탭바 스타일 지정 및 초기화
    private func configureTabBarController(tabNavigationControllers: [UIViewController]) {
        // TabBar의 VC 지정
        self.tabBarController.setViewControllers(tabNavigationControllers, animated: false)
        // home의 index로 TabBar Index 세팅
        self.tabBarController.selectedIndex = TabBarItemType.home.toInt()
        // TabBar 스타일 지정
        self.tabBarController.view.backgroundColor = .systemBackground
        self.tabBarController.tabBar.backgroundColor = .systemBackground
        self.tabBarController.tabBar.tintColor = UIColor.black
    }
    
    private func addTabBarController() {
        // 화면에 추가
        navigationController.pushViewController(self.tabBarController, animated: true)
    }
    
    /// 탭바 아이템 생성
    private func createTabBarItem(of page: TabBarItemType) -> UITabBarItem {
        return UITabBarItem(
            title: page.toKrName(),
            image: UIImage(systemName: page.toIconName()),
            tag: page.toInt()
        )
    }

    /// 탭바 페이지대로 탭바 생성
    private func createTabNavigationController(tabBarItem: UITabBarItem) -> UINavigationController {
        let tabNavigationController = UINavigationController()
        
        tabNavigationController.setNavigationBarHidden(false, animated: false)
        tabNavigationController.navigationBar.topItem?.title = TabBarItemType(index: tabBarItem.tag)?.toKrName()
        tabNavigationController.tabBarItem = tabBarItem

        return tabNavigationController
    }
    
    private func startTabCoordinator(tabNavigationController: UINavigationController) {
        // tag 번호로 TabBarPage로 변경
        let tabBarItemTag: Int = tabNavigationController.tabBarItem.tag
        guard let tabBarItemType: TabBarItemType = TabBarItemType(index: tabBarItemTag) else { return }
        
        // 코디네이터 생성 및 실행
        switch tabBarItemType {
        case .home:
            let homeCoordinator = DefaultGroupCoordinator(navigationController: tabNavigationController)
            self.childCoordinators.append(homeCoordinator)
            homeCoordinator.start()
        case .friends:
            let friendCoordinator = DefaultFriendsListCoordinator(navigationController: tabNavigationController)
            self.childCoordinators.append(friendCoordinator)
            friendCoordinator.start()
        case .notification:
            let notificationCoordinator = DefaultNotificationCoordinator(navigationController: tabNavigationController)
            self.childCoordinators.append(notificationCoordinator)
            notificationCoordinator.start()
        case .myPage:
            let myPageCoordinator = DefaultMyPageCoordinator(navigationController: tabNavigationController)
            self.childCoordinators.append(myPageCoordinator)
            myPageCoordinator.start()
        }
    }
}
