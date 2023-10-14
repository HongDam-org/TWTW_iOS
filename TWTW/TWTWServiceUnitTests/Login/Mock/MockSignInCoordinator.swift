//
//  MockSignInCoordinator.swift
//  TWTW
//
//  Created by 정호진 on 10/14/23.
//

import Foundation
import UIKit

final class MockSignInCoordinator: SignInCoordinatorProtocol {
    
    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController
    var delegate: MockSignInCoordinatorDelegate?
    init(childCoordinators: [Coordinator], navigationController: UINavigationController?) {
        self.childCoordinators = childCoordinators
        self.navigationController = navigationController!
    }
    
    func start() {
        print("Mock \(#function)")
    }
    
    func moveLogin() {
        print("Mock \(#function)")
    }
    
    func moveSignUp() {
        print("Mock \(#function)")
    }
    
    func moveMain() {
        print("Mock \(#function)")
        delegate?.moveMain(function: #function)
    }
    
}

protocol MockSignInCoordinatorDelegate {
    func moveMain(function: String)
}

