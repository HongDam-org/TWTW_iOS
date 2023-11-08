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
final class SignInViewModel {
    var coordinator: SignInCoordinatorProtocol?
    private let disposeBag = DisposeBag()
    private var signInServices: SignInProtocol?

    
    // MARK: - init
    
    init(coordinator: SignInCoordinatorProtocol?, signInServices: SignInProtocol) {
        self.coordinator = coordinator
        self.signInServices = signInServices
    }
    
    struct Input {
        let kakaoLoginButtonTapped: Observable<ControlEvent<UITapGestureRecognizer>.Element>
    }
    
    struct Output {
        var checkAccessTokenValidation: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        var checkGetNewAccessToken: BehaviorRelay<TokenResponse?> = BehaviorRelay(value: nil)
        var checkSignInService: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    }
    
    // MARK: - Functions
    
    /// MARK: 저장된 토큰 확인
    func checkSavingTokens(output: Output){
        if let _ = KeychainWrapper.loadString(forKey: SignIn.accessToken.rawValue),
            let _ = KeychainWrapper.loadString(forKey: SignIn.refreshToken.rawValue){
            return checkAccessTokenValidation(output: output)
        }
        //SignInViewController 이동
        coordinator?.moveSignIn()    
    }
    
    /// MARK: binding Input
    /// - Parameter input: Input 구조체
    func bind(input: Input, output: Output){
        input.kakaoLoginButtonTapped.bind { [weak self] _ in
            guard let self = self else {return}
            print("called kakaoLogin")
            kakaoLogin(output: output)
        }
        .disposed(by: disposeBag)
    }
    
    func createOutput() -> Output {
        let output = Output()
        return output
    }
    
    // MARK: - API Connect
    
    /// 카카오 로그인
    func kakaoLogin(output: Output){
        signInServices?.kakaoLogin()
            .subscribe(onNext:{ [weak self] kakaoUserInfo in
                guard let self = self else {return}
                signInService(authType: AuthType.kakao.rawValue, identifier: "\(kakaoUserInfo.id ?? 0)", output: output)
            })
            .disposed(by: disposeBag)
        
    }
    
    /// Access Token 유효성 검사
    func checkAccessTokenValidation(output: Output) {
        signInServices?.checkAccessTokenValidation()
            .subscribe(onNext:{ [weak self] _ in
                guard let self = self else {return}
                // MeetingListViewController로 이동
                output.checkAccessTokenValidation.accept(true)
                coordinator?.moveMain()
            },onError: { [weak self] error in
                guard let self = self else {return}
                print(#function)
                print(error)
                output.checkAccessTokenValidation.accept(false)
                getNewAccessToken(output: output)
            })
            .disposed(by: disposeBag)
    }
    
    /// AccessToken 재발급할 때 사용
    func getNewAccessToken(output: Output){
        let accessToken = KeychainWrapper.loadString(forKey: SignIn.accessToken.rawValue)
        let refreshToken = KeychainWrapper.loadString(forKey: SignIn.refreshToken.rawValue)
        
        signInServices?.getNewAccessToken(token: TokenResponse(accessToken: accessToken, refreshToken: refreshToken))
            .subscribe(onNext:{ [weak self] data in // 재발급 성공
                guard let self = self else {return}
                if let access = data.accessToken, let refresh = data.refreshToken {
                    if KeychainWrapper.saveString(value: access, forKey: SignIn.accessToken.rawValue) && KeychainWrapper.saveString(value: refresh, forKey: SignIn.refreshToken.rawValue){
                        // move MeetingListViewController
                        output.checkGetNewAccessToken.accept(TokenResponse(accessToken: accessToken, refreshToken: refreshToken))
                        coordinator?.moveMain()
                    }
                }
            },onError: { [weak self] error in   // Refresh 토큰 까지 만료된 경우
                guard let self = self else {return}
                print("\(#function) error!\n\(error)")
                output.checkGetNewAccessToken.accept(nil)
                coordinator?.moveSignIn()
            })
            .disposed(by: disposeBag)
    }
 
    /// 로그인 API
    /// - Parameters:
    ///   - authType: 인증 방식 ex)카카오, 애플
    ///   - identifier: 유저 고유의 identifier
    func signInService(authType: String, identifier: String, output: Output) {
        let _ = KeychainWrapper.saveString(value: authType, forKey: SignInSaveKeyChain.authType.rawValue)
        let _ = KeychainWrapper.saveString(value: identifier, forKey: SignInSaveKeyChain.identifier.rawValue)
        
        signInServices?.signInService(request: OAuthRequest(token: identifier,
                                                           authType: authType))
            .subscribe(onNext:{ [weak self] data in
                guard let self = self else {return}
                if KeychainWrapper.saveString(value: data.tokenDto?.accessToken ?? "", forKey: SignIn.accessToken.rawValue) && 
                    KeychainWrapper.saveString(value: data.tokenDto?.refreshToken ?? "", forKey: SignIn.refreshToken.rawValue) {
                    
                    output.checkSignInService.accept(data.status)
                    switch (data.status ?? "") {
                    case LoginStatus.signIn.rawValue:
                        coordinator?.moveMain()
                    case LoginStatus.signUp.rawValue:
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
