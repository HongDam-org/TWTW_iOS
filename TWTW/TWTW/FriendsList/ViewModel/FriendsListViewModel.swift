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
    private let caller: Caller
    
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
    init(coordinator: DefaultFriendsListCoordinator, friendService: FriendProtocol, caller: Caller = .fromTabBar) {
        self.coordinator = coordinator
        self.friendService = friendService
        self.caller = caller
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
        
        if caller == .fromPartiSetLocation {
            input.selectedFriendsEvents?
                .bind { indexPath in
                    var select = output.selectedFriendRelay.value
                    output.filteringFriendListRelay.accept(output.filteringFriendListRelay.value)
                    
                    if select.contains(output.filteringFriendListRelay.value[indexPath.row]) {
                        select.remove(at: select.firstIndex(of: output.filteringFriendListRelay.value[indexPath.row]) ?? 0)
                        output.selectedFriendRelay.accept(select)
                        return
                    }
                    select.append(output.filteringFriendListRelay.value[indexPath.row])
                    output.selectedFriendRelay.accept(select)
                }
                .disposed(by: disposeBag)
        }
        
        input.clickedAddButtonEvents?
            .bind { [weak self] _ in
                guard let self = self else { return }
                switch self.caller {
                case .fromPartiSetLocation:
                    // PartiSetLocation에서 호출된 경우의 동작
//                    print("Selected friends: \(output.selectedFriendRelay.value)")
                    coordinator.navigateBackWithSelectedFriends(output.selectedFriendRelay.value)

                case .fromTabBar:
                    // 탭바에서 호출된 경우의 동작
                    print("친구 추가 - 탭바에서 호출됨")
                    self.coordinator.makeNewFriends()
                }
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
            let list = [Friend(memberId: "aasd1", nickname: "1"),
                        Friend(memberId: "aasd2", nickname: "2"),
                        Friend(memberId: "aasd3", nickname: "3"),
                        Friend(memberId: "aasd4", nickname: "4"),
                        Friend(memberId: "aasd5", nickname: "5"),
                        Friend(memberId: "aasd6", nickname: "6"),
                        Friend(memberId: "aasd7", nickname: "7"),
                        Friend(memberId: "aasd8", nickname: "8"),
                        Friend(memberId: "aasd9", nickname: "9"),
                        Friend(memberId: "aasd10", nickname: "10"),
                        Friend(memberId: "aasd11", nickname: "11"),
                        Friend(memberId: "aasd12", nickname: "12")]
            
            output.friendListRelay.accept(list)
            
//        friendService.getAllFriends()
//            .subscribe(onNext: { list in
//                print(#function, list)
//                output.friendListRelay.accept(list)
//            }, onError: { error in
//                print(#function, error)
//            })
//            .disposed(by: disposeBag)
    }
}
