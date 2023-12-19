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
    func startFromAlert() {
        let plansViewModel = PlansViewModel(
            coordinator: self,
            caller: .fromAlert
        )
        let plansViewController = PlansViewController(viewModel: plansViewModel)
        
        navigationController.pushViewController(plansViewController, animated: false)
        
    }
    
    func moveToPlan() {
        let partiGetLocationCoordinator = DefaultPlansCoordinator(navigationController: navigationController)
        partiGetLocationCoordinator.start()
        childCoordinators.append(partiGetLocationCoordinator)
    }
    
    func moveToPartiSetLocation() {
        let plansFromAlertCoordinator = DefaultPlansFromAlertCoordinator(navigationController: navigationController)
        plansFromAlertCoordinator.start()
        childCoordinators.append(plansFromAlertCoordinator)
    }
    func addPlans() {
       self.startFromAlert()
    }
}
