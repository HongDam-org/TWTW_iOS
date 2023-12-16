//
//  PartiSetLocationViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/16.
//

import RxSwift
import UIKit

final class ParticipantsSetViewModel: PartiLocationViewModel {
    private let disposeBag = DisposeBag()
   // weak var coordinator: DefaultParticipantsCoordinator?
    
    struct Input {
        let selectedPlace: Observable<Participant>
    }

    // MARK: - Init
    init(coordinator: DefaultParticipantsCoordinator) {
        super.init()
        self.coordinator = coordinator
    }

    func bind(input: Input) {
        input.selectedPlace
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                coordinator?.moveToPartiSetLocation()
                
            })
            .disposed(by: disposeBag)
    }
}
