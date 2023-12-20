//
//  PlansFromAlertViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/18.
//

import RxCocoa
import RxRelay
import RxSwift
import UIKit

final class PlansFromAlertViewModel {
    private let disposeBag = DisposeBag()
    weak var coordinator: DefaultPlansFromAlertCoordinator?
    // 선택된 친구 목록을 저장하는 Relay
    private let selectedFriendsRelay = BehaviorRelay<[Friend]>(value: [])
    private let caller: SettingPlanCaller

    // 선택된 친구 목록을 외부에 공개하는 Observable
    var selectedFriendsObservable: Observable<[Friend]> {
        return selectedFriendsRelay.asObservable()
    }
    // 새로 선택된 목적지 명
    var newPlaceName: Observable<String> {
        return Observable.create { observer in
            if let newPlaceName = KeychainWrapper.loadItem(forKey: SearchPlaceKeyChain.placeName.rawValue) {
                       observer.onNext(newPlaceName)
                   } else {
                       observer.onNext(" ")
                   }
                   observer.onCompleted()
                   return Disposables.create()
               }
     }
    
    struct Input {
        // 1.달력버튼 클릭
        
        // 2. 친구추가 버튼 클릭
        let clickedAddParticipantsEvents: ControlEvent<Void>?
        // 3.저장 버튼 클릭
         let clickedConfirmEvents: ControlEvent<Void>?
    }
    
    struct Output {
        // 1.
        
        // 2.코디네이터로 친구코디네이터 이동
        
        // 3.
    }
    // MARK: - Init
    init(coordinator: DefaultPlansFromAlertCoordinator, caller: SettingPlanCaller = .forNew) {
        self.coordinator = coordinator
        self.caller = caller
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
        
        input.clickedConfirmEvents?
            .bind { [weak self] in
                guard let self = self else {return }
                moveToMain()
            }
            .disposed(by: disposeBag)
        
        return output
    }
    
    /// 친구추가화면으로
    func moveAddPrticipants() {
        coordinator?.addParticipants()
    }
    /// 초기화면으로
    func moveToMain() {
        coordinator?.moveToMain()
    }
    // 선택된 친구 목록을 업데이트하는 메서드
    func updateSelectedFriends(_ friends: [Friend]) {
        selectedFriendsRelay.accept(friends)
    }
}
