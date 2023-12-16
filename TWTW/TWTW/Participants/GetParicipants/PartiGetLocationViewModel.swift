//
//  PartiGetLocationViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/16.
//

import RxSwift
import UIKit

final class PartiGetLocationViewModel: PartiLocationViewModel {
    private let disposeBag = DisposeBag()
    weak var coordinator: DefaultsParticipantsCoordinator?
    
    
    // MARK: - Init
    init(coordinator: DefaultsParticipantsCoordinator) {
        self.coordinator = coordinator
    }
    
    func moveToGetLocationViewController() {
        print("get")
    }
}
