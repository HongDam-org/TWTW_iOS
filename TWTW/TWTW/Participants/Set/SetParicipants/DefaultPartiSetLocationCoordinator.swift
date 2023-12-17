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
    private var partiSetLocationViewModel: PartiSetLocationViewModel?
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        partiSetLocationViewModel = PartiSetLocationViewModel(coordinator: self)
        
    }
    
    func start() {
        let viewModel = PartiSetLocationViewModel(coordinator: self)
        self.partiSetLocationViewModel = viewModel
        let partiSetLocationVC = PartiSetLocationViewController(viewModel: viewModel)
        navigationController.pushViewController(partiSetLocationVC, animated: false)
    }
    /// 친구추가 화면으로 이동

    func addParticipants() {
        let friendsListCoordinator = DefaultFriendsListCoordinator(navigationController: navigationController)
        friendsListCoordinator.delegate = self // delegate를 여기에 설정
        childCoordinators.append(friendsListCoordinator)
        friendsListCoordinator.startFromPartiSetLocation()
    }

}

extension DefaultPartiSetLocationCoordinator: FriendsSendListCoordinatorDelegate {
    func didSelectFriends(_ friends: [Friend]) {
        partiSetLocationViewModel?.updateSelectedFriends(friends)
    }
}
