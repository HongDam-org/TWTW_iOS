//
//  AppCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/26.
//

import Foundation
import UIKit
import RxSwift

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let disposeBag = DisposeBag()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let defaultLoginCoordinator = DefaultLoginCoordinator(navigationController: navigationController)
        defaultLoginCoordinator.delegate = self
        defaultLoginCoordinator.start()
        childCoordinators.append(defaultLoginCoordinator)
    }
    
}

extension AppCoordinator: CoordinatorFinishDelegate {
    
}
