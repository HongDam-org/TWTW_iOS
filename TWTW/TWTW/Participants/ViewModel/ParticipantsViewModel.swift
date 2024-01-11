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
    private let service: ParticipantsProtocol
    /// Input
    struct Input {
        let changeLocationButtonTapped: ControlEvent<IndexPath>?
        let plusButtonEvents: ControlEvent<Void>?
    }
    
    struct Output {
        var participantsRelay: BehaviorRelay<[Friend]> = BehaviorRelay(value: [])
        var myLocationRelay: BehaviorRelay<SearchPlace?> = BehaviorRelay(value: nil)
    }
    
    // MARK: - Init
    init(coordinator: DefaultsParticipantsCoordinator, service: ParticipantsProtocol) {
        self.coordinator = coordinator
        self.service = service
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
        
       
        changeMyLocation(output: output)
        //dummyData(output: output)
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
//    private func dummyData(output: Output) {
//        let list = [ Friend(memberId: "1", nickname: "aa", participantsImage: ""),
//                     Friend(memberId: "1", nickname: "aa", participantsImage: ""),
//                     Friend(memberId: "1", nickname: "aa", participantsImage: ""),
//                     Friend(memberId: "1", nickname: "aa", participantsImage: ""),
//                     Friend(memberId: "1", nickname: "aa", participantsImage: ""),
//                     Friend(memberId: "1", nickname: "aa", participantsImage: "")]
//        
//        output.participantsRelay.accept(list)
//    }
//    
    // MARK: - API CONNECT
    
    /// 내위치 변경하기
    private func changeMyLocation(output: Output) {
        output.myLocationRelay
            .bind { [weak self] searchPlace in
                guard let self = self, let latitude = searchPlace?.latitude, let longitude = searchPlace?.longitude else { return }
                
                // 내위치 변경 API
                service.changeMyLocation(latitude: latitude, longitude: longitude)
                    .subscribe(onError: { error in
                        print(#function, error)
                    })
                    .disposed(by: disposeBag)
            }
            .disposed(by: disposeBag)
    }
}
