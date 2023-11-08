//
//  Domain.swift
//  TWTW
//
//  Created by 정호진 on 2023/09/16.
//

import Foundation

struct Domain {
    static let RESTAPI = "http://" + 
                            (Bundle.main.object(forInfoDictionaryKey: "IP") as? String ?? "") +
                            (Bundle.main.object(forInfoDictionaryKey: "PORT") as? String ?? "") +
                            "/api/v1"
}
