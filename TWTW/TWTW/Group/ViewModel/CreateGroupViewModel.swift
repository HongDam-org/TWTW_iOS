//
//  CreateViewModel.swift
//  TWTW
//
//  Created by 정호진 on 11/28/23.
//

import RxCocoa
import RxSwift

final class CreateGroupViewModel {
    var coordinator: CreateGroupCoordinatorProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - init
    init(coordinator: CreateGroupCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    
}
