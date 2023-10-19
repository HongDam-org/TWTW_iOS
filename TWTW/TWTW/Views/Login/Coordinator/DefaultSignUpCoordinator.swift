//
//  DefaultSignUpCoordinator.swift
//  TWTW
//
//  Created by 정호진 on 10/9/23.
//

import Foundation
import UIKit

/// 회원가입 관리하는 Coordinator
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
        signUpViewModel = SignUpViewModel(coordinator: self,
                                          signUpServices: SignUpService())
    }
    
    func start() {
        moveSignUp()
    }
    
    /// 회원가입 완료
    func moveMain() {
        delegate?.finishSignUp()
    }
    
    /// 회원가입으로 이동
    func moveSignUp() {
        signUpViewController.viewModel = signUpViewModel
        navigationController.pushViewController(signUpViewController, animated: true)
    }
    
}
