//
//  SignUpProtocol.swift
//  TWTW
//
//  Created by 정호진 on 10/15/23.
//

import Foundation
import RxSwift

protocol SignUpProtocol {
    /// 회원가입할 떄 호출
    /// - Parameter request: 서버에 보내는 회원가입 정보
    /// - Returns: 회원 상태, AccesToken, RefreshToken
    func signUpService(request: LoginRequest) -> Observable<LoginResponse>
    
    /// ID 중복 검사
    /// - Parameter id: nickName
    func checkOverlapId(id: String) -> Observable<Bool>
}
