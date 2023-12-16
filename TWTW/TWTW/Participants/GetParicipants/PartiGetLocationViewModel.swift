//
//  PartiGetLocationViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/16.
//

import RxSwift
import UIKit

final class PartiGetLocationViewModel {
    private let disposeBag = DisposeBag()
    weak var coordinator: DefaultPartiGetLocationCoordinator?
    
    // MARK: - Init
    init(coordinator: DefaultPartiGetLocationCoordinator) {
        self.coordinator = coordinator
    }
    
    func moveToGetLocationViewController() {
        print("get")
    }
}
