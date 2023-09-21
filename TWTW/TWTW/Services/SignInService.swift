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
    
    
    func sendingLoginInfoToServer() -> Observable<Login> {
        let url = Domain.REST_API + LoginPath.login
        let body: Parameters = [
        
        ]
        return Observable.create { observer in
            AF.request(url,
                       method: .post,
                       parameters: body,
                       encoding: JSONEncoding.default)
            .responseDecodable(of: Login.self) { response in
                
            }
            
            return Disposables.create()
        }
    }
    
}
