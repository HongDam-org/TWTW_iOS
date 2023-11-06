//
//  NotificationCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/15.
//

import Foundation
import UIKit

class DefaultNotificationCoordinator: NotificationCoordinator  {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
    }
    
    func start() {
        let notificationViewController = NotificationViewController()
        navigationController.pushViewController(notificationViewController, animated: true)
    }
    
    /// Create Controller
    /// - Returns: NavigationController
    func startPush() -> UINavigationController {
        let notificationViewController = NotificationViewController()
        navigationController.pushViewController(notificationViewController, animated: true)
        return navigationController
    }
}
