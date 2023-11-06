//
//  Domain.swift
//  TWTW
//
//  Created by 정호진 on 2023/09/16.
//

import Foundation

struct SearchPath {
    static let placeAndCategory = "/plans/search/destination?query=encodedQuery&page=1&categoryGroupCode=NONE"
    
}

struct LoginPath {
    static let signUp = "/auth/save"
    static let signIn = "/auth/login"
    static let updateToken = "/auth/refresh"
    static let checkValidation = "/auth/validate"
    static let checkOverlapId = "/member/duplicate/Id"
}

