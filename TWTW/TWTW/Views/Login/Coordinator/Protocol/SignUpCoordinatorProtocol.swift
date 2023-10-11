//
//  SignUpCoordinatorProtocol.swift
//  TWTW
//
//  Created by 정호진 on 10/10/23.
//

import Foundation

/// 회원가입 Protocol
protocol SignUpCoordinatorProtocol: Coordinator {
    func moveMain()
    func moveSignUp()
}
