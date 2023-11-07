//
//  LoginCoordinatorProtocol.swift
//  TWTW
//
//  Created by 정호진 on 10/10/23.
//

import Foundation

/// 로그인 Protocol
protocol SignInCoordinatorProtocol: Coordinator {
    func moveSignIn()
    func moveSignUp()
    func moveMain()
}
