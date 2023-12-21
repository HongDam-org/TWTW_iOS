//
//  NotificationCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/15.
//

import Foundation
import UIKit

final class DefaultNotificationCoordinator: NotificationCoordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let notificationViewModel = NotificationViewModel(coordinator: self)
        let notificationViewController = NotificationViewController(viewModel: notificationViewModel)
        navigationController.viewControllers = [notificationViewController]
    }
}
