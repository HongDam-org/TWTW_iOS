//
//  MakeNewFriendsListCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/03.
//

import Foundation
import UIKit

protocol MakeNewFriendsListCoordinatorProtocol: Coordinator {
    
    func sendSelectedNewFriends(output: MakeNewFriendsListViewModel.Output)
   
    func navigateBack()
}
