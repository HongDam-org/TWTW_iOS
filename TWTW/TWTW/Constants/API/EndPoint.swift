//
//  Domain.swift
//  TWTW
//
//  Created by 정호진 on 2023/09/16.
//

import Foundation

struct SearchPath {
    static let placeAndCategory = "/plans/search/destination/"
    
}

struct LoginPath {
    static let signUp = "/auth/save"
    static let signIn = "/auth/login"
    static let updateToken = "/auth/refresh"
    static let checkValidation = "/auth/validate"
    static let checkOverlapId = "/member/duplicate/Id"
}
