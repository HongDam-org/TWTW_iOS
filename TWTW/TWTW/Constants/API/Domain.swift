//
//  Domain.swift
//  TWTW
//
//  Created by 정호진 on 2023/09/16.
//

import Foundation

struct Domain {
    static let REST_API = Bundle.main.object(forInfoDictionaryKey: "REST_API") as? String ?? ""
}
