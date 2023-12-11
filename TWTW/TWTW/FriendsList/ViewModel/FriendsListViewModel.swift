//
//  FriendsListViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/03.
//

import Foundation
import RxCocoa
import RxRelay
import RxSwift

/// 친구 전체 목록
final class FriendsListViewModel {
    var coordinator: DefaultFriendsListCoordinator
    private let friendService: FriendProtocol
    private let disposeBag = DisposeBag()
    
    
    struct Input {
        let searchBarEvents: Observable<String>?
        let selectedFriendsEvents: ControlEvent<IndexPath>?
        let clickedAddButtonEvents: ControlEvent<Void>?
    }
    
    struct Output {
        var friendListRelay: BehaviorRelay<[Friend]> = BehaviorRelay(value: [])
        var filteringFriendListRelay: BehaviorRelay<[Friend]> = BehaviorRelay(value: [])
        var selectedFriendRelay: BehaviorRelay<[Friend]> = BehaviorRelay(value: [])
    }
    
    // MARK: - init
    init(coordinator: DefaultFriendsListCoordinator, friendService: FriendProtocol) {
        self.coordinator = coordinator
        self.friendService = friendService
    }
    
    /// create Output
    /// - Parameter input: Input Model
    /// - Returns: Output Model
    func createOutput(input: Input) -> Output {
        let output = Output()
        input.searchBarEvents?
            .flatMapLatest { word -> Observable<[Friend]> in
                if word.isEmpty {
                    return output.friendListRelay.asObservable()
                }
                return output.friendListRelay.asObservable().map { $0.filter { $0.nickname?.hasPrefix(word) ?? false}}
            }
            .bind(to: output.filteringFriendListRelay)
            .disposed(by: disposeBag)
        input.clickedAddButtonEvents?
            .bind { [weak self] _ in
                guard let self = self else { return }
                moveMakeNewFriends()
            }.disposed(by: disposeBag)
        
        getAllFriends(output: output)
        return output
    }
    
    /// move MakeNewFriends
    func moveMakeNewFriends() {
        coordinator.makeNewFriends()
    }
    
    /// 전체 친구 목록 로딩
    /// - Parameter output: output
    private func getAllFriends(output: Output) {

        friendService.getAllFriends()
            .subscribe(onNext: { list in
                print(#function, list)
                output.friendListRelay.accept(list)
            }, onError: { error in
                print(#function, error)
            })
            .disposed(by: disposeBag)
    }
}
