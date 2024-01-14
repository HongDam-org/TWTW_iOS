//
//  Participants.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/01.
//

import UIKit

struct PlanResponse: Codable {
    let planId: String
    let placeId: String
    let planMakerId: String
    let planDay: String
    let placeDetails: PlaceDetails
    let groupInfo: GroupforPlanInfo
    let members: [Friend]
}

struct GroupforPlanInfo: Codable {
    let groupId: String
    let leaderId: String
    let name: String
    let groupImage: String
    let groupMembers: [Friend]
}
