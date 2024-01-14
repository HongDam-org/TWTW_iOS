//
//  ParticipantsCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/11/30.
//

import Foundation

protocol ParticipantsCoordinator: Coordinator {
    /// 선택한 사람 장소 바꾸기
    func moveToChangeLocation()
    
    /// Add New Friends In Group
    func moveAddNewFriends(output: ParticipantsViewModel.Output) 
}
