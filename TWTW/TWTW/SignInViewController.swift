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

class SignInViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    //카카오계정으로 로그인 버튼 생성(카카오로그인 크기를 커스텀하기위해 버튼 ->이미지로 변경)
    private lazy var kakaoLoginImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kakao_login")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onKakaoLoginImageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }()
    
    @objc func onKakaoLoginImageViewTapped() {
        // 이미지뷰를 터치한 경우에 호출될 메서드
        onKakaoLoginButtonTapped()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKakaoLoginUI()
        setupUI()
    }
    final func setupUI(){
        view.backgroundColor = .white
    }
    final func setupKakaoLoginUI() {
        
        view.addSubview(kakaoLoginImageView)
        // 버튼 제약 조건 설정
        kakaoLoginImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(kakaoLoginImageView.snp.width).dividedBy(0.3)
        }
        
    }
    
    
    func onKakaoLoginButtonTapped() {
        // 카카오계정으로 로그인
        UserApi.shared.rx.loginWithKakaoAccount()
            .subscribe(onNext: { [weak self] (oauthToken) in
                print("loginWithKakaoAccount() success.")
                // 로그인 성공 후 ViewController로 이동
                let viewController = ViewController() // 해당 뷰 컨트롤러를 초기화
                viewController.modalPresentationStyle = .fullScreen
                self?.present(viewController, animated: true, completion: nil)
            }, onError: { error in
                print("loginWithKakaoAccount() error: \(error)")
                
                
            })
            .disposed(by: disposeBag)
        
        
    }
    
    
    
}
