//
//  DefaultPlansFromAlertCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/18.
//

import Foundation
import UIKit

final class DefaultPlansFromAlertCoordinator: PlanFromAlertCoordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private var plansFromAlertViewModel: PlansFromAlertViewModel?
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        plansFromAlertViewModel = PlansFromAlertViewModel(coordinator: self)
        
    }
    
    func start() {
        let viewModel = PlansFromAlertViewModel(coordinator: self)
        self.plansFromAlertViewModel = viewModel
        let plansFromAlertViewController = PlansFromAlertViewController(viewModel: viewModel)
        navigationController.pushViewController(plansFromAlertViewController, animated: false)
    }
    /// 친구추가 화면으로 이동

    func addParticipants() {
        let friendsListCoordinator = DefaultFriendsListCoordinator(navigationController: navigationController)
        friendsListCoordinator.delegate = self // delegate를 여기에 설정
        childCoordinators.append(friendsListCoordinator)
        friendsListCoordinator.startFromPartiSetLocation()
    }

}

extension DefaultPlansFromAlertCoordinator: FriendsSendListCoordinatorDelegate {
    func didSelectFriends(_ friends: [Friend]) {
        plansFromAlertViewModel?.updateSelectedFriends(friends)
    }
}
