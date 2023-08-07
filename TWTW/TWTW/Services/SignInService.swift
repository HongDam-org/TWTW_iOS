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

/// 로그인 Service
final class SignInService{
    private let disposeBag = DisposeBag()
    
    /// 카카오 로그인
    func kakaoLogin() -> Observable<KakaoSDKUser.User>{
        return Observable.create { [weak self] observer in
            UserApi.shared.rx.loginWithKakaoAccount()
                .flatMap { [weak self] oauthToken -> Observable<KakaoSDKUser.User> in //flatMap중복성 제거
                    self?.fetchKakaoUserInfo() ?? .empty()
                }
            // 토큰 저장 필요
                .subscribe(onNext: { userInfo in
                    observer.onNext(userInfo)
                }, onError: { error in
                    print("loginWithKakaoAccount() error: \(error)")
                })
                .disposed(by: self?.disposeBag ?? DisposeBag())
            
            
            return Disposables.create()
        }
    }
    
    
    
    // 카카오 사용자 정보 불러오기
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
            if (AuthApi.hasToken()) {
                UserApi.shared.rx.accessTokenInfo()
                    .subscribe(
                        onSuccess: { (AccessTokenInfo) in   // Access
                            print("AccessToekn \(AccessTokenInfo)")
                            self?.fetchKakaoUserInfo()
                                .subscribe(onNext:{ kakakUserInfo in
                                    observer.onNext(kakakUserInfo)
                                })
                                .disposed(by: self?.disposeBag ?? DisposeBag())
                        },
                        onFailure: {  error in
                            if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true {
                                // 토큰이 만료된 경우 카카오 로그인 재실행
                                self?.kakaoLogin()
                                    .subscribe(onNext:{ kakakUserInfo in
                                        observer.onNext(kakakUserInfo)
                                    })
                                    .disposed(by: self?.disposeBag ?? DisposeBag())
                            }
                            else { // 이상한 오류? 발생
                                print("Kakao Token Error!\n\(error)")
                            }
                        })
                    .disposed(by: self?.disposeBag ?? DisposeBag())
            } else {
                // 토큰이 없는 경우 카카오 로그인 재실행
                self?.kakaoLogin()
                    .subscribe(onNext: { kakakUserInfo in
                        observer.onNext(kakakUserInfo)
                    })
                    .disposed(by: self?.disposeBag ?? DisposeBag())
            }
            return Disposables.create()
        }
    }
    
    
}
