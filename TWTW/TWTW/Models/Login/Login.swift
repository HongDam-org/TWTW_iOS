//
//  Login.swift
//  TWTW
//
//  Created by 정호진 on 2023/09/21.
//

import Foundation

struct LoginResponse: Codable {
    let accessToken: String?
    let refreshToken: String?
}

struct LoginRequest: Codable {
    let nickname: String?
    let phoneNumber: String?
    let oauthRequest: OAuthRequest?
}

struct OAuthRequest: Codable {
    let token: String?
    let authType: String?
}
