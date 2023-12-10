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
    var navigationControllerDelegate = TabBarNavigationControllerDelegate()

    private var output: CreateGroupViewModel.Output?
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
//        navigationController.delegate = navigationControllerDelegate
        let createGroupViewModel = CreateGroupViewModel(coordinator: self)
        let createGroupViewController = CreateGroupViewController(viewModel: createGroupViewModel)
        navigationController.pushViewController(createGroupViewController, animated: true)
    }
    
    /// move Selected Friends Page
    func moveSelectedFriends(output: CreateGroupViewModel.Output) {
        self.output = output
        let defaultFriendSearchCoordinator = DefaultFriendSearchCoordinator(navigationController: navigationController)
        defaultFriendSearchCoordinator.delegate = self
        defaultFriendSearchCoordinator.start()
        childCoordinators.append(defaultFriendSearchCoordinator)
    }
}

extension DefaultCreateGroupCoordinator: FriendSearchDelegate {
    func sendData(selectedList: [Friend]) {
        output?.selectedFriendListRelay.accept(selectedList)
        childCoordinators = []
        navigationController.popViewController(animated: true)
    }
}
