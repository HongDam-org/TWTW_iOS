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
        let searchBarEvents: ControlProperty<String?>?
        let selectedFriendsEvents: ControlEvent<IndexPath>?
    }
    
    struct Output {
        var friendListRelay: BehaviorRelay<[Friend]> = BehaviorRelay(value: [])
        var selectedFriendsRelay: BehaviorRelay<[Friend]> = BehaviorRelay(value: [])
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
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind { [weak self] word in
                guard let self = self, let word = word else { return }
                if !word.isEmpty {
                    searchingFriends(word: EncodedQueryConfig.encodedQuery(searchText: word).getEncodedQuery(),
                                     output: output)
                }
            }
            .disposed(by: disposeBag)

        input.selectedFriendsEvents?
            .bind { [weak self] indexPath in
                guard let self = self else { return }
                let member = output.friendListRelay.value[indexPath.row]
                var selectedList = output.selectedFriendsRelay.value
                let filter = selectedList.filter { $0 == member }
                
                if filter.isEmpty {
                    return selectedList.append(member)
                }
                selectedList.remove(at: selectedList.firstIndex(of: member) ?? 0)
            }
            .disposed(by: disposeBag)
        
        getAllFriends(output: output)
        return output
    }

    // MARK: - API Connect
    
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
    
    /// 닉네임으로 친구 검색
    /// - Parameters:
    ///   - word: 입력한 닉네임
    ///   - output: Output Model
    private func searchingFriends(word: String, output: Output) {
        friendService.searchingFriends(word: word)
            .subscribe(onNext: { list in
                print(#function, list)
                output.friendListRelay.accept(list)
            }, onError: { error in
                print(#function, error)
            })
            .disposed(by: disposeBag)
    }
}
