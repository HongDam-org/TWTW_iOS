//
//  Domain.swift
//  TWTW
//
//  Created by 정호진 on 2023/09/16.
//

import Foundation

enum SearchPath: String {
    case placeAndCategory = "/plans/search/destination?query=encodedQuery&longitude=LONGITUDE&latitude=LATITUDE&page=pageNum&categoryGroupCode=NONE"
    case nearByPlace = "/places/surround?longitude=LONGITUDE&latitude=LATITUDE&page=pageNum"
}

enum LoginPath: String {
    case signUp = "/auth/save"
    case signIn = "/auth/login"
    case updateToken = "/auth/refresh"
    case checkValidation = "/auth/validate"
    case checkOverlapId = "/member/duplicate/Id"
}

enum RoutePath: String {
    case car = "/paths/search/car"
    case ped = "/paths/search/ped"
}

enum GroupPath: String {
    case group = "/group" // 그룹생성
    case invite = "/group/invite"
    case join = "/group/join"
    case lookUpGroup = "/group/GROUPID" // 그룹 단건조회
    case changeMyLocation = "/group/location"
}

enum FriendPath: String {
    case all = "/friends/all"
    case search = "/friends/search?nickname=NAME"
    case request = "/friends/request"
    case notFriendSearch = "/member?nickname=NAME"
    case status = "/friends/status"
}

enum ParticipantsPath: String {
    case all = "/plans/PLANID" // 그룹 모든 친구, 그룹 + plan
    case not = "/plans/"// 그룹 + !plan 조회
    case request = "/plans/yet" // 그룹 + !plan 요청
}

enum PlanPath: String {
    case all = "/plans/PLANID" // Plan 단건 조회
    case save = "/plans" // plan 저장
}
