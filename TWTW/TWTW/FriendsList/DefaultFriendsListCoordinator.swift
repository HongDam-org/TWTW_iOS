//
//  FriendsListCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/15.
//

import Foundation
import UIKit

final class DefaultFriendsListCoordinator: FriendsListCoordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let friendsListViewController = FriendsListViewController()
        navigationController.pushViewController(friendsListViewController, animated: false)
    }
}
