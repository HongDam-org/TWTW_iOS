//
//  Domain.swift
//  TWTW
//
//  Created by 정호진 on 2023/09/16.
//

import Foundation

enum SearchPath: String {
    case placeAndCategory = "/plans/search/destination?query=encodedQuery&page=1&categoryGroupCode=NONE"
}

enum LoginPath: String {
    case signUp = "/auth/save"
    case signIn = "/auth/login"
    case updateToken = "/auth/refresh"
    case checkValidation = "/auth/validate"
    case checkOverlapId = "/member/duplicate/Id"
}

