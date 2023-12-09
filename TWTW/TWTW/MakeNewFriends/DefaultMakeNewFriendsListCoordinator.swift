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
    var delegate: MakeNewFriendsDelegate?
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let makeNewFriendsListViewModel = MakeNewFriendsListViewModel(coordinator: self, friendService: FriendService())
        let makeNewFriendsListViewController = MakeNewFriendsListViewController(viewModel: makeNewFriendsListViewModel)
        navigationController.pushViewController(makeNewFriendsListViewController, animated: true)
    }
    
    /// 선택한 친구들 전송
    /// - Parameter output: Output
    func sendSelectedNewFriends(output: MakeNewFriendsListViewModel.Output) {
        delegate?.sendData(selectedList: output.selectedFriendRelay.value)
    }
    
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
}
