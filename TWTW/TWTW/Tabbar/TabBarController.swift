//
//  TabBarController.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/14.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class TabBarController: UITabBarController {
    ///mark: -  탭 아이템을 저장하는 BehaviorRelay
    private let tabItemsRelay = BehaviorRelay<[TabItem]>(value: [])
    weak var delegates: BottomSheetDelegate?
    
    ///mark: -  MainMapViewController 뷰의 높이를 나타내는 BehaviorRelay
    var viewHeight: BehaviorRelay<CGFloat> = BehaviorRelay(value: CGFloat())
    
    private var tabBarViewModel = TabBarViewModel()
    
    ///mark: - 처음 로딩되었을때 바텀시트 높이지정하기 위한 플래그
    var isFirstLoad: Bool = true
    private let disposeBag = DisposeBag()
    let acceptableRange = 0.1
    
    //내위치로 이동하기 이미지버튼
    lazy var myloctaionImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "myLocation"))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    // 초기화 메서드
    init(delegates: BottomSheetDelegate? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.delegates = delegates
        setTabbar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 뷰가 로드된 후 호출되는 메서드
    override func viewDidLoad() {
        super.viewDidLoad()
        // 뷰의 높이를 설정하고
        let viewHeight = self.view.bounds.height
        tabBarViewModel.setupHeight(viewHeight: viewHeight)
        tabBar.backgroundColor = UIColor(white: 1, alpha: 1)
        view.backgroundColor = .clear
    }
    
    // 탭바와 뷰컨트롤러 연결
    private func setTabbar() {
        let tabItems: [TabItem] = [
            TabItem(title: "홈", imageName: TabbarItemTitle.house.rawValue),
            TabItem(title: "일정", imageName: TabbarItemTitle.calendar.rawValue),
            TabItem(title: "친구 목록", imageName: TabbarItemTitle.person.rawValue),
            TabItem(title: "알림", imageName: TabbarItemTitle.bell.rawValue),
            TabItem(title: "전화", imageName: TabbarItemTitle.phone.rawValue)
        ]
        
        let observableTabItem: Observable<[TabItem]> = Observable.of([
            TabItem(title: "홈", imageName: TabbarItemTitle.house.rawValue),
            TabItem(title: "일정", imageName: TabbarItemTitle.calendar.rawValue),
            TabItem(title: "친구 목록", imageName: TabbarItemTitle.person.rawValue),
            TabItem(title: "알림", imageName: TabbarItemTitle.bell.rawValue),
            TabItem(title: "전화", imageName: TabbarItemTitle.phone.rawValue)
        ])
        
        let homeCoordinator = PreviousAppointmentsCoordinator(navigationController: UINavigationController())
        let scheduleCoordinator = PreviousAppointmentsCoordinator(navigationController: UINavigationController())
        let friendsListCoordinator = FriendsListCoordinator(navigationController: UINavigationController())
        let notificationCoordinator = NotificationCoordinator(navigationController: UINavigationController())
        let callCoordinator = CallCoordinator(navigationController: UINavigationController())
        
        viewControllers = [
            homeCoordinator.navigationController,
            scheduleCoordinator.navigationController,
            friendsListCoordinator.navigationController,
            notificationCoordinator.navigationController,
            callCoordinator.navigationController
        ]
        homeCoordinator.start()
        scheduleCoordinator.start()
        friendsListCoordinator.start()
        notificationCoordinator.start()
        callCoordinator.start()
        
        tabItemsRelay.accept(tabItems)
        
        addSubViews()
        bindTabItems()
    }
    
    // 탭 아이템을 BehaviorRelay를 사용하여 탭 바 아이템에 연결
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
    
    // 뷰 컨트롤러에 서브뷰 추가
    private func addSubViews() {
        viewControllers?.forEach { viewController in
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            viewController.view.addGestureRecognizer(panGesture)
            //  tabBarViewModel.setupHeight(viewHeight: viewHeight.value)
        }
        view.addSubview(myloctaionImageView)
        configureConstraints()
    }
    
    private func configureConstraints(){
        myloctaionImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(5)
            make.bottom.equalTo(self.view.snp.top).offset(-5) // 바텀시트와 5 포인트 떨어진 위치에 배치
            make.width.height.equalTo(view.snp.width).dividedBy(10) // 이미지 크기 설정
        }
    }
    
    // 팬 제스처 핸들링 메서드
    @objc private func handlePan(_ panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
            
        case .began:
            // 초기 터치 위치
            tabBarViewModel.initialTouchY = panGesture.location(in: view).y
            
        case .changed:
            let lastTouchY = panGesture.location(in: view).y
            let gapTouchY = tabBarViewModel.initialTouchY - lastTouchY // Y 좌표 간격을 계산
            
            // 뷰의 현재 높이와 이동된 간격을 기반으로 새로운 높이를 계산
            var heightByTouch = viewHeight.value + gapTouchY
            
            // 최소 높이와 최대 높이를 벗어나지 않도록 보정
            heightByTouch = min(max(heightByTouch, tabBarViewModel.noneHeight * (1)), tabBarViewModel.maxHeight * (1 + acceptableRange))
            updateBottomSheetHeight(heightByTouch)
            
        case .ended, .cancelled:
            let targetHeight = tabBarViewModel.calculateFinalHeight(changedHeight: viewHeight.value)
            
            // ViewModel을 사용하여 최종 높이를 계산
            let finalHeight = tabBarViewModel.calculateFinalHeight(changedHeight: targetHeight)
            
            UIView.animate(withDuration: 0.2) {
                self.updateBottomSheetHeight(finalHeight)
                self.view.layoutIfNeeded()
            }
            delegates?.didUpdateBottomSheetHeight(finalHeight)
            
        default:
            break
        }
    }
    
    // 뷰의 높이 업데이트
    func updateBottomSheetHeight(_ height: CGFloat) {
        var newHeight = height
        if isFirstLoad {
            if newHeight > tabBarViewModel.maxHeight {
                newHeight = tabBarViewModel.minHeight
                isFirstLoad = false
            }
        }
        // 바텀시트와 5 포인트 떨어진 위치로 유지
        myloctaionImageView.snp.updateConstraints { make in
            make.bottom.equalTo(self.view.snp.top).offset(-5)
        }
        if newHeight > tabBarViewModel.midHeight {
            view.sendSubviewToBack(myloctaionImageView)
            myloctaionImageView.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.snp.top).offset(myloctaionImageView.frame.height + 5)
            }
        }
        viewHeight.accept(newHeight)
        tabBarViewModel.heightConstraintRelay.accept(tabBarViewModel.heightConstraintRelay.value?.update(offset: newHeight))
        delegates?.didUpdateBottomSheetHeight(newHeight)
    }
}

