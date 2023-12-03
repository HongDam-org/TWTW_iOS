//
//  Domain.swift
//  TWTW
//
//  Created by 정호진 on 2023/09/16.
//

import Foundation

enum SearchPath: String {
    case placeAndCategory = "/plans/search/destination?query=encodedQuery&x=xPosition&y=yPosition&page=pageNum&categoryGroupCode=NONE"
    case nearByPlace = "/places/surround?x=xPosition&y=yPosition&page=pageNum"
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
    case group = "/group"
    case invite = "/group/invite"
    case join = "/group/join"
}

enum FriendPath: String {
    case all = "/friends/all"
    case search = "/friends/search?nickname=NAME"
}
