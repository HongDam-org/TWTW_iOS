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
    /// 새로운 친구추가 화면으로 이동
    func makeNewFriends() {
        
        let defaultMakeNewFriendsListCoordinator = DefaultMakeNewFriendsListCoordinator(navigationController: navigationController)
        childCoordinators.append(defaultMakeNewFriendsListCoordinator)
        defaultMakeNewFriendsListCoordinator.start()

    }
}
