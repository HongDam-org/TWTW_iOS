//
//  AppCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/26.
//

import Foundation
import UIKit

final class DefaultAppCoordinator: AppCoordinator {    
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        moveLogin()
    }
    
    func moveLogin() {
        let defaultLoginCoordinator = DefaultLoginCoordinator(navigationController: navigationController)
        defaultLoginCoordinator.delegate = self
        defaultLoginCoordinator.start()
        childCoordinators.append(defaultLoginCoordinator)
    }
    
    func moveMain() {
        childCoordinators.removeAll()
        // MeetingListCoodrinator로 이동
        print("called DefaultAppCoordinator \(#function)")
    }
    
}

extension DefaultAppCoordinator: CoordinatorFinishDelegate {
    func finishLogin(_ coordinator: DefaultLoginCoordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        moveMain()
    }
    
}
