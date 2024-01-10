//
//  NotificationViewModel.swift
//  TWTW
//
//  Created by 정호진 on 12/22/23.
//

import Foundation
import RxCocoa
import RxRelay
import RxSwift

final class NotificationViewModel {
    private let disposeBag = DisposeBag()
    private let coordinator: NotificationCoordinator
    
    // MARK: - init
    init(coordinator: NotificationCoordinator) {
        self.coordinator = coordinator
    }
    
    struct Input {
        let selectedCellEvents: ControlEvent<IndexPath>?
        
    }
    
    struct Output {
        let notificationListRelay: BehaviorRelay<[Notifications]> = BehaviorRelay(value: [])
    }
    
    /// Create Output
    /// - Parameter input: Input
    /// - Returns: Output
    func createOutput(input: Input) -> Output {
        let output = Output()
        
        input.selectedCellEvents?
            .bind { indexPath in
                
            }
            .disposed(by: disposeBag)
        
        bindNotificationListRelay(output: output)
        return output
    }
    
    /// Binding Notifiaction List
    private func bindNotificationListRelay(output: Output) {
        let list = [Notifications(type: "친구", id: "member2", name: "JJ1"),
                    Notifications(type: "친구", id: "member3", name: "JJ2"),
                    Notifications(type: "친구", id: "member4", name: "JJ3"),
                    Notifications(type: "친구", id: "member5", name: "JJ4")]
        
        output.notificationListRelay.accept(list)
    }
}
