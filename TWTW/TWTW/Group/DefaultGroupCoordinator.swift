//
//  DefaultMeetingListCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/16.
//

import Foundation
import UIKit

final class DefaultGroupCoordinator: GroupCoordinatorProtocol {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let meetingListViewModel = GroupViewModel(coordinator: self, service: GroupService())
        let meetingListViewController = GroupViewController(viewModel: meetingListViewModel)
        
        navigationController.pushViewController(meetingListViewController, animated: true)
    }
    
    func moveMainMap() {
        let mainMapCoordinator = DefaultMainMapCoordinator(navigationController: navigationController)
        childCoordinators.append(mainMapCoordinator)
        mainMapCoordinator.start()
    }
    
}
