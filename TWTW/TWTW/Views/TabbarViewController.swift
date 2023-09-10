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
    // BehaviorRelay로 탭 아이템 저장
    private let tabItemsRelay = BehaviorRelay<[TabItem]>(value: [])
    weak var delegates: BottomSheetDelegate?
    
    /// MainMapViewController view의 높이
    var viewHeight: BehaviorRelay<CGFloat> = BehaviorRelay(value: CGFloat())
    
    private var bottomSheetViewModel = BottomSheetViewModel()
    var isFirstLoad : Bool = true
    private let disposeBag = DisposeBag()
    
    // MARK: - init
    init(delegates: BottomSheetDelegate? = nil, viewHeight: CGFloat) {
        super.init(nibName: nil, bundle: nil)
        
        self.delegates = delegates
        self.viewHeight.accept(viewHeight)
        
        setTabbar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 20
        
        // view의 높이를 설정하고
            let viewHeight = self.view.bounds.height
            // BottomSheetViewModel에 높이를 설정
            bottomSheetViewModel.setupHeight(viewHeight: viewHeight)
        print("🍎\(viewHeight)")
    }
    
    func setViewHeight(_ height: CGFloat) {
        viewHeight.accept(height)
    }
    
    /// MARK: Tabbar와 VCs 연결
    private func setTabbar() {
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
    
    /// Tabbar 아이템을 BehaviorRelay를 사용하여 탭 바 아이템을 바인딩
    private func bindTabItems() {
        tabItemsRelay
            .asObservable()
            .subscribe(onNext: { [weak self] items in
                guard let self = self else { return }
                self.viewControllers?.enumerated().forEach { index, viewController in
                    let item = items[index]
                    let image = UIImage(systemName: item.imageName)
                    viewController.tabBarItem = UITabBarItem(title: item.title, image: image, selectedImage: nil)
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// Add UI
    private func addSubViews() {
        viewControllers?.forEach { viewController in
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            viewController.view.addGestureRecognizer(panGesture)
            bottomSheetViewModel.setupHeight(viewHeight: viewHeight.value)
        }
    }
    
    @objc private func handlePan(_ panGesture: UIPanGestureRecognizer) {
        // 현재 손가락 터치 위치 출력
        let location = panGesture.location(in: view)
        // 패닝 제스처의 변화
        let translation = panGesture.translation(in: view)
        // 뷰 컨트롤러의 현재 높이
        var currentHeight = viewHeight.value
        // 패닝 제스처의 변화를 기반으로 새로운 높이를 계산
        let targetHeight = currentHeight - translation.y
        // 새로운 높이로 뷰 컨트롤러의 높이를 업데이트
        updateBottomSheetHeight(targetHeight)
        // 패닝 제스처의 변화를 초기화.
        panGesture.setTranslation(.zero, in: view)

        // 손가락을 떼었을 때 최소(min), 중간(mid), 최대(max)로 이동
        if panGesture.state == .ended || panGesture.state == .cancelled {
            let finalHeight: CGFloat
            if targetHeight > bottomSheetViewModel.midHeight {
                finalHeight = bottomSheetViewModel.maxHeight
            } else if targetHeight > bottomSheetViewModel.minHeight {
                finalHeight = bottomSheetViewModel.midHeight
            } else {
                finalHeight = bottomSheetViewModel.minHeight
            }

            // 최종 높이로 애니메이션을 사용하여 높이를 부드럽게 업데이트
            UIView.animate(withDuration: 0.3) {
                self.updateBottomSheetHeight(finalHeight)
                self.view.layoutIfNeeded()
            }

            // 최종 높이를 델리게이트에 알림
            delegates?.didUpdateBottomSheetHeight(finalHeight)
        }
    }

    func updateBottomSheetHeight(_ height: CGFloat) {

        var newHeight = height
        if isFirstLoad {
            if newHeight > bottomSheetViewModel.maxHeight {
                newHeight = bottomSheetViewModel.minHeight
                isFirstLoad = false
            }
            isFirstLoad = false
        }
           viewHeight.accept(newHeight)
           bottomSheetViewModel.heightConstraintRelay.accept(bottomSheetViewModel.heightConstraintRelay.value?.update(offset: newHeight))
           delegates?.didUpdateBottomSheetHeight(newHeight)
    }
}

// 탭 아이템 나타내는 구조체
struct TabItem {
    let title: String
    let imageName: String
}

