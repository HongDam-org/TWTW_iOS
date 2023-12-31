//
//  MockSignUpService.swift
//  TWTW
//
//  Created by 정호진 on 10/16/23.
//

import Foundation
import RxSwift

final class MockSignUpService: SignUpProtocol {
    func signUpService(request: LoginRequest) -> Observable<LoginResponse> {
        return Observable.create { observer in
            observer.onNext(LoginResponse(status: LoginStatus.signIn.rawValue,
                                          tokenDto: TokenResponse(accessToken: "a", refreshToken: "a")))
            return Disposables.create()
        }
    }

    func checkOverlapId(id: String) -> Observable<Bool> {
        return Observable.create { observer in
            if id.contains("!") || id.contains("@") ||
                id.contains("#") || id.contains("$") ||
                id.contains("%") || id.contains(" ") {
                observer.onNext(false)
                return Disposables.create()
            }

            observer.onNext(true)
            return Disposables.create()
        }
    }
}
