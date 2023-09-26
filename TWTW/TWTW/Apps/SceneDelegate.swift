//
//  SceneDelegate.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/04.
//

import UIKit
import RxKakaoSDKAuth
import KakaoSDKAuth
import RxSwift
import KakaoSDKUser

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private let disposeBag = DisposeBag()
    private let service = SignInViewModel.shared
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        var rootViewController: UIViewController?
        
        if let accessToken = KeychainWrapper.loadString(forKey: SignIn.accessToken.rawValue), let refreshToken = KeychainWrapper.loadString(forKey: SignIn.refreshToken.rawValue){
            
            /*
             1. AccessToken 유효성 확인
              1.1 AccessToken 만료된 경우 재발급 API 호출 -> 2번으로 진행
              1.2 AccessToken 만료되지 않은 경우 -> 자동 로그인 진행
             2. SignIn 진행
             3. response status가 SignUp인 경우 -> 회원 가입 페이지 이동
              3.1 SignIn인 경우 로그인 끝 -> Main으로 이동
             */
            
            
        }
        else{
            rootViewController = SignInViewController()
        }
        
//        rootViewController = InputInfoViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController ?? UIViewController())
        window?.rootViewController = navigationController
        //화면 보이게 윈도우 키 윈도우 설정
        window?.makeKeyAndVisible()
        
    }
    
    ///mark: -카카오로그인 설정
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.rx.handleOpenUrl(url: url)
            }
        }
    }
        
    /// MARK:
    private func getNewToken(){
        service.getNewAccessToken()
            .subscribe(onNext:{ data in
                
            })
            .disposed(by: disposeBag)
    }
    
    /// MARK:
    private func kakatoAutoLogin(){
//         저장된 토큰이 있으면 자동 로그인 진행
            UserApi.shared.rx.loginWithKakaoAccount()
                .subscribe(onNext: { [weak self] oauthToken in
                    // 토큰 저장
                    KeychainWrapper.saveString(value: oauthToken.accessToken, forKey: "AccessToken")

                    // 로그인 성공 후 메인 화면으로 이동
                    // let viewController = MeetingListViewController()
                    if let navigationController = self?.window?.rootViewController as? UINavigationController {
                        let signInViewController = SignInViewController()
                        navigationController.pushViewController(signInViewController, animated: true)
                    }

                }, onError: { error in
                    // 자동 로그인 실패하면 로그인 화면 유지
                })
                .disposed(by: disposeBag)
    }
}
