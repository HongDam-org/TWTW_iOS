//
//  CreateViewModel.swift
//  TWTW
//
//  Created by 정호진 on 11/28/23.
//

import RxCocoa
import RxRelay
import RxSwift

final class CreateGroupViewModel {
    var coordinator: CreateGroupCoordinatorProtocol
    private let disposeBag = DisposeBag()
    
    struct Input {
        let clickedAddFriendEvents: ControlEvent<Void>?
    }
    
    struct Output {
        let selectedFriendListRelay: BehaviorRelay<[Friend]> = BehaviorRelay<[Friend]>(value: [])
    }
    
    // MARK: - init
    init(coordinator: CreateGroupCoordinatorProtocol) {
        self.coordinator = coordinator
    }
    
    /// Create Output
    /// - Parameter input: Input
    /// - Returns: Output
    func createOutput(input: Input) -> Output {
        let output = Output()
        
        input.clickedAddFriendEvents?
            .bind { [weak self] in
                guard let self = self else { return }
                moveSelectedFriend(output: output)
            }
            .disposed(by: disposeBag)

        return output
    }
    
    /// move to selected friend page
    /// - Parameter output: Output
    private func moveSelectedFriend(output: Output) {
        coordinator.moveSelectedFriends(output: output)
    }
}
