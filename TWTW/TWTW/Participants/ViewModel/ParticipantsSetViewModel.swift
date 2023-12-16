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

    struct Input {
        let selectedPlace: Observable<Participant>
        let addButtonTapped: Observable<Void>

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
        
        input.addButtonTapped
            .bind(onNext: { [weak self] in
                self?.coordinator?.moveToMakeNewMeeting()
            })
            .disposed(by: disposeBag)
    }
    
}
