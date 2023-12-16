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
  
    
    // MARK: - Init
    init(coordinator: DefaultsParticipantsCoordinator) {
        self.coordinator = coordinator
    }
}
class PartiLocationViewModel {
  
}
