//
//  DefaultPartiGetLocationCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/16.
//

import Foundation
import UIKit

final class DefaultPartiGetLocationCoordinator: PartiGetLocationCoordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
        
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        print("get")
//        let partiGetLocationViewModel = PartiGetLocationViewModel(coordinator: self)
//        let partiGetLocationVC = PartiGetLocationViewController(viewModel: partiGetLocationViewModel)
//        navigationController.pushViewController(partiGetLocationVC, animated: false)

     }
}
