//
//  FriendSearchDelegate.swift
//  TWTW
//
//  Created by 정호진 on 12/2/23.
//

import Foundation

protocol FriendSearchDelegate: AnyObject {
    func sendData(selectedList: [Friend])
}
