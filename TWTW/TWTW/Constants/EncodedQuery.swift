//
//  EncodedQuery.swift
//  TWTW
//
//  Created by 박다미 on 2023/11/07.
//

import Foundation

enum EncodedQueryConfig {
    case encodedQuery(searchText: String?)
    
    func getEncodedQuery() -> String {
        switch self{
        case .encodedQuery(let searchText):
            return searchText?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        }
    }
}
