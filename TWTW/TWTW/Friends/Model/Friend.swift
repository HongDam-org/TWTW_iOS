//
//  Friend.swift
//  TWTW
//
//  Created by 정호진 on 11/29/23.
//

import Foundation
import UIKit

struct Friend: Codable, Equatable {
    let memberId: String?
    let nickname: String?
    let participantsImage: String?
    
    enum CodingKeys: String, CodingKey {
        case memberId
        case nickname
        case participantsImage = "profileImage"
    }
}
