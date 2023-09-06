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
import SnapKit

final class TabBarController: UITabBarController {
    private let disposeBag = DisposeBag()
    
    //BehaviorRelay로 탭 아이템 저장
    private let tabItemsRelay = BehaviorRelay<[TabItem]>(value: [])
    weak var delegates: BottomSheetDelegate?
    /// MainMapViewController view의 높이
    var viewHeight: BehaviorRelay<CGFloat> = BehaviorRelay(value: CGFloat())

    private let viewModel = BottomSheetViewModel()
    
    init(delegates: BottomSheetDelegate? = nil, viewHeight: CGFloat) {
        super.init(nibName: nil, bundle: nil)
        
        self.delegates = delegates
        self.viewHeight.accept(viewHeight)
        setTabbar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 20
        self.delegate = self
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
            PreviousAppointmentsViewController(),
            PreviousAppointmentsViewController(),
            FriendsListViewController(),
            NotificationViewController(),
            CallViewController()
        ]
        tabItemsRelay.accept(tabItems)
        
        addSubViews()
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
    
    /// MARK: Add UI
    private func addSubViews() {
        viewControllers?.forEach({ viewController in
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            viewController.view.addGestureRecognizer(panGesture)
            print("viewHeight \(viewHeight.value)")
            viewModel.setupHeight(viewHeight: viewHeight.value)
        })
    }
    
    /// panning Gesture
    @objc
    private func handlePan(_ panGesture: UIPanGestureRecognizer){
        viewModel.handlePan(gesture: panGesture, view: view)
            .subscribe(onNext: { [weak self] targetHeight in
                guard let self = self else { return }
                print("height \(targetHeight)")
                self.delegates?.didUpdateBottomSheetHeight(targetHeight)

                UIView.animate(withDuration: 0.2) {
                    self.viewModel.heightConstraintRelay.accept(self.viewModel.heightConstraintRelay.value?.update(offset: targetHeight))
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
    }
    
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        if viewController is PreviousAppointmentsViewController {
//            let modalView = PreviousAppointmentsViewController()
//            modalView.modalPresentationStyle = .formSheet
//            present(modalView, animated:true)
//            return false
//        }
        
        return true
        
    }
    
}

//탭 아이템 나타내는 구조체
struct TabItem {
    let title: String
    let imageName: String
}

