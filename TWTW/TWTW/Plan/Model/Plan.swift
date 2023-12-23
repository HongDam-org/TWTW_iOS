//
//  Plan.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/01.
//

import UIKit

struct PlaceDetails: Codable {
    let placeName: String
    let placeUrl: String
    let roadAddressName: String
    let longitude: Double
    let latitude: Double
}

struct GroupInfo: Codable {
    let groupId: String
    let leaderId: String
    let name: String
    let groupImage: String
}

struct Member: Codable {
    let id: String
    let nickname: String
}
/// 계획 단건 조회
struct Plan: Codable {
    let planId: String
    let placeId: String
    let planMakerId: String
    let placeDetails: PlaceDetails
    let groupInfo: GroupInfo
    let members: [Friend]
}

/// 그룹 단건 조회
struct GroupLookUpInfo: Codable {
    let groupId: String
    let leaderId: String
    let name: String
    let groupImage: String
    let groupMembers: [Friend]
}
