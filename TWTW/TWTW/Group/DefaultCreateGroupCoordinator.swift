//
//  CreateGroupCoordinator.swift
//  TWTW
//
//  Created by 정호진 on 11/29/23.
//

import Foundation
import RxSwift
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
        let createGroupViewController = CreateGroupViewController(viewModel: createGroupViewModel)
        navigationController.pushViewController(createGroupViewController, animated: true)
    }
    
    /// move Selected Friends Page
    func moveSelectedFriends(output: CreateGroupViewModel.Output) {
        let defaultFriendSearchCoordinator = DefaultFriendSearchCoordinator(navigationController: navigationController)
        defaultFriendSearchCoordinator.start()
        childCoordinators.append(defaultFriendSearchCoordinator)
    }
}
