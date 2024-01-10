//
//  TabBarController.swift
//  TWTW
//
//  Created by 정호진 on 12/24/23.
//

import Foundation
import RxSwift
import UIKit

final class TabBarController: UITabBarController {
    
    private let disposeBag = DisposeBag()
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showAlertPage(_:)),
                                               name: NSNotification.Name("showPage"), object: nil)
    }
    
    /// 알림 페이지로 넘어가는 함수
    @objc
    private func showAlertPage(_ notification: Notification) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        if let userInfo = notification.userInfo {
            if let type = userInfo["type"] as? String,
               let title = userInfo["title"] as? String,
               let body = userInfo["body"] as? String,
               let id = userInfo["id"] as? String{
                selectedIndex = TabBarItemType.home.toInt()
                
                switch type {
                case "친구명:", "계획명:", "그룹명:":
                    showAlert(type: type, title: title, body: body, id: id)
                    print("invite")
                case "장소명:":
                    NotificationCenter.default.post(name: Notification.Name("moveMain"), object: nil)
                default:
                    print("wrong")
                }
            }
            
        }
    }
    
    /// 전송받은 알림 표시
    private func showAlert(type: String, title: String, body: String, id: String) {
        
        let sheet = UIAlertController(title: title, message: body, preferredStyle: .alert)

        sheet.addAction(UIAlertAction(title: "승인", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            switch type {
            case "친구명:":
                let service = FriendService()
                service.statusFriend(memberId: id, status: "ACCEPTED")
                    .subscribe(onNext: {
                        print("accepted friend")
                    }, onError: { error in
                        print(#function, error)
                    })
                    .disposed(by: disposeBag)
                print("invite")
            case "계획명":
                // TODO: 타입별로 승인요청 전송
                print("plan invite")
            case "그룹명":
                let service = GroupService()
                service.joinGroup(groupId: id)
                    .subscribe(onNext: { _ in
                        print("accepted join group")
                    }, onError: { error in
                        print(#function, error)
                    })
                    .disposed(by: disposeBag)
                print("invite")
            default:
                print("wrong")
            }
            
        }))

        sheet.addAction(UIAlertAction(title: "거절", style: .destructive, handler: { _ in print("초대 거절") }))

        present(sheet, animated: true)
    }
    
    ///
    private func confirmInviteFriend(id: String) {
        
    }
}
