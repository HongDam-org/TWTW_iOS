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

    init(navigationController: UINavigationController) {
        self.tabBarController = TabBarController()
        self.navigationController = navigationController
      
        print(#function)
    }
    
    deinit {
        print("deinit DafaultTabBar")
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
        
        print(#function, "start")
    }

    // MARK: - TabBarController 설정 메소드
    
    /// 탭바 스타일 지정 및 초기화
    private func configureTabBarController(tabNavigationControllers: [UIViewController]) {
        // TabBar의 VC 지정
        tabBarController.setViewControllers(tabNavigationControllers, animated: false)
        // home의 index로 TabBar Index 세팅
        tabBarController.selectedIndex = TabBarItemType.home.toInt()
        // TabBar 스타일 지정
        tabBarController.view.backgroundColor = .white
        tabBarController.tabBar.backgroundColor = .clear
        tabBarController.tabBar.tintColor = UIColor.black
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
        tabNavigationController.setNavigationBarHidden(true, animated: true)
        tabNavigationController.tabBarItem = tabBarItem

        return tabNavigationController
    }
    
    private func startTabCoordinator(tabNavigationController: UINavigationController) {
        // tag 번호로 TabBarPage로 변경
        let tabBarItemTag: Int = tabNavigationController.tabBarItem.tag
        guard let tabBarItemType: TabBarItemType = TabBarItemType(index: tabBarItemTag) else { return }
        
        // 코디네이터 생성 및 실행
        switch tabBarItemType {
        case .friends:
            let friendCoordinator = DefaultFriendsListCoordinator(navigationController: tabNavigationController)
            childCoordinators.append(friendCoordinator)
            friendCoordinator.start()
        case .home:
            let groupCoordinator = DefaultGroupCoordinator(navigationController: tabNavigationController)
            childCoordinators.append(groupCoordinator)
            groupCoordinator.start()
        case .myPage:
            let myPageCoordinator = DefaultMyPageCoordinator(navigationController: tabNavigationController)
            childCoordinators.append(myPageCoordinator)
            myPageCoordinator.start()
        }
    }
}
