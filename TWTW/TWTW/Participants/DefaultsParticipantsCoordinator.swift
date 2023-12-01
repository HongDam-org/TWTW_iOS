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
    
    private lazy var participantsVC = ParticipantsViewController()
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        participantsVC = ParticipantsViewController()
        navigationController.pushViewController(participantsVC, animated: false)
    }

}
