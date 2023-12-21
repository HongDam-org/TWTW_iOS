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
                }
                return self.searchMakeNewFriends(searchText: word)
            }
            .observe(on: MainScheduler.asyncInstance)
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
        
        return output
    }
    
    /// 그룹 생성 페이지로 이동
    /// - Parameter output: Output
    private func moveCreateFriend(output: Output) {
        print("선택된 친구들: \(output.selectedFriendRelay.value)")
        output.selectedFriendRelay.value.forEach { friend in
            friendService.requestFriends(memberId: friend.memberId ?? "")
                .subscribe(
                    onError: { error in
                        print("에러 발생: \(error)")
                    }, onCompleted: {
                        print("친구 신청 성공")
                        
                    })
                .disposed(by: disposeBag)
        }
        coordinator.navigateBack()
    }
    
    // MARK: - API Connect
    
    /// 새로운 친구 목록 로딩
    /// - Parameter output: output
    private func searchMakeNewFriends(searchText: String) -> Observable<[Friend]> {
        
        // Real API Call
        if searchText.isEmpty {
            return Observable.just([])
        }
        return friendService.searchingFriends(word: searchText)
            .catchAndReturn([])
    }
}
