//
//  SignInService.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/06.
//
import Foundation
import RxSwift
import KakaoSDKUser
import RxKakaoSDKUser
import RxRelay
import KakaoSDKAuth
import KakaoSDKCommon
import Alamofire

/// 로그인 Service
final class SignInService: SignInProtocol{
    private let disposeBag = DisposeBag()
    
    /// 카카오 로그인
    func kakaoLogin() -> Observable<KakaoSDKUser.User> {
        return Observable.create { [weak self] observer in
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.rx.loginWithKakaoTalk()
                    .flatMap { _ in self?.fetchKakaoUserInfo() ?? .empty() }
                    .subscribe(
                        onNext: { userInfo in
                            observer.onNext(userInfo)
                            observer.onCompleted()
                        },
                        onError: { error in
                            observer.onError(error)
                        }
                    )
                    .disposed(by: self?.disposeBag ?? DisposeBag())
                return Disposables.create()
            }
            
            UserApi.shared.rx.loginWithKakaoAccount()
                .flatMap { _ in self?.fetchKakaoUserInfo() ?? .empty() }
                .subscribe(
                    onNext: { userInfo in
                        observer.onNext(userInfo)
                    },
                    onError: { error in
                        print("loginWithKakaoAccount() error: \(error)")
                    }
                )
                .disposed(by: self?.disposeBag ?? DisposeBag())
            return Disposables.create()
        }
    }
    
    /// 카카오 사용자 정보 불러오기
    func fetchKakaoUserInfo() -> Observable<KakaoSDKUser.User> {
        return UserApi.shared.rx.me().asObservable()
            .do(onNext: { user in
                print("fetchKakaoUserInfo \n\(user)")
            }, onError: { error in
                print("fetchKakaoUserInfo error!\n\(error)")
            })
    }
    
    
    /// AccessToken 재발급할 때 사용
    /// - Parameter token: AccessToken, RefreshToken
    /// - Returns: New AccesToken, New RefreshToken
    func getNewAccessToken(token: TokenResponse) -> Observable<TokenResponse> {
        let url = Domain.RESTAPI + LoginPath.updateToken.rawValue
        print(#function)
        print(url)
        return Observable.create { observer in
            AF.request(url,
                       method: .post,
                       parameters: token,
                       encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200..<201)
            .responseDecodable(of: TokenResponse.self) { response in
                switch response.result {
                case .success(let data):
                    observer.onNext(data)
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    
    /// 로그인 API
    /// - Parameter request: Kakao, Apple에서 발급받는 Token, AuthType
    /// - Returns: status, Tokens
    func signInService(request: OAuthRequest) -> Observable<LoginResponse> {
        let url = Domain.RESTAPI + LoginPath.signIn.rawValue
        print(#function)
        print(url)
        print(request)
        return Observable.create { observer in
            AF.request(url,
                       method: .post,
                       parameters: request,
                       encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200..<201)
            .responseDecodable(of: LoginResponse.self) { response in
                switch response.result {
                case .success(let data):
                    observer.onNext(data)
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    
    /// Access Token 유효성 검사
    /// - Returns: true: AccessToken 유효, false: 만료
    func checkAccessTokenValidation() -> Observable<Void> {
        let url = Domain.RESTAPI + LoginPath.checkValidation.rawValue
        let header = Header.header.getHeader()
        
        print(#function)
        print(url)
        
        return Observable.create { observer in
            AF.request(url,
                       method: .get,
                       headers: header)
            .validate(statusCode: 204..<205)
            .response{ res in
                switch res.result{
                case .success(_):
                    observer.onNext(())
                case .failure(let error):
                    print(#function)
                    print(error)
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
        
    }
    
    
}
