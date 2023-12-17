//
//  MakeNewMeetingViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/17.
//

import RxSwift
import UIKit

final class MakeNewMeetingViewModel {
    private let disposeBag = DisposeBag()
    weak var coordinator: DefaultMakeNewMeetingCoordinator?
    
    // MARK: - Init
    init(coordinator: DefaultMakeNewMeetingCoordinator) {
        self.coordinator = coordinator
    }
    
    func moveToGetLocationViewController() {
        print("get")
    }
}
