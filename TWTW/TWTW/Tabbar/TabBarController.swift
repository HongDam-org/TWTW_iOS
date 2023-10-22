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
import RxGesture

final class TabBarController: UITabBarController {
    var viewModel: TabBarViewModel
    weak var delegates: BottomSheetDelegate?
    private let disposeBag = DisposeBag()
    
    ///mark: - 처음 로딩되었을때 바텀시트 높이지정하기 위한 플래그
    var isFirstLoad: Bool = true
    
    // MARK: - init
    
    // 초기화 메서드
    init(viewModel: TabBarViewModel, delegates: BottomSheetDelegate? = nil) {
        self.viewModel = viewModel
        self.delegates = delegates
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 뷰의 높이를 설정하고
        tabBar.backgroundColor = UIColor(white: 1, alpha: 1)
        view.backgroundColor = .clear   
    }
    
    func start() {
        bind()
    }
    
    /// MARK: viewModel binding
    private func bind(){
        let input = TabBarViewModel.Input(homePanEvents: viewControllers?[0].view.rx.panGesture().when(.began,.changed,.ended),
                                          schedulePanEvents: viewControllers?[1].view.rx.panGesture().when(.began, .changed, .ended),
                                          friendsListPanEvents: viewControllers?[2].view.rx.panGesture().when(.began, .changed, .ended),
                                          notificationPanEvents: viewControllers?[3].view.rx.panGesture().when(.began, .changed, .ended),
                                          callPanEvents: viewControllers?[4].view.rx.panGesture().when(.began, .changed, .ended),
                                          nowViewHeight: BehaviorSubject(value: view.frame.height * 0.3),
                                          viewHeight: view.frame.height)
        
        let output = viewModel.transform(input: input)
        
        output.heightRelay
            .bind { [weak self] height in
                guard let self = self else {return}
                print("heightRelay \(height)")
                delegates?.didUpdateBottomSheetHeight(height)
            }
            .disposed(by: disposeBag)
    }
}
