//
//  PlansViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/17.
//

import RxSwift
import UIKit

final class PlansViewModel {
    var coordinator: DefaultPlansCoordinator
    
    /// 입력이 아닌 뷰모델의 상태를 나타내는 출력 값 Input 밖에서
    var callerObservable: Observable<PlanCaller> {
            return Observable.just(caller)
        }
    
    private let disposeBag = DisposeBag()
    private let caller: PlanCaller
    
    struct Input {
        let selectedPlansList: Observable<IndexPath>
        let addPlans: Observable<Void>
    }
    
    // MARK: - Init
    init(coordinator: DefaultPlansCoordinator, caller: PlanCaller = .fromTabBar) {
        self.coordinator = coordinator
        self.caller = caller
    }
    
    func bind(input: Input) {
        input.selectedPlansList
            .bind { [weak self] _ in
                guard let self = self else { return }
                switch self.caller {
                case .fromAlert:
                    coordinator.moveToPartiSetLocation()
                case .fromTabBar:
                    print("탭바에서 호출됨")
                    coordinator.moveToPartiGetLocation()

                }
            }.disposed(by: disposeBag)
        
        input.addPlans
            .bind { [weak self] _ in
                guard let self = self else { return }
                coordinator.moveToPartiSetLocation()
            }.disposed(by: disposeBag)
    }
}
