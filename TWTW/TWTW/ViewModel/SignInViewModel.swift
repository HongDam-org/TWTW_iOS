//
//  SignInViewModel.swift
//  TWTW
//
//  Created by 정호진 on 2023/08/06.
//

import Foundation
import RxSwift
import RxRelay
import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon

/// 로그인 ViewModel
final class SignInViewModel {
    private let disposeBag = DisposeBag()
    private let signInServices = SignInService()
    
    var nickName: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var phoneNumber: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    /// MARK: Kakao UserId, Apple: UserIdentifier
    var identifier: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    /// Kakao 로그인 or Apple 로그인
    var authType: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    // MARK: - API Connect
    
    /// 카카오 로그인
    func kakaoLogin() -> Observable<KakaoSDKUser.User>{
        return signInServices.kakaoLogin() //Observable을 그대로 리턴
    }

    /// 자동 로그인 통신
    func checkKakaoOAuthToken() -> Observable<KakaoSDKUser.User>{
        return signInServices.checkKakaoOAuthToken()
    }
    
    
    /// 회원가입할 떄 호출
    /// - Returns: 회원 상태, AccesToken, RefreshToken
    func signUp() -> Observable<LoginResponse>{
        let loginRequest = LoginRequest(nickname: nickName.value,
                                        phoneNumber: phoneNumber.value, 
                                        profileImage: nil,
                                        oauthRequest: OAuthRequest(token: identifier.value,
                                                                   authType: authType.value))
        
        return signInServices.signUpService(request: loginRequest)
    }
    
    /// AccessToken 재발급할 때 사용
    /// - Returns: New AccesToken, New RefreshToken
    func getNewAccessToken() -> Observable<TokenResponse> {
        let accessToken = KeychainWrapper.loadString(forKey: SignIn.accessToken.rawValue)
        let refreshToken = KeychainWrapper.loadString(forKey: SignIn.refreshToken.rawValue)
        
        return signInServices.getNewAccessToken(token: TokenResponse(accessToken: accessToken,
                                                                     refreshToken: refreshToken))
    }
    
    /// 로그인 API
    /// - Returns: status, Tokens
    func signInService() -> Observable<LoginResponse> {
        return signInServices.signInService(request: OAuthRequest(token: identifier.value,
                                                                  authType: authType.value))
    }
}
