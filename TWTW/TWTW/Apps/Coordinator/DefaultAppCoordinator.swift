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
        let defaultLoginCoordinator = DefaultSignInCoordinator(navigationController: navigationController)
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

extension DefaultAppCoordinator: SignInCoordinatorFinishDelegate {
    func finishLogin(_ coordinator: DefaultSignInCoordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        moveMain()
    }
    
}
