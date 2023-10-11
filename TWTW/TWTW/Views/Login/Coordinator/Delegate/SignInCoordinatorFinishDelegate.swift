//
//  CoordinatorFinishDelegate.swift
//  TWTW
//
//  Created by 정호진 on 10/10/23.
//

import Foundation

/// 로그인 종료 신호 보내는 Delegate
protocol SignInCoordinatorFinishDelegate {
    func finishLogin(_ coordinator: DefaultSignInCoordinator)
}
