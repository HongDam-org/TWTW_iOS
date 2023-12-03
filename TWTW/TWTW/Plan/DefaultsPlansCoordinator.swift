//
//  DefaultsPlansCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/01.
//

import Foundation
import UIKit

final class DefaultPlansCoordinator: PlanCoordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private lazy var planVC = PlanViewController()
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        planVC = PlanViewController()
        navigationController.pushViewController(planVC, animated: false)
    }
}
