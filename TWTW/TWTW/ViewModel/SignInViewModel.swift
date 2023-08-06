//
//  SignInViewModel.swift
//  TWTW
//
//  Created by 정호진 on 2023/08/06.
//

import Foundation
import RxSwift
import RxRelay
import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon

/// 로그인 ViewModel
final class SignInViewModel {
    private let disposeBag = DisposeBag()
    private let signInServices = SignInService()
    
    // MARK: - API Connect
    
    /// 카카오 로그인 
    func kakaoLogin() -> Observable<KakaoSDKUser.User>{
        return Observable.create { [weak self] observer in
            self?.signInServices.kakaoLogin()
                .subscribe(onNext: { kakaoUserInfo in
                    observer.onNext(kakaoUserInfo)
                })
                .disposed(by: self?.disposeBag ?? DisposeBag())
            return Disposables.create()
        }
    }
    
    /// 자동 로그인 통신
    func checkKakaoOAuthToken() -> Observable<KakaoSDKUser.User>{
        return Observable.create { [weak self] observer in
            self?.signInServices.checkKakaoOAuthToken()
                .subscribe(onNext:{ userInfo in
                    observer.onNext(userInfo)
                })
                .disposed(by: self?.disposeBag ?? DisposeBag())
            return Disposables.create()
        }
    }

        
}
