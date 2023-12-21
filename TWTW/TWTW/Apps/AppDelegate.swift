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
            }
            else if let token = token {
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
        print(messaging)
        print("파이어베이스 토큰: \(fcmToken)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    // 푸시알림이 수신되었을 때 수행되는 메소드
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("메시지 수신 \(#function)")
        print(notification, center)
        completionHandler([.badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        print("STart😡")
        userInfo.forEach { (key: AnyHashable, value: Any) in
            print(key, value)
        }
        
        if let gameId = userInfo["gameId"] as? String {
            print("gameId = \(gameId)")
        }
        
        if let messageId = userInfo["messageId"] as? String {
            print("messageId = \(messageId)")
        }
        
//        let meetingID = userInfo["MEETING_ID"] as! String
//        let userID = userInfo["USER_ID"] as! String
        
        // Perform the task associated with the action
//        switch response.actionIdentifier {
//        case "ACCEPT_ACTION":
//            print("\(userID)님이 \(meetingID) 미팅을 수락하셨습니다")
//        case "DECLINE_ACTION":
//            print("\(userID)님이 \(meetingID) 미팅을 거부하셨습니다")
//        case UNNotificationDefaultActionIdentifier:
//            print("그냥 액션 정의 안했고 알림 탭 해서 앱 실행시킨 경우")
//        case UNNotificationDismissActionIdentifier:
//            print("알림 dismiss 시켜버린 경우")
//        default:
//            break
//        }
        
        print("END😡")
        print(#function)
        print(center, response)
        completionHandler()
    }
}
