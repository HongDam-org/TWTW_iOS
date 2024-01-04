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
        let notificationListRelay: BehaviorRelay<[String]> = BehaviorRelay(value: [])
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
        let list = ["aaaa",
                    "bbbb",
                    "cccc",
                    "dddd"]
        
        output.notificationListRelay.accept(list)
    }
}