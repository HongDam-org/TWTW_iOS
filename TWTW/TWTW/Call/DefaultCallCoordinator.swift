//
//  CallCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/15.
//

import Foundation
import UIKit

class DefaultCallCoordinator: CallCoordinator  {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
    }
    
    func start() {
    }
    
    
    /// Create Controller
    /// - Returns: NavigationController
    func startPush() -> UINavigationController {
        let callViewController = CallViewController()
        navigationController.pushViewController(callViewController, animated: true)
        return navigationController
    }
    
}
    
