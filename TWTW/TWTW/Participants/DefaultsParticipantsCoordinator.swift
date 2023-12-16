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
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let participantsViewModel = PartiGetLocationViewModel(coordinator: self)
        let participantsViewController = ParticipantsViewController(viewModel: participantsViewModel)
        
        navigationController.pushViewController(participantsViewController, animated: true)
    }
    
    func startWithViewModel(from source: ParticipantsSource) {
        let viewModel: PartiLocationViewModel

            switch source {
            case .get:
                viewModel = PartiGetLocationViewModel(coordinator: self)
               
            case .set:
                viewModel = PartiSetLocationViewModel(coordinator: self)

            }
        
              let participantsViewController = ParticipantsViewController(viewModel: viewModel)
              navigationController.pushViewController(participantsViewController, animated: true)
          }

    /// 선택한 사람 장소 바꾸기
    func moveToChangeLocation() {
        let changeLocationCoordinator = DefaultChangeLocationCoordinator(navigationController: navigationController)
        changeLocationCoordinator.start()
        childCoordinators.append(changeLocationCoordinator)
    }
}
