//
//  DefaultMakeNewFriendsListCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/03.
//

import Foundation
import RxSwift
import UIKit

final class DefaultMakeNewFriendsListCoordinator: MakeNewFriendsListCoordinatorProtocol {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var navigationControllerDelegate = TabBarNavigationControllerDelegate()

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let makeNewFriendsListViewModel = MakeNewFriendsListViewModel(coordinator: self, friendService: FriendService())
        let makeNewFriendsListViewController = MakeNewFriendsListViewController(viewModel: makeNewFriendsListViewModel)
        
        setNavigationControllerDelegate()
        
        navigationController.pushViewController(makeNewFriendsListViewController, animated: true)
    }
    
    func setNavigationControllerDelegate() {
        navigationController.delegate = navigationControllerDelegate
    }

    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
}
