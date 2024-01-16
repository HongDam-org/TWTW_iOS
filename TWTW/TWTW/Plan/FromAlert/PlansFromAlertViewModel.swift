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
    
    private let selectedFriendsRelay = BehaviorRelay<[Friend]>(value: [])
    private let caller: SettingPlanCaller
    
    var selectedFriendsObservable: Observable<[Friend]> {
        return selectedFriendsRelay.asObservable()
    }
    private let currentPlanSubject = BehaviorSubject<Plan?>(value: nil)

    struct Input {
        let clickedAddParticipantsEvents: ControlEvent<Void>?
        let clickedConfirmEvents: ControlEvent<Void>?
        // 약속명
        let meetingName: Observable<String>
        // 장소명
        let originPlaceName: Observable<String>
        // 날짜,시간
        let selectedDate: Observable<String>
        // 친구
        let selectedFriends: Observable<[Friend]>
        
    }
    
    struct Output {
        let meetingName: Observable<String>
        let originPlaceName: Observable<String>
        let selectedDate: Observable<String>
        let selectedFriends: Observable<[Friend]>
        let callerState: SettingPlanCaller
    }
    
    init(coordinator: DefaultPlansFromAlertCoordinator, service: PlanService,
         caller: SettingPlanCaller = .forNew) {
        self.coordinator = coordinator
        planService = service
        self.caller = caller
    }
    func createOutput() -> Output {
            // 초기 데이터 설정
        let initialMeetingName = currentPlanSubject
                   .map { $0?.name ?? "약속 명" }
                   .asObservable()

               let initialOriginPlaceName = currentPlanSubject
                   .map { $0?.placeDetails.placeName ?? "장소 명" }
                   .asObservable()

               let initialSelectedDate = currentPlanSubject
                   .map { $0?.planDay ?? "날짜" }
                   .asObservable()

               let initialSelectedFriends = BehaviorSubject<[Friend]>(value: [])

               return Output(
                   meetingName: initialMeetingName,
                   originPlaceName: initialOriginPlaceName,
                   selectedDate: initialSelectedDate,
                   selectedFriends: initialSelectedFriends.asObservable(),
                   callerState: self.caller
               )
           }
    
    func createOutput(input: Input) -> Output {
        getAndPrintPlanDetails()
        let output = Output(
               meetingName: input.meetingName,
               originPlaceName: input.originPlaceName,
               selectedDate: input.selectedDate.map { $0.components(separatedBy: " ").first ?? "" },
               selectedFriends: input.selectedFriends,
               callerState: self.caller
           )

        let newPlaceNameObservable = input.originPlaceName
            .map { placeName in
                return placeName
            }
    
        input.clickedAddParticipantsEvents?
            .bind { [weak self] in
                guard let self = self else { return }
                self.coordinator?.addParticipants()
            }
            .disposed(by: disposeBag)

        input.clickedConfirmEvents?
            .bind { [weak self] in
                guard let self = self else { return }

                Observable.combineLatest(input.meetingName, input.selectedDate, input.selectedFriends)
                    .take(1)
                    .subscribe(onNext: { [weak self] (meetingName: String, selectedDateTime: String, selectedFriends: [Friend]) in
                        guard let self = self else { return }
                        
                        let groupId = (KeychainWrapper.loadItem(forKey: "GroupId"))
                        let placeDetails = self.createPlaceDetailsFromKeychain()

                        let memberIds = selectedFriends.compactMap { $0.memberId }

                        let planSaveRequest = PlanSaveRequest(
                            name: meetingName,
                            groupId: groupId ?? "",
                            planDay: selectedDateTime,
                            placeDetails: placeDetails,
                            memberIds: memberIds
                        )

                        self.savePlan(request: planSaveRequest)
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        return output
    }
    
    private func createPlaceDetailsFromKeychain() -> PlaceDetails {
         let placeName = KeychainWrapper.loadItem(forKey: SearchPlaceKeyChain.placeName.rawValue) ?? ""
         let placeUrl = KeychainWrapper.loadItem(forKey: SearchPlaceKeyChain.placeURL.rawValue) ?? ""
         let roadAddressName = KeychainWrapper.loadItem(forKey: SearchPlaceKeyChain.roadAddressName.rawValue) ?? ""
         let longitude = Double(KeychainWrapper.loadItem(forKey: SearchPlaceKeyChain.longitude.rawValue) ?? "0") ?? 0.0
         let latitude = Double(KeychainWrapper.loadItem(forKey: SearchPlaceKeyChain.latitude.rawValue) ?? "0") ?? 0.0

         return PlaceDetails(placeName: placeName, 
                             placeUrl: placeUrl,
                             roadAddressName: roadAddressName,
                             longitude: longitude,
                             latitude: latitude)
     }
    func moveAddPrticipants() {
        coordinator?.addParticipants()
    }
    
    private func savePlan(request: PlanSaveRequest) {
        guard let groupID = request.groupId,
                  let meetingName = request.name,
                  let selectedDate = request.planDay else {
                print("Error: nil")
                return
            }
        
    let placeDetails = request.placeDetails
    let memberIds = request.memberIds.compactMap { $0 }
        
    let planSaveRequest = PlanSaveRequest(
               name: meetingName,
               groupId: groupID,
               planDay: selectedDate,
               placeDetails: placeDetails,
               memberIds: request.memberIds
           )

        planService.savePlanService(request: planSaveRequest)
            .subscribe(onNext: { [weak self] response in
                print("Plan saved: \(response)")
                self?.coordinator?.moveToMain()
            }, onError: { error in
                print("Error saving plan: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    func getAndPrintPlanDetails() {
            let planID = KeychainWrapper.loadItem(forKey: "PlanID") ?? ""
            planService.getPlanService(request: planID)
                .subscribe(onNext: { [weak self] plan in
                    self?.currentPlanSubject.onNext(plan)

                    print("\(plan.name)")
                    print("\(plan.planDay)")
                    print("\(plan.placeDetails.placeName)")

                    print("\(plan.name)")

                }, onError: { error in
                    print("Error: \(error)")
                })
                .disposed(by: disposeBag)
        }
    
    func updateSelectedFriends(_ friends: [Friend]) {
        selectedFriendsRelay.accept(friends)
    }
}
