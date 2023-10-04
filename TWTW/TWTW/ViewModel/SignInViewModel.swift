//
//  SignInViewModel.swift
//  TWTW
//
//  Created by 정호진 on 2023/08/06.
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon

/// 로그인 ViewModel
///  Singleton
final class SignInViewModel {
    static let shared = SignInViewModel()
    private init() {}
    private let disposeBag = DisposeBag()
    private let signInServices = SignInService()
    final let maxLength = 8
    final let minLength = 2
    
    /// MARK: Kakao UserId, Apple: UserIdentifier
    var identifier: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    /// Kakao 로그인 or Apple 로그인
    var authType: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    /// 선택한 이미지들
    var selectedPhotoImages: BehaviorRelay<UIImage> = BehaviorRelay(value: UIImage(resource: .profile))
    
    /// 사용자가 지정한 닉네임
    var nickName: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    
    
    // MARK: - Functions
    
    /// MARK: textField 글자수 계산해서 최대 글자수 넘는 경우 입력 막기
    func calculateTextField(text: String, string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        guard text.count < maxLength else { return false }
        return true
    }
    
    /// MARK: 글자수 확인
    func checkTextFieldTextCount(text: String) -> Bool {
        if text.count >= minLength && text.count <= maxLength {
            return true
        }
        else{
            return false
        }
    }
    
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
    
    /// Access Token 유효성 검사
    /// - Returns: true: AccessToken 유효, false: 만료
    func checkAccessTokenValidation() -> Observable<Bool> {
        return signInServices.checkAccessTokenValidation()
    }
}
