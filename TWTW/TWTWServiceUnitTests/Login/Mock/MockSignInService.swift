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
        return Observable.create { observer in
            return Disposables.create()
        }
    }
    
    func fetchKakaoUserInfo() -> Observable<KakaoSDKUser.User> {
        return Observable.create { observer in
            return Disposables.create()
        }
    }
    
    func getNewAccessToken(token: TokenResponse) -> Observable<TokenResponse> {
        return Observable.create { observer in
            observer.onNext(TokenResponse(accessToken: "abc", refreshToken: "def"))
            observer.onNext(TokenResponse(accessToken: "abcvv", refreshToken: "defvv"))
            return Disposables.create()
        }
    }
    
    func signInService(request: OAuthRequest) -> Observable<LoginResponse> {
        return Observable.create { observer in
            observer.onNext(LoginResponse(status: "SIGNUP", tokenDto: TokenResponse(accessToken: "abc", refreshToken: "def")))
            observer.onNext(LoginResponse(status: "SIGNIN", tokenDto: TokenResponse(accessToken: "abc11", refreshToken: "def22")))
            return Disposables.create()
        }
    }
    
    func checkAccessTokenValidation() -> Observable<Void> {
        let error = NSError()
        return Observable.create { observer in
            observer.onNext(())
            observer.onError(error)
            return Disposables.create()
        }
    }
    
    
}
