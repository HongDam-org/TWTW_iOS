//
//  RoadViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/21.
//

import Foundation
import RxSwift
import UIKit

final class RoadViewModel {
    private let disposeBag = DisposeBag()
    weak var coordinator: DefaultsRoadViewCoordinator?
    
    // MARK: - Init
    init(coordinator: DefaultsRoadViewCoordinator) {
        self.coordinator = coordinator
    }
}
