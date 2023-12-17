//
//  DefaultParticipantsCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/11/30.
//

import Foundation
import UIKit

final class DefaultsParticipantsCoordinator: ParticipantsCoordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let participantsViewModel = ParticipantsViewModel(coordinator: self)
        let participantsVC = ParticipantsViewController(viewModel: participantsViewModel)
        navigationController.pushViewController(participantsVC, animated: false)
    }
    
    /// 선택한 사람 장소 바꾸기
    func moveToChangeLocation() {
        let changeLocationCoordinator = DefaultChangeLocationCoordinator(navigationController: navigationController)
        changeLocationCoordinator.start()
        childCoordinators.append(changeLocationCoordinator)
    }
}
