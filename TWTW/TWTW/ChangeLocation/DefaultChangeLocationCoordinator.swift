//
//  DefaultChangeLocationCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/08.
//

import Foundation
import UIKit

final class DefaultChangeLocationCoordinator: ChangeLocationCoordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private lazy var changeLocationVC = ChangeLocationViewController()
    
    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
       
     }
}
