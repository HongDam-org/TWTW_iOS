//
//  ParticipantsViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/08.
//

import Foundation
import RxCocoa
import RxSwift

final class ParticipantsViewModel {
    private let disposeBag = DisposeBag()
    weak var coordinator: DefaultsParticipantsCoordinator?
    
    /// Input
    struct Input {
        let changeLocationButtonTapped: Observable<Void>
    }
    
    // MARK: - Init
    init(coordinator: DefaultsParticipantsCoordinator) {
        self.coordinator = coordinator
    }
    
    /// bind
    func bind(input: Input) {
        input.changeLocationButtonTapped
            .subscribe(onNext: {[weak self] in
                self?.changeLocationButtonTapped()
            })
            .disposed(by: disposeBag)
    }
    /// 화면이동
    private func changeLocationButtonTapped() {
        coordinator?.moveToChangeLocation()
    }
}
