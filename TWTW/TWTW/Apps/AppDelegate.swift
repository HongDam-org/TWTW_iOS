//
//  AppDelegate.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/04.
//

import Firebase
import KakaoSDKAuth
import RxKakaoSDKAuth
import RxKakaoSDKCommon
import UIKit
import UserNotifications

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /// Kakao SDK 초기화
        let kakaoNativeAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
        RxKakaoSDK.initSDK(appKey: kakaoNativeAppKey as? String ?? "")
        /// 백 버튼 색상 설정
        UINavigationBar.appearance().tintColor = UIColor.black
        /// 백 버튼 글자 숨김
        UIBarButtonItem.appearance()
            .setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -UIScreen.main.bounds.width, vertical: 0), for: .default)
        
        FirebaseApp.configure()
                
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization( options: authOptions, completionHandler: {_, _ in })
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
            }
        }
        
        
        return true
        
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("파이어베이스 토큰: \(fcmToken ?? "")")
        guard let fcmToken = fcmToken else { return }
        _ = KeychainWrapper.saveItem(value: fcmToken, forKey: "DeviceToken")
        
        let loginService = SignInService()
        _ = loginService.updateFCMDeviceToken(fcmToken: fcmToken)
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 푸시알림이 수신되었을 때 수행되는 메소드
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("메시지 수신 \(#function)")
        print(notification, center)
        completionHandler([.badge, .sound, .banner, .list])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("STart😡")
        print(response.notification.request.content.title, response.notification.request.content.body)
        
        let userInfo = response.notification.request.content.userInfo
        let type = "\(response.notification.request.content.body.split(separator: " ")[0])"
        let id = userInfo.filter { "\($0.key)" == "id" }
        
        print("type: \(type)")
//        if type == "친구명:" || type == "계획명:" || type == "그룹명:" {
            guard let value = id.first?.value else { return }
            print("value \(value)")
//            NotificationCenter.default.post(name: Notification.Name("showPage"), object: nil, userInfo: ["index": 2, "id": value])
        NotificationCenter.default.post(name: Notification.Name("showPage"), object: nil, userInfo: ["index": 0,
                                                                                                     "id" : value,
                                                                                                     "type": type,
                                                                                                     "title": response.notification.request.content.title,
                                                                                                     "body": response.notification.request.content.body])
//        } else if type == "장소명:" {
//            NotificationCenter.default.post(name: Notification.Name("showPage"), object: nil, userInfo: ["index": 0])
//        }
        
        userInfo.forEach { (key: AnyHashable, value: Any) in
            print(key, value)
        }
        
        
        print("END😡")
        completionHandler()
    }
}
