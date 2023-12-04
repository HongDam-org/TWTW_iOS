//
//  FriendsListCoordinator.swift
//  TWTW
//
//  Created by 정호진 on 10/21/23.
//

import Foundation
import UIKit

protocol FriendsListCoordinatorProtocol: Coordinator {
    func sendSelectedFriends(output: FriendsListViewModel.Output)
}
