//
//  DefaultMakeNewMeetingCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/17.
//

import Foundation
import UIKit

final class DefaultMakeNewMeetingCoordinator: MakeNewMeetingCoordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private var makeNewMeetingViewModel: MakeNewMeetingViewModel?

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        makeNewMeetingViewModel = MakeNewMeetingViewModel(coordinator: self)
    }
    
    func start() {
        let makeNewMeetingViewModel = MakeNewMeetingViewModel(coordinator: self)
        let makeNewMeetingVC = MakeNewMeetingViewController(viewModel: makeNewMeetingViewModel)
        
        navigationController.pushViewController(makeNewMeetingVC, animated: false)

     }
    
}
