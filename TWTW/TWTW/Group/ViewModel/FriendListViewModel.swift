//
//  FriendListViewModel.swift
//  TWTW
//
//  Created by 정호진 on 11/28/23.
//

import RxCocoa
import RxRelay
import RxSwift

final class FriendListViewModel {
    var coordinator: CreateGroupCoordinatorProtocol
    private let disposeBag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        var friendListRelay: BehaviorRelay<[Friend]> = BehaviorRelay(value: [])
    }
    
    // MARK: - init
    init(coordinator: CreateGroupCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    
    /// create Output
    /// - Parameter input: Input Model
    /// - Returns: Output Model
    func createOutput(input: Input) -> Output {
        let output = Output()
        
        return output
    }
    
    
    // MARK: - API Connect
    
}
