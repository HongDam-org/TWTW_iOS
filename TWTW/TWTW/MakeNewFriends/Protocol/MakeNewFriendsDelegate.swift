//
//  MakeNewFriendsDelegate.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/04.
//

import Foundation

protocol MakeNewFriendsDelegate: AnyObject {
    func sendData(selectedList: [Friend])
}
