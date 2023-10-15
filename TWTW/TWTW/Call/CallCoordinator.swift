//
//  CallCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/15.
//

import Foundation
import UIKit

class CallCoordinator: Coordinator  {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
    }
    func start() {
        let callViewController = CallViewController()
        navigationController.pushViewController(callViewController, animated: true)
    }
    
}
    
