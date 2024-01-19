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
        var inviteFriendRelay: BehaviorRelay<[Friend]> = BehaviorRelay(value: [])
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
        
        output.inviteFriendRelay
            .bind { [weak self] friendList in
                guard let self = self else {return}
                inviteFriends(output: output, inviteFriends: friendList)
            }
            .disposed(by: disposeBag)
        
        changeMyLocation(output: output)
        getGroupMemberList(output: output)
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
    
    
    /// 그룹 참여자들 불러오기
    /// - Parameter output: Output
    private func getGroupMemberList(output: Output) {
        service.getGroupFriends()
            .subscribe(onNext: { data in
                print(data)
                output.participantsRelay.accept(data)
            }, onError: { error in
                print(#function, error)
            })
            .disposed(by: disposeBag)
    }
    
    
    /// InviteFriend
    /// - Parameters:
    ///   - output: Output
    ///   - inviteFriends: 초대되는 친구들
    private func inviteFriends(output: Output, inviteFriends: [Friend]) {
        let groupService = GroupService()
        let groupId = KeychainWrapper.loadItem(forKey: "GroupId") ?? ""
        let members = inviteFriends.map { $0.memberId ?? "" }
        groupService.inviteGroup(inviteMembers: members, groupId: groupId)
            .subscribe(onNext: { group in
                print(group)
            }, onError: { error in
                print(#function, error)
            })
            .disposed(by: disposeBag)
    }
    
    
}
