//
//  PartiGetLocationViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/16.
//

import RxSwift
import UIKit

final class ParticipantsGetViewModel: PartiLocationViewModel {
    private let disposeBag = DisposeBag()
    
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
                guard let self = self, let coordinator = self.coordinator else { return }
                coordinator.moveToPartiGetLocation()
                
            })
            .disposed(by: disposeBag)
        
    }
}
