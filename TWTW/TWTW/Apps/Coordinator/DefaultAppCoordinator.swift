//
//  AppCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/26.
//

import Foundation
import UIKit

/// App Coordinator
final class DefaultAppCoordinator: AppCoordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        moveSignIn()
    }
    
    func moveSignIn() {
        let defaultSignInCoordinator = DefaultSignInCoordinator(navigationController: navigationController)
        defaultSignInCoordinator.delegate = self
        defaultSignInCoordinator.start()
        childCoordinators.append(defaultSignInCoordinator)
    }
    
    func moveMain() {
            childCoordinators.removeAll()
            // MeetingListCoodrinator로 이동
            let meetingListCoordinator = DefaultMeetingListCoordinator(navigationController: navigationController)
            meetingListCoordinator.start()

        }
    
}

extension DefaultAppCoordinator: SignInCoordinatorFinishDelegate {
    func finishLogin(_ coordinator: DefaultSignInCoordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        moveMain()
    }
    
}
