//
//  DefaultParticipantsCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/11/30.
//

import Foundation
import UIKit

final class DefaultParticipantsCoordinator: ParticipantsCoordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let participantsViewModel = ParticipantsGetViewModel(coordinator: self)
        let participantsViewController = ParticipantsViewController(viewModel: participantsViewModel)
        
        navigationController.pushViewController(participantsViewController, animated: true)
    }
    
    func startWithViewModel(from source: ParticipantsSource) {
        let viewModel: PartiLocationViewModel
        
        switch source {
        case .get:
            viewModel = ParticipantsGetViewModel(coordinator: self)
            
        case .set:
            viewModel = ParticipantsSetViewModel(coordinator: self)
        }
        
        let participantsViewController = ParticipantsViewController(viewModel: viewModel)
        navigationController.pushViewController(participantsViewController, animated: true)
    }
    
    func moveToPartiGetLocation() {
        let partiGetLocationCoordinator = DefaultPartiGetLocationCoordinator(navigationController: navigationController)
        partiGetLocationCoordinator.start()
        childCoordinators.append(partiGetLocationCoordinator)
    }
    
    func moveToPartiSetLocation() {
        let partiSetLocationCoordinator = DefaultPartiSetLocationCoordinator(navigationController: navigationController)
        partiSetLocationCoordinator.start()
        childCoordinators.append(partiSetLocationCoordinator)
    }
    
    func moveToMakeNewMeeting() {
        let makeNewMeetingCoordinator = DefaultMakeNewMeetingCoordinator(navigationController: navigationController)
        makeNewMeetingCoordinator.start()
        childCoordinators.append(makeNewMeetingCoordinator)
    }
}
