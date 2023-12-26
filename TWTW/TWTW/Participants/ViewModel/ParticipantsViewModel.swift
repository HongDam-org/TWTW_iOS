//
//  ParticipantsViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/08.
//

import Foundation
import RxCocoa
import RxRelay
import RxSwift
import UIKit

final class ParticipantsViewModel {
    private let disposeBag = DisposeBag()
    weak var coordinator: DefaultsParticipantsCoordinator?
    
    /// Input
    struct Input {
        let changeLocationButtonTapped: ControlEvent<IndexPath>?
        let plusButtonEvents: ControlEvent<Void>?
    }
    
    struct Output {
        var participantsRelay: BehaviorRelay<[Friend]> = BehaviorRelay(value: [])
    }
    
    // MARK: - Init
    init(coordinator: DefaultsParticipantsCoordinator) {
        self.coordinator = coordinator
    }
    
    /// bind
    func bind(input: Input) -> Output {
        let output = Output()
        input.changeLocationButtonTapped?
            .subscribe(onNext: { [weak self] _ in
                self?.changeLocationButtonTapped()
            })
            .disposed(by: disposeBag)
        
        input.plusButtonEvents?
            .bind { [weak self] in
                guard let self = self else {return}
                moveAddFriends(output: output)
            }
            .disposed(by: disposeBag)
        
        dummyData(output: output)
        return output
    }
    
    /// 화면이동
    private func changeLocationButtonTapped() {
        coordinator?.moveToChangeLocation()
    }
    
    /// move Add Friends
    private func moveAddFriends(output: Output) {
        coordinator?.moveAddNewFriends(output: output)
    }
    
    /// Create Dummy
    private func dummyData(output: Output) {
        let list = [ Friend(memberId: "1", nickname: "aa", participantsImage: ""),
                     Friend(memberId: "1", nickname: "aa", participantsImage: ""),
                     Friend(memberId: "1", nickname: "aa", participantsImage: ""),
                     Friend(memberId: "1", nickname: "aa", participantsImage: ""),
                     Friend(memberId: "1", nickname: "aa", participantsImage: ""),
                     Friend(memberId: "1", nickname: "aa", participantsImage: "")]
        
        output.participantsRelay.accept(list)
    }
}
