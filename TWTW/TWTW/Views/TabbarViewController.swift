//
//  TabbarViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/09/04.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class TabBarController: UITabBarController {
    private let disposeBag = DisposeBag()
    
    //BehaviorRelay로 탭 아이템 저장
    private let tabItemsRelay = BehaviorRelay<[TabItem]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTabbar()
       
      
    }
    
    ///mark : Tabbar 와 VCs 연결
    private func setTabbar(){
        // 각 탭 아이템 생성
        let tabItems: [TabItem] = [
            TabItem(title: "홈", imageName: "house"),
            TabItem(title: "일정", imageName: "calendar"),
            TabItem(title: "친구 목록", imageName: "person.2"),
            TabItem(title: "알림", imageName: "bell"),
            TabItem(title: "전화", imageName: "phone")
        ]
      
        viewControllers = [
            MainMapViewController(),
            PreviousAppointmentsViewController(),
            FriendsListViewController(),
            NotificationViewController(),
            CallViewController()
        ]
        tabItemsRelay.accept(tabItems)
        
        bindTabItems()
    }
    ///mark : 탭바 아이템을 BehaviorRelay를 사용하여 탭 바 아이템을 바인딩
    private func bindTabItems(){
        tabItemsRelay
            .asObservable()
            .subscribe(onNext: {[weak self] items in
                guard let self = self else {return}
                self.viewControllers?.enumerated().forEach{ index, viewController in
                    let item = items[index]
                    let image = UIImage(systemName: item.imageName)
                    viewController.tabBarItem = UITabBarItem(title: item.title, image: image, selectedImage: nil)
                }
            })
            .disposed(by: disposeBag)
    }
}

//탭 아이템 나타내는 구조체
struct TabItem {
    let title: String
    let imageName: String
}

