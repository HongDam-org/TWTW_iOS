//
//  DefaultTabbarCoordinator.swift
//  TWTW
//
//  Created by 정호진 on 10/17/23.
//

import Foundation
import UIKit
import RxSwift

final class DefaultTabbarCoordinator: TabbarCoordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController //for SearchPlacesCoordinator
    var tabBarController: TabBarController // for TabBarCoordinator
    var delegate: TabbarCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = TabBarController()
    }
    
    func start() {
        delegate?.tabbarControllerInstance(tabBarController: tabBarController)
    }
    
    
}


