//
//  DefaultMeetingListCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/16.
//

import Foundation
import UIKit

final class DefaultMeetingListCoordinator: MeetingListCoordinatorProtocol {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let meetingListViewModel = MeetingListViewModel(coordinator: self)
        let meetingListViewController = MeetingListViewController(viewModel: meetingListViewModel)
        
        navigationController.pushViewController(meetingListViewController, animated: true)
    }
    
    func moveMainMap() {
        let mainMapCoordinator = DefaultMainMapCoordinator(navigationController: navigationController)
        mainMapCoordinator.start()
    }
    
}
