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
        let viewModel = PlansFromAlertViewModel(coordinator: self, caller: .forRevice)
        self.plansFromAlertViewModel = viewModel
        let plansFromAlertViewController = PlansFromAlertViewController(viewModel: viewModel)
        navigationController.pushViewController(plansFromAlertViewController, animated: false)
    }
    
    func startToAddPlan() {
        let viewModel = PlansFromAlertViewModel(coordinator: self, caller: .forNew)
        self.plansFromAlertViewModel = viewModel
        let plansFromAlertViewController = PlansFromAlertViewController(viewModel: viewModel)
        navigationController.pushViewController(plansFromAlertViewController, animated: false)
    }
    
    /// 친구추가 화면으로 이동
    func addParticipants() {
        let friendsListCoordinator = DefaultFriendsListCoordinator(navigationController: navigationController)
        friendsListCoordinator.delegate = self 
        childCoordinators.append(friendsListCoordinator)
        friendsListCoordinator.startFromPartiSetLocation()
    }
    /// 설정완료후 처음 지도 화면으로
    func moveToMain() {
        childCoordinators.removeAll()
        let mainMapCoordinator = DefaultMainMapCoordinator(navigationController: navigationController)
        mainMapCoordinator.start()
        childCoordinators.append(mainMapCoordinator)
        //navigationController.popToRootViewController(animated: true)
    }
    /// 길찾기
//    func moveToFindRoad() {
//        let findRoadCoordinator = DefaultsFindRoadCoordinator(navigationController: navigationController)
//        childCoordinators.append(findRoadCoordinator)
//        findRoadCoordinator.start()
//    }
}

extension DefaultPlansFromAlertCoordinator: FriendsSendListCoordinatorDelegate {
    func didSelectFriends(_ friends: [Friend]) {
        plansFromAlertViewModel?.updateSelectedFriends(friends)
    }
}