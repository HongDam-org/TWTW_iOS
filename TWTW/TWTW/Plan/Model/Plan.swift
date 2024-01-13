//
//  Plan.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/01.
//

import UIKit

struct PlaceDetails: Codable {
    var placeName: String
    let placeUrl: String
    var roadAddressName: String
    let longitude: Double
    let latitude: Double
}

struct GroupInfo: Codable {
    let groupId: String
    let leaderId: String
    let name: String
    let groupImage: String
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
    let groupId: String?
    let leaderId: String?
    let name: String?
    let groupImage: String?
    let groupMembers: [Friend]?
    let members: [Friend]?
    let notJoinedMembers: [Friend]?
}

/// 그룹 저장
struct PlanSaveRequest: Codable {
    let name: String?
    let groupId: String?
    let planDay: String?
    var placeDetails: PlaceDetails
    let memberIds: [String?]
    
    mutating func encodePlaceDetails() {
         placeDetails.placeName = EncodedQueryConfig.encodedQuery(encodeRequest: placeDetails.placeName).getEncodedQuery()
         placeDetails.roadAddressName = EncodedQueryConfig.encodedQuery(encodeRequest: placeDetails.roadAddressName).getEncodedQuery()
     }
}

struct PlanSaveResponse: Codable {
    let planId: String?
    let groupId: String?
}
