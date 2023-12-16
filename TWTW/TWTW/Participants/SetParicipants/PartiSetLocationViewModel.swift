//
//  PartiSetLocationViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/16.
//

import RxSwift
import UIKit

final class PartiSetLocationViewModel {
    private let disposeBag = DisposeBag()
    weak var coordinator: DefaultPartiSetLocationCoordinator?
    
    // MARK: - Init
    init(coordinator: DefaultPartiSetLocationCoordinator) {
        self.coordinator = coordinator
    }
    func moveToSetLocationViewController() {
    
    }
}
