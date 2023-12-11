//
//  DefaultMyPageCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/09.
//

import Foundation
import UIKit

final class DefaultMyPageCoordinator: MyPageCoordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    func start() {
        let myPageViewController = MyPageViewController()
        navigationController.pushViewController(myPageViewController, animated: true)
    }
}
