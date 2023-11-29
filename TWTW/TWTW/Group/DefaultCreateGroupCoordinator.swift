//
//  CreateGroupCoordinator.swift
//  TWTW
//
//  Created by 정호진 on 11/29/23.
//

import Foundation
import UIKit

final class DefaultCreateGroupCoordinator: CreateGroupCoordinatorProtocol {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let createGroupViewModel = CreateGroupViewModel(coordinator: self)
        let friendListView = FriendListView()
        friendListView.viewModel = FriendListViewModel(coordinator: self)
        let createGroupViewController = CreateGroupViewController(viewModel: createGroupViewModel,
                                                                  friendListview: friendListView)
        navigationController.pushViewController(createGroupViewController, animated: true)
    }
    
}
