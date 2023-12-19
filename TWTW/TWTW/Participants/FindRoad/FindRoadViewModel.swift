//
//  FindRoadViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/18.
//

import Foundation
import RxSwift
import UIKit

final class FindRoadViewModel {
    private let disposeBag = DisposeBag()
    weak var coordinator: DefaultsFindRoadCoordinator?
    
    // MARK: - Init
    init(coordinator: DefaultsFindRoadCoordinator) {
        self.coordinator = coordinator
    }
    
    func moveToGetLocationViewController() {
        print("get")
    }
}
