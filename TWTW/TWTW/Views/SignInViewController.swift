//
//  SignInViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/04.
//


import UIKit
import SnapKit
import KakaoSDKAuth
import RxKakaoSDKAuth
import KakaoSDKUser
import RxKakaoSDKUser
import RxSwift
import AuthenticationServices

class SignInViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let signInServices = SignInService()
    
    private lazy var kakaoLoginImageView: UIImageView = {
        // 카카오 로그인 이미지뷰 생성 및 설정
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kakao_login") // 카카오 로그인 이미지 설정
        imageView.contentMode = .scaleAspectFit
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onKakaoLoginImageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }()
    
    private lazy var appleLoginImageView: UIImageView = {
        // 애플 로그인 이미지뷰 생성 및 설정
        let imageView = UIImageView()
        imageView.image = UIImage(named: "apple_login") // 애플 로그인 이미지 설정
        imageView.contentMode = .scaleAspectFit
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onAppleLoginImageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        configureConstraints()
        setupUI()
        bindViewModel()
    }
    private func setupUI() {
        view.backgroundColor = .white
    }
    
    private func addSubViews() {
        view.addSubview(kakaoLoginImageView)
        view.addSubview(appleLoginImageView)
        
    }
        
        //카카오로그인, 애플로그인 constraint설정
    private func configureConstraints() {
        kakaoLoginImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(kakaoLoginImageView.snp.width).multipliedBy(0.18)
        }
        appleLoginImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(kakaoLoginImageView.snp.bottom).offset(5)
            make.width.height.equalTo(kakaoLoginImageView)
        }
    }
    
    @objc private func onKakaoLoginImageViewTapped() {
        // 뷰모델의 카카오 로그인 트리거 실행
        signInServices.kakaoLoginTrigger.accept(())
    }
    
    // View와 ViewModel을 바인딩
    private func bindViewModel() {
        signInServices.kakaoLoginSuccess
            .subscribe(onNext: { [weak self] in
                let viewController = ViewController()
                viewController.modalPresentationStyle = .fullScreen
                self?.present(viewController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        // 카카오 로그인 에러를 처리
        signInServices.kakaoLoginError
            .subscribe(onNext: { error in
            })
            .disposed(by: disposeBag)
        // 애플 로그인 --> 애플은 Sign in with Apple 기능 자체 API 필요없음
    }
}
//ASAuthorizationControllerDelegate 프로토콜 ASAuthorizationControllerPresentationContextProviding 프로토콜로 애플 로그인사용
extension SignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    // 애플 로그인 결과를 처리하는 함수
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // 사용자의 고유 Apple ID와 이름 가져오기
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            // 로그인 성공 처리
            let viewController = ViewController()
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 로그인 오류 처리
        print("loginWithAppleAccount() error: \(error)")
    }
    
    // 애플 로그인 표시를 위한 컨텍스트를 처리하는 함수
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    // 애플 로그인 과정을 시작하는 함수
    @objc private func onAppleLoginImageViewTapped() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email] // 사용자의 이름과 이메일을 요청
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}
