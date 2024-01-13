//
//  SceneDelegate.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/04.
//

import KakaoSDKAuth
import KakaoSDKUser
import RxKakaoSDKAuth
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var coordinator: Coordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
    
        let navigationController = UINavigationController()
        window?.rootViewController = navigationController
        UIApplication.shared.applicationIconBadgeNumber = 0
        coordinator = DefaultAppCoordinator(navigationController: navigationController)
        coordinator?.start()
        window?.makeKeyAndVisible()
        
    }
        
    /// 카카오로그인 설정
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.rx.handleOpenUrl(url: url)
            }
        }
    }

}
