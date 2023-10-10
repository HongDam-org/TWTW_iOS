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
import RxCocoa

/// 로그인 ViewModel
///  Singleton
final class SignInViewModel {
    var coordinator: LoginCoordinatorProtocol?
    private let disposeBag = DisposeBag()
    private let signInServices = SignInService()

    
    // MARK: - init
    
    init(coordinator: LoginCoordinatorProtocol) {
        self.coordinator = coordinator
        
    }
    
    struct Input {
        let kakaoLoginButtonTapped: Observable<ControlEvent<UITapGestureRecognizer>.Element>
    }
    
    // MARK: - Functions
    
    /// MARK: 저장된 토큰 확인
    func checkSavingTokens(){
        let _ = KeychainWrapper.delete(key: SignIn.accessToken.rawValue)
        let _ = KeychainWrapper.delete(key: SignIn.refreshToken.rawValue)
        if let accessToken = KeychainWrapper.loadString(forKey: SignIn.accessToken.rawValue),
            let refreshToken = KeychainWrapper.loadString(forKey: SignIn.refreshToken.rawValue){
            
            checkAccessTokenValidation()
        }
        else{
            //SignInViewController 이동
            coordinator?.moveLogin()
        }
    }
    
    /// MARK: binding Input
    func bind(input: Input){
        input.kakaoLoginButtonTapped.bind { [weak self] _ in
            guard let self = self else {return}
            print("called kakaoLogin")
            kakaoLogin()
        }
        .disposed(by: disposeBag)
    }
    
    // MARK: - API Connect
    
    /// 카카오 로그인
    func kakaoLogin(){
        signInServices.kakaoLogin()
            .subscribe(onNext:{ [weak self] kakaoUserInfo in
                guard let self = self else {return}
                signInService(authType: AuthType.kakao.rawValue, identifier: "\(kakaoUserInfo.id ?? 0)")
            })
            .disposed(by: disposeBag)
        
    }

    /// 자동 로그인 통신
    func checkKakaoOAuthToken() -> Observable<KakaoSDKUser.User>{
        return signInServices.checkKakaoOAuthToken()
    }
    
    /// Access Token 유효성 검사
    func checkAccessTokenValidation() {
        signInServices.checkAccessTokenValidation()
            .subscribe(onNext:{ [weak self] _ in
                guard let self = self else {return}
                // MeetingListViewController로 이동
                coordinator?.moveMain()
            },onError: { [weak self] error in
                guard let self = self else {return}
                print(#function)
                print(error)
                
                getNewAccessToken()
            })
            .disposed(by: disposeBag)
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
                        coordinator?.moveMain()
                    }
                }
            },onError: { [weak self] error in   // Refresh 토큰 까지 만료된 경우
                guard let self = self else {return}
                print("\(#function) error!\n\(error)")
                coordinator?.moveLogin()
            })
            .disposed(by: disposeBag)
    }
 
    /// 로그인 API
    func signInService(authType: String, identifier: String) {
        let _ = KeychainWrapper.saveString(value: authType, forKey: SignInSaveKeyChain.authType.rawValue)
        let _ = KeychainWrapper.saveString(value: identifier, forKey: SignInSaveKeyChain.identifier.rawValue)
        signInServices.signInService(request: OAuthRequest(token: identifier,
                                                           authType: authType))
            .subscribe(onNext:{ [weak self] data in
                guard let self = self else {return}
                if KeychainWrapper.saveString(value: data.tokenDto?.accessToken ?? "", forKey: SignIn.accessToken.rawValue) && 
                    KeychainWrapper.saveString(value: data.tokenDto?.refreshToken ?? "", forKey: SignIn.refreshToken.rawValue) {
                    switch (data.status ?? "") {
                    case LoginStatus.SignIn.rawValue:
                        coordinator?.moveMain()
                    case LoginStatus.SignUp.rawValue:
                        coordinator?.moveSignUp()
                    default:
                        print("잘못된 접근")
                    }
                    
                }
            }, onError: { error in
                print("\(#function) error! \n\(error)")
            })
            .disposed(by: disposeBag)
        
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
