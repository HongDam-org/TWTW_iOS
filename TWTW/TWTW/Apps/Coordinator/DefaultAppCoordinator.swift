//
//  AppCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/26.
//

import CoreLocation
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
        let defaultSignInCoordinator = DefaultFriendsListCoordinator(navigationController: navigationController)//DefaultSignInCoordinator(navigationController: navigationController)
        //defaultSignInCoordinator.delegate = self
        defaultSignInCoordinator.start()
        childCoordinators.append(defaultSignInCoordinator)
    }
    
    func moveMain() {
        childCoordinators.removeAll()
        _ = KeychainWrapper.saveItem(value: "\(0.0)", forKey: "latitude")
        _ = KeychainWrapper.saveItem(value: "\(0.0)", forKey: "longitude")
        // MeetingListCoodrinator로 이동
        let meetingListCoordinator = DefaultFriendsListCoordinator(navigationController: navigationController)//DefaultGroupCoordinator(navigationController: navigationController)
        meetingListCoordinator.start()
        
    }
    
}

extension DefaultAppCoordinator: SignInCoordinatorFinishDelegate {
    func finishLogin(_ coordinator: DefaultSignInCoordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        navigationController.viewControllers = []
        moveMain()
    }
    
}
