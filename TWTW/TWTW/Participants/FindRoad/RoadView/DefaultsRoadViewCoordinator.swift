//
//  DefaultsRoadViewCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/21.
//

import Foundation
import UIKit

final class DefaultsRoadViewCoordinator: RoadViewCoordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private var roadViewModel: RoadViewModel?

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        roadViewModel = RoadViewModel(coordinator: self)
    }
    
    func start() {
        let roadViewModel = RoadViewModel(coordinator: self)
        let roadViewController = RoadViewController()
        navigationController.pushViewController(roadViewController, animated: true)

     }
}
