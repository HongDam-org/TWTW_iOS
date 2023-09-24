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
    
    func sendingLoginInfoToServer() -> Observable<LoginResponse>{
        print(nickName.value)
        
        let loginRequest = LoginRequest(nickname: nickName.value,
                                        phoneNumber: phoneNumber.value,
                                        oauthRequest: OAuthRequest(token: identifier.value,
                                                                   authType: authType.value))
        
        return signInServices.sendingLoginInfoToServer(request: loginRequest)
    }
        
}
