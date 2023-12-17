//
//  PartiSetLocationViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/16.
//

import RxCocoa
import RxRelay
import RxSwift
import UIKit

final class PartiSetLocationViewModel {
    private let disposeBag = DisposeBag()
    weak var coordinator: DefaultPartiSetLocationCoordinator?
    // 선택된 친구 목록을 저장하는 Relay
        private let selectedFriendsRelay = BehaviorRelay<[Friend]>(value: [])

        // 선택된 친구 목록을 외부에 공개하는 Observable
        var selectedFriendsObservable: Observable<[Friend]> {
            return selectedFriendsRelay.asObservable()
        }

   
    struct Input {
        // 1.달력버튼 클릭
        
        // 2. 친구추가 버튼 클릭
        let clickedAddParticipantsEvents: ControlEvent<Void>?
        // 3.저장 버튼 클릭
       // let clickedSaveEvents: ControlEvent<Void>?
    }
    
    struct Output {
        // 1.
        
        // 2.코디네이터로 친구코디네이터 이동
        
        // 3.
    }
    // MARK: - Init
    init(coordinator: DefaultPartiSetLocationCoordinator) {
        self.coordinator = coordinator
    }
    
    // create Output
    /// - Parameter input: Input Model
    /// - Returns: Output Model
    func createOutput(input: Input) -> Output {
        let output = Output()
        input.clickedAddParticipantsEvents?
            .bind { [weak self] in
                guard let self = self else { return }
                moveAddPrticipants()
            }
            .disposed(by: disposeBag)
        
    return output
    }
    
    func moveToSetLocationViewController() {
    }
    
    func moveAddPrticipants() {
        coordinator?.addParticipants()
    }
    // 선택된 친구 목록을 업데이트하는 메서드
    func updateSelectedFriends(_ friends: [Friend]) {
        selectedFriendsRelay.accept(friends)
    }
}
