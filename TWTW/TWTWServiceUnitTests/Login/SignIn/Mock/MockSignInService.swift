//
//  MockSignInService.swift
//  TWTW
//
//  Created by 정호진 on 10/14/23.
//

import Foundation
import RxSwift
import KakaoSDKAuth
import KakaoSDKUser

final class MockSignInService: SignInProtocol {

    func kakaoLogin() -> Observable<KakaoSDKUser.User> {
        return Observable.create { _ in
            return Disposables.create()
        }
    }

    func fetchKakaoUserInfo() -> Observable<KakaoSDKUser.User> {
        return Observable.create { _ in
            return Disposables.create()
        }
    }

    func getNewAccessToken(token: TokenResponse) -> Observable<TokenResponse> {
        return Observable.create { observer in
            observer.onNext(TokenResponse(accessToken: "abc", refreshToken: "def"))
            observer.onNext(TokenResponse(accessToken: "abcvv", refreshToken: "defvv"))
            observer.onError(NSError(domain: "not connect", code: 500, userInfo: nil))
            return Disposables.create()
        }
    }

    func signInService(request: OAuthRequest) -> Observable<LoginResponse> {
        return Observable.create { observer in
//            observer.onNext(LoginResponse(status: "SIGNUP", 
//                                          tokenDto: TokenResponse(accessToken: "abc",
//                                                                  refreshToken: "def")))
            observer.onNext(LoginResponse(status: "SIGNIN",
                                          tokenDto: TokenResponse(accessToken: "abc11",
                                                                  refreshToken: "def22")))

//            observer.onError(NSError(domain: "not connect", code: 500, userInfo: nil))
            return Disposables.create()
        }
    }

    func checkAccessTokenValidation() -> Observable<Void> {
        return Observable.create { observer in
//            observer.onNext(())
            observer.onError(NSError(domain: "inValid Token", code: 400, userInfo: nil))
            return Disposables.create()
        }
    }
}
