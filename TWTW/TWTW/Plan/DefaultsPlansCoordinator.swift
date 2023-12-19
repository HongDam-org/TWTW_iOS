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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let plansViewModel = PlansViewModel(coordinator: self)
        let plansViewController = PlansViewController(viewModel: plansViewModel)
        
        navigationController.pushViewController(plansViewController, animated: true)
    }
    //첫 지도화면에서 탭바버튼으로
    func planStartFromTabBar() {
        let plansViewModel = PlansViewModel(
            coordinator: self,
            caller: .fromTabBar
        )
        let plansViewController = PlansViewController(viewModel: plansViewModel)
        
        navigationController.pushViewController(plansViewController, animated: false)
        
        
    }
    
    func startFromAlert() {
        let plansViewModel = PlansViewModel(
            coordinator: self,
            caller: .fromAlert
        )
        let plansViewController = PlansViewController(viewModel: plansViewModel)
        
        navigationController.pushViewController(plansViewController, animated: false)
        
    }
    
    func moveToPlanFromTabBar() {
        let findRoadCoordinator = DefaultsFindRoadCoordinator(navigationController: navigationController)
        findRoadCoordinator.start()
        childCoordinators.append(findRoadCoordinator)
    }
    
    func moveToplansFromAlert() {
        let plansFromAlertCoordinator = DefaultPlansFromAlertCoordinator(navigationController: navigationController)
        plansFromAlertCoordinator.start()
        childCoordinators.append(plansFromAlertCoordinator)
    }
    func addPlans() {
       self.startFromAlert()
    }
}
