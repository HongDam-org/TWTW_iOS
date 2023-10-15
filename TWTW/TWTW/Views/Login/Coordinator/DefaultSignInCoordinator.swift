//
//  DefaultLoginCoordinator.swift
//  TWTW
//
//  Created by 정호진 on 10/9/23.
//

import Foundation
import UIKit

/// 로그인 관리하는 Coordinator
final class DefaultSignInCoordinator: SignInCoordinatorProtocol {
    
    var childCoordinators: [Coordinator] = []
    
    var delegate: SignInCoordinatorFinishDelegate?
    var navigationController: UINavigationController
    private let signInViewController: SignInViewController
    private var signInViewModel: SignInViewModel?
    private let output: SignInViewModel.Output
    
    init( navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.signInViewController = SignInViewController()
        output = signInViewModel?.createOutput() ?? SignInViewModel.Output()
        self.signInViewModel = SignInViewModel(coordinator: self,
                                               signInServices: SignInService())
    }
    
    func start() {
        print("Called DefaultSignInCoordinator \(#function)")

        signInViewModel?.checkSavingTokens(output: output)
    }
    
    /// 로그인 페이지로 이동
    func moveLogin() {
        print(#function)
        signInViewController.viewModel = signInViewModel
        signInViewController.output = output
        navigationController.viewControllers = [signInViewController]
    }
    
    /// 회원가입 페이지로 이동
    func moveSignUp() {
        let defaultSignUpCoordinator = DefaultSignUpCoordinator(navigationController: navigationController)
        defaultSignUpCoordinator.delegate = self
        defaultSignUpCoordinator.start()
        childCoordinators.append(defaultSignUpCoordinator)
    }
    
    /// 로그인 완료된 경우
    func moveMain() {
        delegate?.finishLogin(self)
    }
    
  
    
}

extension DefaultSignInCoordinator: SignUpCoordinatorFinishDelegate {
    func finishSignUp() {
        moveMain()
    }
}
