//
//  FriendsListCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/15.
//

import Foundation
import UIKit

final class DefaultFriendsListCoordinator: FriendsListCoordinatorProtocol {
    func sendSelectedFriends(output: FriendsListViewModel.Output) {
        
    }
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let friendsListViewModel = FriendsListViewModel(coordinator: self, friendService: FriendService())
        let friendsListViewController = FriendsListViewController(viewModel: friendsListViewModel)
        navigationController.pushViewController(friendsListViewController, animated: false)
    }
    /// 그룹 생성 화면으로 이동
    func makeNewFriends() {
        let defaultMakeNewFriendsListCoordinator = DefaultMakeNewFriendsListCoordinator(navigationController: navigationController)
        
        childCoordinators.append(defaultMakeNewFriendsListCoordinator)
        defaultMakeNewFriendsListCoordinator.start()
    }
}
