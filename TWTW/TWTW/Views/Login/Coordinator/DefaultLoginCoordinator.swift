//
//  DefaultLoginCoordinator.swift
//  TWTW
//
//  Created by 정호진 on 10/9/23.
//

import Foundation
import UIKit

final class DefaultLoginCoordinator: LoginCoordinatorProtocol {
    
    var childCoordinators: [Coordinator] = []
    
    var delegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    private let signInViewController: SignInViewController
    private var signInViewModel: SignInViewModel?
    
    init( navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.signInViewController = SignInViewController()
    }
    
    func start() {
        print("Called DefaultLoginCoordinator \(#function)")
        self.signInViewModel = SignInViewModel(coordinator: self)
    }
    
    func moveLogin() {
        signInViewController.viewModel = signInViewModel
        navigationController.viewControllers = [signInViewController]
    }
    
    func moveSignUp() {
        
    }
    
    func moveMain() {
        
    }
    
  
    
}
