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
    var output: ParticipantsViewModel.Output?
    
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
    
    /// Add New Friends In Group
    func moveAddNewFriends(output: ParticipantsViewModel.Output) {
        let defaultFriendSearchCoordinator = DefaultFriendSearchCoordinator(navigationController: navigationController)
        defaultFriendSearchCoordinator.start()
        defaultFriendSearchCoordinator.delegate = self
        self.output = output
        childCoordinators.append(defaultFriendSearchCoordinator)
    }
}

extension DefaultsParticipantsCoordinator: FriendSearchDelegate {
    func sendData(selectedList: [Friend]) {
        output?.participantsRelay.accept(selectedList)
        navigationController.popViewController(animated: true)
    }
    
}
