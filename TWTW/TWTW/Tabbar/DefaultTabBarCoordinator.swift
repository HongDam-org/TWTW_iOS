//
//  DefaultTabBarCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/09.
//

import Foundation
import RxSwift
import UIKit

final class DefaultTabBarCoordinator: TabBarCoordinator {
    var navigationControllerDelegate = TabBarNavigationControllerDelegate()

    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var tabBarController: TabBarController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = TabBarController()
    }

    func setNavigationControllerDelegate() {
        navigationController.delegate = navigationControllerDelegate
     }
    
    func start() {
        setNavigationControllerDelegate()
        navigationController.viewControllers = [tabBarController]
    }
}
