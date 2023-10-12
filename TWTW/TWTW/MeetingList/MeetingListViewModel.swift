//
//  MeetingListViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/13.
//

import Foundation
import UIKit

class MeetingListViewModel{
    var coordinator: MeetingListCoordinator
    
    init(coordinator: MeetingListCoordinator) {
        self.coordinator = coordinator
    }
    func buttonTapped(){
        coordinator.buttonTapped()
    }
    
}
