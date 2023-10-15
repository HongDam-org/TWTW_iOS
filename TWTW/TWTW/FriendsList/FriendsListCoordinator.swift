//
//  FriendsListCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/15.
//

import Foundation
import UIKit

class FriendsListCoordinator: Coordinator  {
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
