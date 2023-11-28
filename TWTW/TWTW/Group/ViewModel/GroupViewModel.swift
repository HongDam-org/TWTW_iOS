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
        let clickedAlertEvenets: ControlEvent<Void>?
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
        
        input.clickedAlertEvenets?
            .bind {
                print("clicked Alert")
            }
            .disposed(by: disposeBag)
        
        input.clickedCreateGroupEvents?
            .bind {
                print("clicked createGroupBarButton")
            }
            .disposed(by: disposeBag)
        
        input.clickedTableViewItemEvents?
            .bind { [weak self] indexPath in
                guard let self = self else { return }
                moveMainMap()
            }
            .disposed(by: disposeBag)
        
        myGroupList(output: output)
        return output
    }
    
    /// move mainMap
    func moveMainMap() {
        coordinator.moveMainMap()
    }
        
    // MARK: - API Connect
    
    /// 내가 속한 그룹 리스트 받기
    private func myGroupList(output: Output) {
        groupService.groupList()
            .subscribe(onNext: { list in
                output.groupListRelay.accept(list)
            }, onError: { error in
                print(error)
                output.groupListErrorSubject.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
}
