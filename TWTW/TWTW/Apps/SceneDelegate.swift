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
    private let signInViewModel = SignInViewModel.shared
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        var rootViewController: UIViewController?
        
//        if let accessToken = KeychainWrapper.loadString(forKey: SignIn.accessToken.rawValue), let refreshToken = KeychainWrapper.loadString(forKey: SignIn.refreshToken.rawValue){
//            
//            /*
//             1. AccessToken 유효성 확인
//              1.1 AccessToken 만료된 경우 재발급 API 호출 -> 2번으로 진행
//              1.2 AccessToken 만료되지 않은 경우 -> 자동 로그인 진행
//             2. SignIn 진행
//             3. response status가 SignUp인 경우 -> 회원 가입 페이지 이동
//              3.1 SignIn인 경우 로그인 끝 -> Main으로 이동
//             */
//            
//            // 토큰 재발급
//            if getNewToken() {
//                rootViewController = MeetingListViewController()
//            }
//            else{
//                rootViewController = SignInViewController()
//            }
//        }
//        else{
//            rootViewController = SignInViewController()
//        }
        
        rootViewController = InputInfoViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController ?? UIViewController())
        window?.rootViewController = navigationController
        //화면 보이게 윈도우 키 윈도우 설정
        window?.makeKeyAndVisible()
        
    }
    
    /// MARK: 새로운 토큰 발급
    private func getNewToken() -> Bool {
        var check: Bool = false
        
        signInViewModel.getNewAccessToken()
            .subscribe(onNext:{ [weak self] data in
                guard let self = self else { return }
                if let access = data.accessToken, let refresh = data.refreshToken {
                    if KeychainWrapper.saveString(value: access, forKey: SignIn.accessToken.rawValue) && KeychainWrapper.saveString(value: refresh, forKey: SignIn.refreshToken.rawValue){
                        check = true
                    }
                }
            },onError: { [weak self] error in
                guard let self = self else { return }
                print("\(#function) error!\n\(error)")
            })
            .disposed(by: disposeBag)
        
        return check
        
    }
    
    ///mark: -카카오로그인 설정
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.rx.handleOpenUrl(url: url)
            }
        }
    }
    
}
