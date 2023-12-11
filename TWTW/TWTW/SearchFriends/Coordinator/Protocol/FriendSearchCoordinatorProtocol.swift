//
//  FriendSearchCoordinatorProtocol.swift
//  TWTW
//
//  Created by 정호진 on 12/1/23.
//

import Foundation

protocol FriendSearchCoordinatorProtocol: Coordinator {
    func sendSelectedFriends(output: FriendSearchViewModel.Output)
}
