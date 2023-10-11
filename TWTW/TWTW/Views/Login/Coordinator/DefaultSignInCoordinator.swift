//
//  DefaultLoginCoordinator.swift
//  TWTW
//
//  Created by 정호진 on 10/9/23.
//

import Foundation
import UIKit

final class DefaultSignInCoordinator: SignInCoordinatorProtocol {
    
    var childCoordinators: [Coordinator] = []
    
    var delegate: SignInCoordinatorFinishDelegate?
    var navigationController: UINavigationController
    private let signInViewController: SignInViewController
    private var signInViewModel: SignInViewModel?
    
    init( navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.signInViewController = SignInViewController()
        self.signInViewModel = SignInViewModel(coordinator: self)
    }
    
    func start() {
        print("Called DefaultLoginCoordinator \(#function)")
        signInViewModel?.checkSavingTokens()
    }
    
    /// 로그인 페이지로 이동
    func moveLogin() {
        print(#function)
        signInViewController.viewModel = signInViewModel
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
