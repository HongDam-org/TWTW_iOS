//
//  EncodedQuery.swift
//  TWTW
//
//  Created by 박다미 on 2023/11/07.
//

import Foundation

enum EncodedQueryConfig {
    case encodedQuery(encodeRequest: String?)
    
    func getEncodedQuery() -> String {
        switch self {
        case .encodedQuery(let encodeRequest):
            return encodeRequest?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        }
    }
}
