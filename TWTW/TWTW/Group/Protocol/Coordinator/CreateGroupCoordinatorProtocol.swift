//
//  CreateGroupCoordinatorProtocol.swift
//  TWTW
//
//  Created by 정호진 on 11/29/23.
//

import Foundation
import RxSwift

protocol CreateGroupCoordinatorProtocol: BaseTabBarCoodinator {
    /// move Selected Friends Page
    func moveSelectedFriends(output: CreateGroupViewModel.Output)
}
