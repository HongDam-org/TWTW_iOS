//
//  SignInViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/04.
//


import UIKit
import SnapKit
import RxKakaoSDKAuth
import RxKakaoSDKUser
import RxSwift
import AuthenticationServices

final class SignInViewController: UIViewController {
    
    /// 카카오 로그인 이미지뷰 생성 및 설정
    private lazy var kakaoLoginImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kakao_login") // 카카오 로그인 이미지 설정
        imageView.contentMode = .scaleAspectFit
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onKakaoLoginImageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    /// 애플 로그인 이미지뷰 생성 및 설정
    private lazy var appleLoginImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "apple_login") // 애플 로그인 이미지 설정
        imageView.contentMode = .scaleAspectFit
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onAppleLoginImageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    private let disposeBag = DisposeBag()
    private let signInViewModel = SignInViewModel()
    
    // MARK: - View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkKakaoOAuthToken()
        setupUI()
        addSubViews()
    }
    
    /// MARK: Set Up About UI
    private func setupUI() {
        view.backgroundColor = .white
    }
    
    
    /// MARK: Add UI
    private func addSubViews() {
        view.addSubview(kakaoLoginImageView)
        view.addSubview(appleLoginImageView)
        
        configureConstraints()
    }
        
    /// MARK: 카카오로그인, 애플로그인 constraint설정
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
    
    // MARK: - Functions
    
    /// kakao 로그인 버튼 터치 했을 때
    @objc
    private func onKakaoLoginImageViewTapped() {
        signInViewModel.kakaoLogin()
            .subscribe(onNext:{ [weak self] kakaoUserInfo in
                let viewController = ViewController()
                viewController.modalPresentationStyle = .fullScreen
                self?.present(viewController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    /// MARK: OAuth Token 자동 로그인
    private func checkKakaoOAuthToken(){
        signInViewModel.checkKakaoOAuthToken()
            .subscribe(onNext: {[weak self] kakaoUserInfo in
                let viewController = ViewController()
                viewController.modalPresentationStyle = .fullScreen
                self?.present(viewController, animated: true, completion: nil)
                
            })
            .disposed(by: disposeBag)
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
