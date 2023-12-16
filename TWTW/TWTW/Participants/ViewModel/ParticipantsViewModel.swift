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
    weak var coordinator: DefaultParticipantsCoordinator?
  
    
    // MARK: - Init
    init(coordinator: DefaultParticipantsCoordinator) {
        self.coordinator = coordinator
    }
}

class PartiLocationViewModel {   
    weak var coordinator: DefaultParticipantsCoordinator?

}
