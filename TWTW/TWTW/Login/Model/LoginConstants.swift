//
//  Apple.swift
//  TWTW
//
//  Created by 정호진 on 2023/09/21.
//

import Foundation

/// 로그인 정보
enum SignIn: String{
    case accessToken = "AccessToken"
    case refreshToken = "RefreshToken"
}

/// 로그인 상태 (회원유무)
enum LoginStatus: String {
    case signUp = "SIGNUP"
    case signIn = "SIGNIN"
}

/// 사용자 로그인한 종류
enum AuthType: String {
    case kakao = "KAKAO"
    case apple = "APPLE"
}

enum SignInSaveKeyChain: String {
    case authType
    case identifier
}

/// 로그인할 때 사용할 변수
enum LoginImageTitle: String {
    case photo = "add_a_photo"
    case profile
}

