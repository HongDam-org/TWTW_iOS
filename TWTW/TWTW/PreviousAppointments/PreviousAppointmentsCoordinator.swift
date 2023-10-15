//
//  PreviousAppointmentsCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/15.
//

import Foundation
import UIKit

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
