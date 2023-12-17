//
//  SearchPlaceBottomSheetViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/15.
//

import Foundation
import RxSwift

final class SearchPlaceBottomSheetViewModel {
    private let disposeBag = DisposeBag()
    weak var coordinator: DefaultMainMapCoordinator?
    
    /// Input
    struct Input {
        let participantsButtonTapped: Observable<Void>
    }
    
    // MARK: - Init
    init(coordinator: DefaultMainMapCoordinator) {
        self.coordinator = coordinator
    }
    
    // 바인딩 함수
    func bind(input: Input) {
        input.participantsButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.plansButtonTapped()
            })
            .disposed(by: disposeBag)
    }
    
    private func plansButtonTapped() {
        coordinator?.moveToPlanFromAlert(from: .fromAlert)
    }
}
