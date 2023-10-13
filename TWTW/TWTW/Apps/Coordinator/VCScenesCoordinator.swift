//
//  VCScenesCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/26.
//

import Foundation
import UIKit

class NotificationCoordinator: Coordinator  {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
        
    }
    
    func start() {
        let notificationViewController = NotificationViewController()
        navigationController.pushViewController(notificationViewController, animated: true)
    }
    
    
}
class FriendsCoordinator: Coordinator  {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
    }
    func start() {
        let friendsViewController = FriendsListViewController()
        navigationController.pushViewController(friendsViewController, animated: true)
    }
    
    
}
class PreviousAppointmentsCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
    }
    func start() {
        let previousAppointsViewController = PreviousAppointmentsViewController()
        navigationController.pushViewController(previousAppointsViewController, animated: true)
    }
    
    
}
class CallCoordinator: Coordinator  {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
    }
    func start() {
        let callViewController = CallViewController()
        navigationController.pushViewController(callViewController, animated: true)
    }
    
    
}
