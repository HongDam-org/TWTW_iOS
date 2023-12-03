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
}

enum GroupPath: String {
    case groupList = "/group"
}

enum FriendPath: String {
    case all = "/friends/all"
    case search = "/friends/search?nickname=NAME"
}
