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
    private var partiGetLocationViewModel: PartiGetLocationViewModel?

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        partiGetLocationViewModel = PartiGetLocationViewModel(coordinator: self)
    }
    
    func start() {

        let partiGetLocationViewModel = PartiGetLocationViewModel(coordinator: self)
        let partiGetLocationVC = PartiGetLocationViewController(viewModel: partiGetLocationViewModel)
        navigationController.pushViewController(partiGetLocationVC, animated: true)

     }
}
