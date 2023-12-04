//
//  MakeNewFriendsListViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/03.
//

import Foundation
import RxCocoa
import RxRelay
import RxSwift

final class MakeNewFriendsListViewModel {
    var coordinator: MakeNewFriendsListCoordinatorProtocol
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
    init(coordinator: MakeNewFriendsListCoordinatorProtocol, friendService: FriendService) {
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
                    return Observable.just([])
                } else {
                    self.getMakeNewFriends(searchText: word, output: output)
                    //self.getMakeNewFriends(searchText: word, output: output) //real API
                    return output.friendListRelay.asObservable()
                }
            }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: output.filteringFriendListRelay)
            .disposed(by: disposeBag)
        

//        input.selectedFriendsEvents?
//            .bind { [weak self] indexPath in
//                guard let self = self else { return }
//                var selectedFriends = output.selectedFriendRelay.value
//                let selectedFriend = output.filteringFriendListRelay.value[indexPath.row]
//                if let index = selectedFriends.firstIndex(of: selectedFriend) {
//                    selectedFriends.remove(at: index)
//                }
//                selectedFriends.append(selectedFriend)
//                output.selectedFriendRelay.accept(selectedFriends)
//            }
//            .disposed(by: disposeBag)
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

        return output
    }
    
    /// 그룹 생성 페이지로 이동
    /// - Parameter output: Output
    private func moveCreateFriend(output: Output) {
        print("선택된 친구들: \(output.selectedFriendRelay.value)")
        coordinator.sendSelectedNewFriends(output: output)
    }
    
    // MARK: - API Connect
    
    /// 새로운 친구 목록 로딩
    /// - Parameter output: output
    private func getMakeNewFriends(searchText: String, output: Output) {
        
//        // Real API Call
//        friendService.searchingFriends(word: searchText)
//            .subscribe(onNext: { friends in
//                output.friendListRelay.accept(friends)
//            }, onError: { error in
//                print(error)
//            }).disposed(by: disposeBag)
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
                    Friend(memberId: "aasd12", nickname: "12")
        ]
        output.friendListRelay.accept(list)

    }
}
