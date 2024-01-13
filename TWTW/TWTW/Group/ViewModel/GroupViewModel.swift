//
//  MeetingListViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/13.
//

import RxCocoa
import RxRelay
import RxSwift
import UIKit


final class GroupViewModel {
    var coordinator: DefaultGroupCoordinator
    private let disposeBag = DisposeBag()
    private let groupService: GroupProtocol
    
    struct Input {
        let clickedCreateGroupEvents: ControlEvent<Void>?
        let clickedTableViewItemEvents: ControlEvent<IndexPath>?
    }
    
    struct Output {
        /// 자신이 속한 그룹 리스트
        var groupListRelay: BehaviorRelay<[Group]> = BehaviorRelay(value: [])
        
        /// API 통신 에러 발생시
        var groupListErrorSubject: PublishSubject<Void> = PublishSubject<Void>()
    }
    
    // MARK: - init
    init(coordinator: DefaultGroupCoordinator, service: GroupProtocol) {
        self.coordinator = coordinator
        groupService = service
    }
    
    /// create Output
    /// - Parameter input: Input Model
    /// - Returns: Output Model
    func createOutput(input: Input) -> Output {
        let output = Output()
        
        input.clickedCreateGroupEvents?
            .bind { [weak self] in
                guard let self = self else { return }
                print("clicked createGroupBarButton")
                moveCreateGroup()
            }
            .disposed(by: disposeBag)
        
        input.clickedTableViewItemEvents?
            .bind { [weak self] indexPath in
                guard let self = self else { return }
                _ = KeychainWrapper.saveItem(value: output.groupListRelay.value[indexPath.row].groupId ?? "", forKey: "GroupId")
                print("GroupId🏘️ \(KeychainWrapper.loadItem(forKey: "GroupId"))")
                moveMainMap()
            }
            .disposed(by: disposeBag)
        
        myGroupList(output: output)
        return output
    }
    
    func reloadGroupList(output: Output) {
        myGroupList(output: output)
    }
    
    /// move mainMap
    func moveMainMap() {
        coordinator.moveMainMap()
    }
    
    /// move create group
    func moveCreateGroup() {
        coordinator.moveCreateGroup()
    }
        
    // MARK: - API Connect
    
    /// 내가 속한 그룹 리스트 받기
    private func myGroupList(output: Output) {
        groupService.groupList()
            .subscribe(onNext: { list in
                print(list)
                output.groupListRelay.accept(list)
            }, onError: { error in
                print(error)
                output.groupListErrorSubject.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
}
