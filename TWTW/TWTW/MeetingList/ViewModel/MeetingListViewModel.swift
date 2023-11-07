//
//  MeetingListViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/13.
//

import Foundation
import UIKit

class MeetingListViewModel{
    var coordinator: DefaultMeetingListCoordinator
    
    init(coordinator: DefaultMeetingListCoordinator) {
        self.coordinator = coordinator
    }
    func buttonTapped(){
        coordinator.moveMainMap()
    }
    
}
