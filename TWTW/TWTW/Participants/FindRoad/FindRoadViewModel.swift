//
//  FindRoadViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/18.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

final class FindRoadViewModel {
    private let disposeBag = DisposeBag()
    weak var coordinator: DefaultsFindRoadCoordinator?
    
    struct Input {
        let myLocationTap: Observable<Void>
    }

    // MARK: - Init
    init(coordinator: DefaultsFindRoadCoordinator) {
        self.coordinator = coordinator
    }
    
    ///  bind
    func bind(input: Input) {
        input.myLocationTap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                coordinator?.moveToStartSearchPlace()
            })
            .disposed(by: disposeBag)
   
    }
}
