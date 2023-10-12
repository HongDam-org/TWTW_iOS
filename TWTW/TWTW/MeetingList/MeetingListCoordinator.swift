//
//  MeetingListCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/13.
//

import Foundation
import UIKit

class MeetingListCoordinator: Coordinator {
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
    func buttonTapped(){
        navigationController.pushViewController(MainMapViewController(), animated: true)
        //TabbarController로 이동
     
    }

}
