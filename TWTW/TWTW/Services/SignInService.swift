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

class SignInService{
    private let disposeBag = DisposeBag()
    
    // Input: 뷰에서 받은 입력 처리 트리거
    let kakaoLoginTrigger = PublishRelay<Void>()// 카카오 로그인
    let appleLoginTrigger = PublishRelay<Void>()// 애플 로그인
    
    // Output: 뷰로 결과를 전달하기 위한 트리거
    // 카카오 로그인
    let kakaoLoginSuccess = PublishRelay<Void>()
    let kakaoLoginError = PublishRelay<Error>()
    
    init() {
        kakaoLoginTrigger
            .flatMapLatest { _ in
                // 카카오 계정 로그인
                UserApi.shared.rx.loginWithKakaoAccount() //RxSwift- Observable을 반환
                    .materialize() //Notification으로 변환
            }
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .next(let oauthToken):
                    //  로그인 성공한 경우
                    print("loginWithKakaoAccount() success.")
                    // 로그인 성공 후 처리
                    // 뷰모델의 kakaoLoginSuccess 트리거에 값 전달
                    self?.kakaoLoginSuccess.accept(())
                case .error(let error):
                    // 로그인 실패한 경우
                    print("loginWithKakaoAccount() error: \(error)")
                    // 뷰모델의 kakaoLoginError 트리거에 에러 값 전달
                    self?.kakaoLoginError.accept(error)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    
}

