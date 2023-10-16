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
            observer.onNext(LoginResponse(status: LoginStatus.SignIn.rawValue,
                                          tokenDto: TokenResponse(accessToken: "a", refreshToken: "a")))
            return Disposables.create()
        }
    }
    
    func checkOverlapId(id: String) -> Observable<Bool> {
        return Observable.create { observer in
            
            return Disposables.create()
        }
    }
    
    
}
