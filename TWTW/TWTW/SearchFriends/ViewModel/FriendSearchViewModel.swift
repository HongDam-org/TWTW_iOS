//
//  FriendListViewModel.swift
//  TWTW
//
//  Created by 정호진 on 11/28/23.
//

import Foundation
import RxCocoa
import RxRelay
import RxSwift


final class FriendSearchViewModel {
    var coordinator: FriendSearchCoordinatorProtocol
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
    init(coordinator: FriendSearchCoordinatorProtocol, friendService: FriendProtocol) {
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
        
        input.clickedAddButtonEvents?
            .bind { [weak self] in
                guard let self = self else { return }
                moveCreateFriend(output: output)
            }
            .disposed(by: disposeBag)
        
        getAllFriends(output: output)
        return output
    }
    
    /// 그룹 생성 페이지로 이동
    /// - Parameter output: Output
    private func moveCreateFriend(output: Output) {
        coordinator.sendSelectedFriends(output: output)
    }

    // MARK: - API Connect
    
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
      //  friendService.searchingFriends(word: <#T##String#>)

    }

}
