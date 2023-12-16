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
    weak var coordinator: DefaultParticipantsCoordinator?
    
    // MARK: - Init
    init(coordinator: DefaultParticipantsCoordinator) {
        self.coordinator = coordinator
    }
    func moveToSetLocationViewController() {
        coordinator?.moveToPartiSetLocation()
    }
}
