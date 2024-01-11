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
    private let planService: PlanService
    weak var coordinator: DefaultPlansFromAlertCoordinator?

    // 선택된 친구 목록을 저장하는 Relay
    private let selectedFriendsRelay = BehaviorRelay<[Friend]>(value: [])
    private let caller: SettingPlanCaller

    // 선택된 친구 목록을 외부에 공개하는 Observable
    var selectedFriendsObservable: Observable<[Friend]> {
        return selectedFriendsRelay.asObservable()
    }

    struct Input {
        let clickedAddParticipantsEvents: ControlEvent<Void>?
        let clickedConfirmEvents: ControlEvent<Void>?
        // 약속명
        let meetingName: Observable<String>
        // 장소관련
        let placeDetails: Observable<PlaceDetails>
        // 날짜,시간
        let selectedDate: Observable<Date>
        // 친구
        let selectedFriends: Observable<[Friend]>
    }
    
    struct Output {
        let newPlaceName: Observable<String>
        let callerState: SettingPlanCaller
    }
    
    // MARK: - Init
    init(coordinator: DefaultPlansFromAlertCoordinator, service: PlanService,
         caller: SettingPlanCaller = .forNew) {
        self.coordinator = coordinator
        planService = service
        self.caller = caller
    }
  
    // create Output
    /// - Parameter input: Input Model
    /// - Returns: Output Model
    func createOutput(input: Input) -> Output {
        let newPlaceNameObservable = Observable.create { observer in
                   if let newPlaceName = KeychainWrapper.loadItem(forKey: SearchPlaceKeyChain.placeName.rawValue) {
                       observer.onNext(newPlaceName)
                   } else {
                       observer.onNext(" ")
                   }
                   observer.onCompleted()
                   return Disposables.create()
               }
        
        let output = Output(newPlaceName: newPlaceNameObservable, callerState: caller)
        
        /// 친구추가
        input.clickedAddParticipantsEvents?
            .bind { [weak self] in
                guard let self = self else { return }
                moveAddPrticipants()
            }
            .disposed(by: disposeBag)
        
        /// 확인버튼
        input.clickedConfirmEvents?
            .bind { [weak self] in
                guard let self = self else {return }
                moveToMain(input: input)
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
        planService.savePlanService(request: planSaveRequest)
                    .subscribe(onNext: { [weak self] response in
                        // Handle success response
                        print("Plan save ")
                        self?.coordinator?.moveToMain()
                    }, onError: { error in
                        // Handle error
                        print(" \(error)")
                    })
                    .disposed(by: disposeBag)
        coordinator?.moveToMain()
    }

       private func savePlan(request: PlanSaveRequest) {
           planService.savePlanService(request: request)
               .subscribe(onNext: { [weak self] response in
                   print("Plan saved: \(response)")
                   self?.coordinator?.moveToMain()
               }, onError: { error in
                   print("Error saving plan: \(error)")
               })
               .disposed(by: disposeBag)
       }

    // 선택된 친구 목록을 업데이트하는 메서드
    func updateSelectedFriends(_ friends: [Friend]) {
        selectedFriendsRelay.accept(friends)
    }
}
