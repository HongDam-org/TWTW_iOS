//
//  DefaultSignUpCoordinator.swift
//  TWTW
//
//  Created by 정호진 on 10/9/23.
//

import Foundation
import UIKit

final class DefaultSignUpCoordinator: SignUpCoordinatorProtocol {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var delegate: SignUpCoordinatorFinishDelegate?
    
    private var signUpViewController: SignUpViewController
    private var signUpViewModel: SignUpViewModel?
    
    // MARK: - init
    init( navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.signUpViewController = SignUpViewController()
        signUpViewModel = SignUpViewModel(coordinator: self)
    }
    
    func start() {
        moveSignUp()
    }
    
    func moveMain() {
        delegate?.finishSignUp()
    }
    
    func moveSignUp() {
        signUpViewController.viewModel = signUpViewModel
        navigationController.pushViewController(signUpViewController, animated: true)
    }
    
}
