//
//  SignInProtocol.swift
//  TWTW
//
//  Created by 정호진 on 10/14/23.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser
import RxSwift

protocol SignInProtocol {
    /// 카카오 로그인
    func kakaoLogin() -> Observable<KakaoSDKUser.User>
    
    /// 카카오 사용자 정보 불러오기
    func fetchKakaoUserInfo() -> Observable<KakaoSDKUser.User>
    
    /// AccessToken 재발급할 때 사용
    /// - Parameter token: AccessToken, RefreshToken
    /// - Returns: New AccesToken, New RefreshToken
    func getNewAccessToken(token: TokenResponse) -> Observable<TokenResponse>
    
    /// 로그인 API
    /// - Parameter request: Kakao, Apple에서 발급받는 Token, AuthType
    /// - Returns: status, Tokens
    func signInService(request: OAuthRequest) -> Observable<LoginResponse>
    
    /// Access Token 유효성 검사
    /// - Returns: true: AccessToken 유효, false: 만료
    func checkAccessTokenValidation() -> Observable<Void>
    
    /// update FCM Device Token
    /// - Parameter fcmToken: FCM Token
    func updateFCMDeviceToken(fcmToken: String) -> Observable<Void>
}
