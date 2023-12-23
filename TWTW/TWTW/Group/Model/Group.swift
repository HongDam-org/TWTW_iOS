//
//  Group.swift
//  TWTW
//
//  Created by 정호진 on 11/28/23.
//

import Foundation

/// 그룹
struct Group: Codable {
    let groupId: String?
    let leaderId: String?
    let name: String?
    let groupImage: String?
}

/// 그룹단건조회
struct GroupLookUpRequest: Codable {
    let groupId: String?
}

