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
    private let groupService: GroupProtocol
    
    struct Input {
        let clickedAddFriendEvents: ControlEvent<Void>?
        let groupTitleEvents: Observable<ControlProperty<String>.Element>?
        let clickedCreateButtonEvents: ControlEvent<Void>?
    }
    
    struct Output {
        let selectedFriendListRelay: BehaviorRelay<[Friend]> = BehaviorRelay<[Friend]>(value: [])
        let doneCreateGroupSubject: BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: false)
        let errorTextFieldSubject: BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: false)
        let failCreateGroupSubject: BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: false)
        let doneInviteGroupMemberSubject: BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: false)
        let failInviteGroupMemberSubject: BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: false)
    }
    
    // MARK: - init
    init(coordinator: CreateGroupCoordinatorProtocol, groupService: GroupProtocol) {
        self.coordinator = coordinator
        self.groupService = groupService
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
        
        if let createEvents = input.clickedCreateButtonEvents, let groupTitle = input.groupTitleEvents {
            Observable.combineLatest(createEvents, groupTitle)
                .bind { [weak self] _, title in
                    guard let self = self else { return }
                    if title != " " {
                        return createGroup(image: "", title: title, output: output)
                    }
                    output.errorTextFieldSubject.onNext(true)
                }
                .disposed(by: disposeBag)
        }
        return output
    }
    
    /// move to selected friend page
    /// - Parameter output: Output
    private func moveSelectedFriend(output: Output) {
        coordinator.moveSelectedFriends(output: output)
    }
    
    /// Move to Group page
    private func moveGroupList() {
        coordinator.moveGroupList()
    }
    
    // MARK: - API Connect
    
    /// Create Group
    /// - Parameters:
    ///   - image: Group Profile Image
    ///   - title: Group Title
    ///   - output: Output
    private func createGroup(image: String, title: String, output: Output) {
        groupService.createGroup(info: Group(groupId: nil,
                                             leaderId: nil,
                                             name: title,
                                             groupImage: "??",
                                             groupMembers: nil))
        .subscribe(onNext: { [weak self] group in
            guard let self = self else { return }
            output.doneCreateGroupSubject.onNext(true)
            inviteMember(groupId: group.groupId ?? "", output: output)
        }, onError: { error in
            output.failCreateGroupSubject.onNext(true)
            print(#function, error)
        })
        .disposed(by: disposeBag)
    }
    
    /// Invite Group Member
    /// - Parameters:
    ///   - groupId: group Id
    ///   - output: Output
    private func inviteMember(groupId: String, output: Output) {
        let list = output.selectedFriendListRelay.value.map { $0.memberId ?? "" }
        
        groupService.inviteGroup(inviteMembers: list, groupId: groupId)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                output.doneInviteGroupMemberSubject.onNext(true)
                moveGroupList()
            }, onError: { error in
                output.failInviteGroupMemberSubject.onNext(true)
                print(#function, error)
            })
            .disposed(by: disposeBag)
    }
}
