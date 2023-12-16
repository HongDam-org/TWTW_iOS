//
//  DefaultPartiSetLocationCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/16.
//

import Foundation
import UIKit

final class DefaultPartiSetLocationCoordinator: PartiSetLocationCoordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
        
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        print("set")
//        let partiSetLocationViewModel = PartiSetLocationViewModel(coordinator: self)
//        let partiSetLocationVC = PartiSetLocationViewController(viewModel: partiSetLocationViewModel)
//        navigationController.pushViewController(partiSetLocationVC, animated: false)
     }
}
