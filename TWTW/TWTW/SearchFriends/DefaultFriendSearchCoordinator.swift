//
//  DefaultFriendSearchCoordinator.swift
//  TWTW
//
//  Created by 정호진 on 12/1/23.
//

import Foundation
import RxSwift
import UIKit

final class DefaultFriendSearchCoordinator: FriendSearchCoordinatorProtocol {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var delegate: FriendSearchDelegate?
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let friendSearchViewModel = FriendSearchViewModel(coordinator: self, friendService: FriendService())
        let friendSearchViewController = FriendSearchViewController(viewModel: friendSearchViewModel)
        
        navigationController.pushViewController(friendSearchViewController, animated: true)
    }
    
    /// 선택한 친구들 전송
    /// - Parameter output: Output
    func sendSelectedFriends(output: FriendSearchViewModel.Output) {
        delegate?.sendData(selectedList: output.selectedFriendRelay.value)
    }
}
