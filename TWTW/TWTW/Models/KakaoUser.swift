//
//  KakaoUser.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/06.
//

import Foundation
struct User {
    var kakaoAccount: KakaoAccount?
}

struct KakaoAccount {
    var profileNeedsAgreement: Bool
    var emailNeedsAgreement: Bool
    var birthdayNeedsAgreement: Bool
    var birthyearNeedsAgreement: Bool
    var genderNeedsAgreement: Bool
    var phoneNumberNeedsAgreement: Bool
    var ageRangeNeedsAgreement: Bool
    var ciNeedsAgreement: Bool
}
