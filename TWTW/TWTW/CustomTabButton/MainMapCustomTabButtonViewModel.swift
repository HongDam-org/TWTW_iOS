//
//  CustomTabButtonViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/11/28.
//

import Foundation
import RxCocoa
import RxSwift

final class MainMapCustomTabButtonViewModel {
    private let disposeBag = DisposeBag()
    weak var coordinator: DefaultMainMapCoordinator?
    
    /// Input
    struct Input {
        let participantsButtonTapped: Observable<Void>
        let notificationsButtonTapped: Observable<Void>
    }
    
    // MARK: - Init
    init(coordinator: DefaultMainMapCoordinator) {
        self.coordinator = coordinator
    }
    /// bind
    func bind(input: Input) {
        input.participantsButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.participantsButtonTapped()
            })
            .disposed(by: disposeBag)
        
        input.notificationsButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.notificationsButtonTapped()
            })
            .disposed(by: disposeBag)
    }
    
    /// 친구화면으로 이동
    private func participantsButtonTapped() {
        coordinator?.moveToParticipantsList()
    }
    
    // 알림 화면으로 이동
    private func notificationsButtonTapped() {
        coordinator?.moveToPlans()
    }
}
