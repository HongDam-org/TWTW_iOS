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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var dispose = DisposeBag()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        //루트 뷰 컨트롤러를 SignInViewController로 설정
        let signInViewController = MainMapViewController()
        window?.rootViewController = signInViewController
        
        //화면 보이게 윈도우 키 윈도우 설정
        window?.makeKeyAndVisible()
        
        // 자동로그인
        if let accessToken = KeychainWrapper.loadString(forKey: "AccessToken") {
            // 저장된 토큰이 있으면 자동 로그인 진행
            UserApi.shared.rx.loginWithKakaoAccount()
                .subscribe(onNext: { [weak self] oauthToken in
                    // 토큰 저장
                    KeychainWrapper.saveString(value: oauthToken.accessToken, forKey: "AccessToken")
                    
                    // 로그인 성공 후 메인 화면으로 이동
                    let viewController = ViewController()
                    viewController.modalPresentationStyle = .fullScreen
                    self?.window?.rootViewController?.present(viewController, animated: true, completion: nil)
                }, onError: { error in
                    // 자동 로그인 실패하면 로그인 화면 유지
                })
                .disposed(by: dispose)
        }
    }
  
    
    
    //카카오로그인 설정
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
           if let url = URLContexts.first?.url {
               if (AuthApi.isKakaoTalkLoginUrl(url)) {
                   _ = AuthController.rx.handleOpenUrl(url: url)
               }
           }
       }
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

