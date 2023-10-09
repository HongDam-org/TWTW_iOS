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
final class SignInService{
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
            } else {
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
            }
            
            return Disposables.create()
        }
    }
    
    /// 카카오 사용자 정보 불러오기
    func fetchKakaoUserInfo() -> Observable<KakaoSDKUser.User>{
        return UserApi.shared.rx.me().asObservable()
            .do(onNext: { user in
                print("fetchKakaoUserInfo \n\(user)")
            }, onError: { error in
                print("fetchKakaoUserInfo error!\n\(error)")
            })
    }
    
    /// 카카오 OAuth 확인하는 함수
    func checkKakaoOAuthToken() -> Observable<KakaoSDKUser.User>{
        return Observable.create { [weak self] observer in
            if (AuthApi.hasToken()) {   // 카카오 토큰이 있는지 확인
                UserApi.shared.rx.accessTokenInfo()
                    .subscribe(
                        onSuccess: { (AccessTokenInfo) in   // Access
                            self?.fetchKakaoUserInfo()
                                .subscribe(onNext:{ kakakUserInfo in
                                    observer.onNext(kakakUserInfo)
                                })
                                .disposed(by: self?.disposeBag ?? DisposeBag())
                        },
                        onFailure: { error in   // Access Token, Refresh Token 만료된 상황
                            if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true {
                                if sdkError.isApiFailed{
                                    print("Kakao Token Error!\n\(sdkError.getApiError())")
                                }
                                else if sdkError.isAuthFailed{
                                    print("Kakao Token Error!\n\(sdkError.getAuthError())")
                                }
                                else if sdkError.isClientFailed{
                                    print("Kakao Token Error!\n\(sdkError.getClientError())")
                                }
                            }
                            else { // 이상한 오류 발생
                                print("Kakao Token Error!!\n\(error)")
                            }
                        })
                    .disposed(by: self?.disposeBag ?? DisposeBag())
            }
            return Disposables.create()
        }
    }
    
    
    
    /// AccessToken 재발급할 때 사용
    /// - Parameter token: AccessToken, RefreshToken
    /// - Returns: New AccesToken, New RefreshToken
    func getNewAccessToken(token: TokenResponse) -> Observable<TokenResponse> {
        let url = Domain.REST_API + LoginPath.updateToken
        print(url)
        return Observable.create { observer in
            AF.request(url,
                       method: .post,
                       parameters: token,
                       encoder: JSONParameterEncoder.default)
            .validate { request, response, data in
                if 200..<201 ~= response.statusCode {
                    return .success(())
                } else if response.statusCode == 401 {
                    return .failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: response.statusCode)))
                } else {
                    return .failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: response.statusCode)))
                }
            }
            .responseDecodable(of: TokenResponse.self) { response in
                switch response.result {
                case .success(let data):
                    observer.onNext(data)
                case .failure(let error):
                    if let statusCodeError = error as? AFError,
                       case .responseValidationFailed(let reason) = statusCodeError,
                       case .unacceptableStatusCode(let code) = reason {
                        if code == 400 {
                            observer.onNext(TokenResponse(accessToken: nil, refreshToken: nil))
                        }
                        else {
                            observer.onError(error)
                        }
                    }
                    else {
                        observer.onError(error)
                    }
                }
                
                
            }
            
            return Disposables.create()
        }
    }
    
    /// 회원가입할 떄 호출
    /// - Parameter request: 서버에 보내는 회원가입 정보
    /// - Returns: 회원 상태, AccesToken, RefreshToken
    func signUpService(request: LoginRequest) -> Observable<LoginResponse> {
        let url = Domain.REST_API + LoginPath.signUp
        print(url)
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
    
    /// 로그인 API
    /// - Parameter request: Kakao, Apple에서 발급받는 Token, AuthType
    /// - Returns: status, Tokens
    func signInService(request: OAuthRequest) -> Observable<LoginResponse> {
        let url = Domain.REST_API + LoginPath.signIn
        print(url)
        print("body\n\(request)")
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
    func checkAccessTokenValidation() -> Observable<Bool> {
        let url = Domain.REST_API + LoginPath.checkValidation
        let accessToken = KeychainWrapper.loadString(forKey: SignIn.accessToken.rawValue) ?? ""
        print(url)
        return Observable.create { observer in
            AF.request(url,
                       method: .get,
                       headers: ["Authorization": "Bearer \(accessToken)"])
            .validate(statusCode: 204..<205)
            .response{ res in
                switch res.result{
                case .success(_):
                    observer.onNext(true)
                case .failure(let error):
                    print(#function)
                    print(error)
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
        
    }
    
    /// ID 중복 검사
    /// - Returns: true: Id 사용가능, false: 중복
    func checkOverlapId(id: String) -> Observable<Void> {
        var url = Domain.REST_API + LoginPath.checkOverlapId
        url = url.replacingOccurrences(of: "Id", with: id)
        print(url)
        
        return Observable.create { observer in
            AF.request(url,
                       method: .get)
            .validate(statusCode: 200..<201)
            .response{ res in
                print(res)
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
