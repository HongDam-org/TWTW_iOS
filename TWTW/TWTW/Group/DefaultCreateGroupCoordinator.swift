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
    
    func setNavigationControllerDelegate() {
        navigationController.delegate = navigationControllerDelegate
    }
    
    func start() {
        setNavigationControllerDelegate()
        let createGroupViewModel = CreateGroupViewModel(coordinator: self, groupService: GroupService())
        let createGroupViewController = CreateGroupViewController(viewModel: createGroupViewModel)
        navigationController.pushViewController(createGroupViewController, animated: true)
    }
    
    /// move Selected Friends Page
    /// - Parameter output: Output
    func moveSelectedFriends(output: CreateGroupViewModel.Output) {
        self.output = output
        let defaultFriendSearchCoordinator = DefaultFriendSearchCoordinator(navigationController: navigationController)
        defaultFriendSearchCoordinator.delegate = self
        defaultFriendSearchCoordinator.start()
        childCoordinators.append(defaultFriendSearchCoordinator)
    }
    
    /// Move to Group List Page
    func moveGroupList() {
        navigationController.popViewController(animated: true)
        childCoordinators = []
    }
}

extension DefaultCreateGroupCoordinator: FriendSearchDelegate {
    /// Send Data
    /// - Parameter selectedList: Selected Friend List
    func sendData(selectedList: [Friend]) {
        output?.selectedFriendListRelay.accept(selectedList)
        childCoordinators = []
        navigationController.popViewController(animated: true)
    }
}
