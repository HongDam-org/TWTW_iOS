//
//  DefaultMeetingListCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/16.
//

import Foundation
import UIKit

final class DefaultGroupCoordinator: GroupCoordinatorProtocol {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showMainPage(_:)),
                                               name: NSNotification.Name("moveMain"), object: nil)
    }
    
    func start() {
        let groupViewModel = GroupViewModel(coordinator: self, service: GroupService())
        let groupViewController = GroupViewController(viewModel: groupViewModel)
        navigationController.pushViewController(groupViewController, animated: true)
    }
    
    /// 메인 지도 화면으로 이동
    func moveMainMap() {
        let mainMapCoordinator = DefaultMainMapCoordinator(navigationController: navigationController)
        childCoordinators.append(mainMapCoordinator)
        mainMapCoordinator.start()
    }
    
    /// 그룹 생성 화면으로 이동
    func moveCreateGroup() {
        let defaultCreateGroupCoordinator = DefaultCreateGroupCoordinator(navigationController: navigationController)
        childCoordinators.append(defaultCreateGroupCoordinator)
        defaultCreateGroupCoordinator.start()
    }
    
    /// 알림 페이지로 넘어가는 함수
    @objc
    private func showMainPage(_ notification: Notification) {
        print("show Main Paeg🪡")
        moveMainMap()
        NotificationCenter.default.post(name: Notification.Name("moveToPlans"), object: nil)
    }

}
