//
//  SignInViewModel.swift
//  TWTW
//
//  Created by 정호진 on 2023/08/06.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser
import RxCocoa
import RxRelay
import RxSwift
import UIKit

/// 로그인 ViewModel
final class SignInViewModel {
    var coordinator: SignInCoordinatorProtocol?
    private let disposeBag = DisposeBag()
    private var signInServices: SignInProtocol?
    
    struct Input {
        let kakaoLoginButtonTapped: Observable<ControlEvent<UITapGestureRecognizer>.Element>
    }
    
    struct Output {
        var checkAccessTokenValidation: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        var checkGetNewAccessToken: BehaviorRelay<TokenResponse?> = BehaviorRelay(value: nil)
        var checkSignInService: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    }
    
    // MARK: - init
    init(coordinator: SignInCoordinatorProtocol?, signInServices: SignInProtocol) {
        self.coordinator = coordinator
        self.signInServices = signInServices
    }
    
    // MARK: - Functions
    
    /// 저장된 토큰 확인
    func checkSavingTokens(output: Output) {
//        _ = KeychainWrapper.delete(key: SignIn.accessToken.rawValue)
//        _ = KeychainWrapper.delete(key: SignIn.refreshToken.rawValue)
        
        if KeychainWrapper.loadItem(forKey: SignIn.accessToken.rawValue) != nil,
           KeychainWrapper.loadItem(forKey: SignIn.refreshToken.rawValue) != nil {
            return checkAccessTokenValidation(output: output)
        }
        // SignInViewController 이동
        coordinator?.moveSignIn()
    }
    
    /// binding Input
    /// - Parameter input: Input 구조체
    func bind(input: Input, output: Output) {
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
    func kakaoLogin(output: Output) {
        signInServices?.kakaoLogin()
            .subscribe(onNext: { [weak self] kakaoUserInfo in
                guard let self = self else {return}
                signInService(authType: AuthType.kakao.rawValue, identifier: "\(kakaoUserInfo.id ?? 0)", output: output)
            })
            .disposed(by: disposeBag)
        
    }
    
    /// Access Token 유효성 검사
    func checkAccessTokenValidation(output: Output) {
        signInServices?.checkAccessTokenValidation()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                // MeetingListViewController로 이동
                output.checkAccessTokenValidation.accept(true)
                coordinator?.moveMain()
            }, onError: { [weak self] error in
                guard let self = self else {return}
                print(#function)
                print(error)
                output.checkAccessTokenValidation.accept(false)
                getNewAccessToken(output: output)
            })
            .disposed(by: disposeBag)
    }
    
    /// AccessToken 재발급할 때 사용
    func getNewAccessToken(output: Output) {
        let accessToken = KeychainWrapper.loadItem(forKey: SignIn.accessToken.rawValue)
        let refreshToken = KeychainWrapper.loadItem(forKey: SignIn.refreshToken.rawValue)
        
        signInServices?.getNewAccessToken(token: TokenResponse(accessToken: "\(String(describing: accessToken))",
                                                               refreshToken: "\(String(describing: refreshToken))"))
            .subscribe(onNext: { [weak self] data in // 재발급 성공
                guard let self = self else {return}
                if let access = data.accessToken, let refresh = data.refreshToken {
                    if KeychainWrapper.saveItem(value: access, forKey: SignIn.accessToken.rawValue) &&
                        KeychainWrapper.saveItem(value: refresh, forKey: SignIn.refreshToken.rawValue) {
                        // move MeetingListViewController
                        output.checkGetNewAccessToken.accept(TokenResponse(accessToken: "\(String(describing: accessToken))",
                                                                           refreshToken: "\(String(describing: refreshToken))"))
                        coordinator?.moveMain()
                    }
                }
            }, onError: { [weak self] error in   // Refresh 토큰 까지 만료된 경우
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
        _ = KeychainWrapper.saveItem(value: authType, forKey: SignInSaveKeyChain.authType.rawValue)
        _ = KeychainWrapper.saveItem(value: identifier, forKey: SignInSaveKeyChain.identifier.rawValue)
        
        signInServices?.signInService(request: OAuthRequest(token: identifier,
                                                           authType: authType))
            .subscribe(onNext: { [weak self] data in
                guard let self = self else {return}
                if KeychainWrapper.saveItem(value: data.tokenDto?.accessToken ?? "", forKey: SignIn.accessToken.rawValue) &&
                    KeychainWrapper.saveItem(value: data.tokenDto?.refreshToken ?? "", forKey: SignIn.refreshToken.rawValue) {
                    
                    output.checkSignInService.accept(data.status)
                    guard let status = data.status else {return}
                    switch status {
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
