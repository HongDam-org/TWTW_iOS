//
//  DefaultsParticipantsCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/11/30.
//

import Foundation
import UIKit

final class DefaultsParticipantsCoordinator: ParticipantsCoordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let
        participantsViewController = ParticipantsViewController()
        navigationController.pushViewController(participantsViewController, animated: true)
    }

}
