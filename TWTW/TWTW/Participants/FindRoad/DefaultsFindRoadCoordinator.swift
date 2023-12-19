//
//  DefaultsFindRoadCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/18.
//

import Foundation
import UIKit

final class DefaultsFindRoadCoordinator: FindRoadCoordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private var findRoadViewModel: FindRoadViewModel?

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        findRoadViewModel = FindRoadViewModel(coordinator: self)
    }
    
    func start() {

        let findRoadViewModel = FindRoadViewModel(coordinator: self)
        let findRoadViewController = FindRoadViewController(viewModel: findRoadViewModel)
        navigationController.pushViewController(findRoadViewController, animated: true)

     }
}
