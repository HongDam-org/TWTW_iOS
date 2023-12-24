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
    struct Output {
        let callerState: PlanCaller
    }
    
    // MARK: - Init
    init(coordinator: DefaultPlansCoordinator, caller: PlanCaller = .fromTabBar) {
        self.coordinator = coordinator
        self.caller = caller
    }
    
    func bind(input: Input) -> Output {
        input.selectedPlansList
            .bind { [weak self] _ in
                guard let self = self else { return }
                switch self.caller {
                case .fromAlert:
                    coordinator.moveToplansFromAlert()
                case .fromTabBar:
                    print("탭바에서 호출됨")
                    coordinator.moveToPlanFromTabBar()
                }
            }.disposed(by: disposeBag)
        
        input.addPlans
            .bind { [weak self] _ in
                guard let self = self else { return }
                coordinator.moveToAddPlans()
            }.disposed(by: disposeBag)
        
        let output = Output(callerState: caller)
        
        return output
    }
    
}
