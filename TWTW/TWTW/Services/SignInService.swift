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


class SignInService{
    private let disposeBag = DisposeBag()
    
    // Input: 뷰에서 받은 입력 처리 트리거
    let kakaoLoginTrigger = PublishRelay<Void>()// 카카오 로그인
    //Output
    let kakaoLoginSuccess = PublishRelay<Void>()//로그인 성공
    
    init() {
        // 토큰 확인
        if (AuthApi.hasToken()) {
            UserApi.shared.rx.accessTokenInfo()
                .subscribe(onSuccess: { (_) in
                    // 토큰 유효성 체크 성공(필요 시 토큰 갱신됨)
                    self.fetchKakaoUserInfo()
                    self.kakaoLoginSuccess.accept(()) // 토큰이 있으면 로그인 성공으로 처리
                }, onFailure: { error in
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true {
                        // 토큰이 유효하지 않음
                    } else {
                        // 기타 에러
                    }
                })
                .disposed(by: disposeBag)
        } else {
            // 로그인 필요
        }
        
        // 카카오 로그인
        kakaoLoginTrigger
            .flatMapLatest { _ in
                // 카카오 계정 로그인
                UserApi.shared.rx.loginWithKakaoAccount()
                    .do(onNext: { _ in
                        print("loginWithKakaoAccount() success.")
                        // 로그인 성공 후 처리
                        self.fetchKakaoUserInfo() // 로그인 성공 후 사용자 정보 불러오기
                        self.kakaoLoginSuccess.accept(()) // 로그인 성공으로 처리
                    }, onError: { error in
                        print("loginWithKakaoAccount() error: \(error)")
                    })
                        .map { _ in () }
                        .catchErrorJustReturn(())
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    // 카카오 사용자 정보 불러오기
    private func fetchKakaoUserInfo() {
        UserApi.shared.rx.me()
            .subscribe (onSuccess:{ user in
                print("me() success.")
                self.processKakaoUserInfo(user: user)
                
                _ = user
            }, onFailure: {error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    // 카카오 사용자 정보 처리
    private func processKakaoUserInfo(user: KakaoSDKUser.User) {
        // 사용자 정보를 받아오기
        let userId = user.id
        let userEmail = user.kakaoAccount?.email ?? ""
        let userNickname = user.kakaoAccount?.profile?.nickname ?? ""
        print(userId ?? "nil")
        print(userEmail)
        print(userNickname)

    }
}
