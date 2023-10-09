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
    weak var coordinator: LoginCoordinatorProtocol?
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
    
    
    init(coordinator: LoginCoordinatorProtocol) {
        self.coordinator = coordinator
        checkSavingTokens()
    }
    
    
    
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
    
    /// MARK: 저장된 토큰 확인
    private func checkSavingTokens(){
        if let _ = KeychainWrapper.loadString(forKey: SignIn.accessToken.rawValue),
            let _ = KeychainWrapper.loadString(forKey: SignIn.refreshToken.rawValue){
            checkAccessTokenValidation()
        }
        else{
            //SignInViewController 이동
            coordinator?.moveLogin()
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
    
    
    
    /// AccessToken 재발급할 때 사용
    func getNewAccessToken(){
        let accessToken = KeychainWrapper.loadString(forKey: SignIn.accessToken.rawValue)
        let refreshToken = KeychainWrapper.loadString(forKey: SignIn.refreshToken.rawValue)
        
        signInServices.getNewAccessToken(token: TokenResponse(accessToken: accessToken, refreshToken: refreshToken))
            .subscribe(onNext:{ [weak self] data in // 재발급 성공
                guard let self = self else {return}
                if let access = data.accessToken, let refresh = data.refreshToken {
                    if KeychainWrapper.saveString(value: access, forKey: SignIn.accessToken.rawValue) && KeychainWrapper.saveString(value: refresh, forKey: SignIn.refreshToken.rawValue){
                        // move MeetingListViewController
                        
                    }
                }
            },onError: { [weak self] error in   // Refresh 토큰 까지 만료된 경우
                guard let self = self else {return}
                print("\(#function) error!\n\(error)")
                // move SignInViewController
            })
            .disposed(by: disposeBag)
    }
    
    /// Access Token 유효성 검사
    func checkAccessTokenValidation() {
        signInServices.checkAccessTokenValidation()
            .subscribe(onNext:{ [weak self] _ in
                guard let self = self else {return}
                // MeetingListViewController로 이동

            },onError: { [weak self] error in
                guard let self = self else {return}
                print(#function)
                print(error)
                
                getNewAccessToken()
            })
            .disposed(by: disposeBag)
    }
    
    /// 로그인 API
    /// - Returns: status, Tokens
    func signInService() -> Observable<LoginResponse> {
        return signInServices.signInService(request: OAuthRequest(token: identifier.value,
                                                                  authType: authType.value))
    }
    
    
    
    /// ID 중복 검사
    /// - Returns: true: Id 사용가능, false: 중복
    func checkOverlapId() -> Observable<Void> {
      
        return Observable.create { [weak self]  observer in
            guard let self = self  else { fatalError() }
            signInServices.checkOverlapId(id: nickName.value)
                .subscribe(onNext: { _ in
                    observer.onNext(())
                },onError: {  [weak self] error in
                    guard let self = self  else {return}
                    observer.onError(error)
                })
                .disposed(by: disposeBag)
            return Disposables.create()
        }
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
}



/*
 1. AccessToken 유효성 확인
 1.1 AccessToken 만료된 경우 재발급 API 호출 -> 2번으로 진행
 1.2 AccessToken 만료되지 않은 경우 -> 자동 로그인 진행
 2. SignIn 진행
 3. response status가 SignUp인 경우 -> 회원 가입 페이지 이동
 3.1 SignIn인 경우 로그인 끝 -> Main으로 이동
 */
