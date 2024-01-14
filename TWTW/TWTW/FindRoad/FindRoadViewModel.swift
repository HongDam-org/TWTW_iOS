//
//  FindRoadViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/18.
//

import RxCocoa
import RxRelay
import RxSwift
import UIKit

final class FindRoadViewModel {
    private let disposeBag = DisposeBag()
    weak var coordinator: DefaultsFindRoadCoordinator?
    
    
    struct Input {
        // 3.길찾기 버튼
        let clickedConfirmEvents: ControlEvent<Void>?
    }
    
    struct Output {
    }
    // MARK: - Init
    init(coordinator: DefaultsFindRoadCoordinator) {
        self.coordinator = coordinator
    }
    
    // create Output
    /// - Parameter input: Input Model
    /// - Returns: Output Model
    func createOutput(input: Input) -> Output {
        let output = Output()
      
        input.clickedConfirmEvents?
            .bind { [weak self] in
                guard let self = self else { return }
                moveToFindRoad()
            }
            .disposed(by: disposeBag)
        
        return output
    }
    /// 길찾기 화면으로
    func moveToFindRoad() {
        coordinator?.start()
    }
    
}
