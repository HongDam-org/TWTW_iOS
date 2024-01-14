//
//  FriendsListCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/15.
//

import Foundation
import UIKit

final class DefaultFriendsListCoordinator: FriendsListCoordinatorProtocol {

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var navigationControllerDelegate = TabBarNavigationControllerDelegate()
    
    weak var delegate: FriendsSendListCoordinatorDelegate?

    private var output: FriendsListViewModel.Output?

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    func setNavigationControllerDelegate() {
        navigationController.delegate = navigationControllerDelegate
    }
    
    func start() {
        setNavigationControllerDelegate()
        let friendsListViewModel = FriendsListViewModel(coordinator: self, friendService: FriendService())
        let friendsListViewController = FriendsListViewController(viewModel: friendsListViewModel)
        navigationController.pushViewController(friendsListViewController, animated: false)
    }
    
    /// mark : 참여자 추가할때  fromPartiSetLocation
    func startFromPartiSetLocation() {
        let friendsListViewModel = FriendsListViewModel(
            coordinator: self,
            friendService: FriendService(),
            caller: .fromPartiSetLocation
        )
        let friendsListViewController = FriendsListViewController(viewModel: friendsListViewModel)
        
        navigationController.pushViewController(friendsListViewController, animated: true)
        
    }

    /// 새로운 친구추가 화면으로 이동
    func makeNewFriends() {
        let defaultMakeNewFriendsListCoordinator = DefaultMakeNewFriendsListCoordinator(navigationController: navigationController)
        childCoordinators.append(defaultMakeNewFriendsListCoordinator)
        defaultMakeNewFriendsListCoordinator.start()

    }

    func navigateBackWithSelectedFriends(_ friends: [Friend]) {
        delegate?.didSelectFriends(friends)
        navigationController.popViewController(animated: true)
    }
}
