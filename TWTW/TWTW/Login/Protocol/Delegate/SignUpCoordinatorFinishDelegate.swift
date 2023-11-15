//
//  SignUpCoordinatorFinishDelegate.swift
//  TWTW
//
//  Created by 정호진 on 10/10/23.
//

import Foundation

/// 회원가입 종료 신호 보내는 Delegate
protocol SignUpCoordinatorFinishDelegate: AnyObject {
    func finishSignUp()
}
