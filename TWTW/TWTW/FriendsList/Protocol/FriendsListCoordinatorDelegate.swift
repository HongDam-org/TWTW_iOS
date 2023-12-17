//
//  FriendsListCoordinatorDelegate.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/17.
//

import Foundation

protocol FriendsSendListCoordinatorDelegate: AnyObject {
    func didSelectFriends(_ friends: [Friend])
}
