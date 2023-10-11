//
//  AppDelegate.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/04.
//

import UIKit
import RxKakaoSDKCommon
import RxKakaoSDKAuth
import KakaoSDKAuth

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        ///mark: -Kakao SDK 초기화
        let kakaoNativeAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
        RxKakaoSDK.initSDK(appKey: kakaoNativeAppKey as? String ?? "")
        
        ///mark: - 백 버튼 색상 설정
        UINavigationBar.appearance().tintColor = UIColor.black
        ///mark: -백 버튼 글자 숨김
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -UIScreen.main.bounds.width, vertical: 0), for: .default)
        
        return true
        
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
}

