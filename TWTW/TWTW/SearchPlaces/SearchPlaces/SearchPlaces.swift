//
//  SearchPlaces.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/24.
//

import Foundation
import Alamofire

/// MARK: 보내는 장소명 text
struct PlacesRequest: Codable {
    let searchText: String?
}
/// MARK: 검색 결과 리스트
struct PlaceResponseModel: Codable {
    let results: [Place]
    let isLast: Bool
}

/// MARK: - 장소 정보
struct Place: Codable {
    let placeName, distance: String
    let placeURL: String
    let categoryName, addressName, roadAddressName, categoryGroupCode: String
    let x, y: String
    
    enum CodingKeys: String, CodingKey {
        case placeName, distance
        case placeURL = "placeUrl"
        case categoryName, addressName, roadAddressName, categoryGroupCode, x, y
    }
}

struct SearchRequestConfig {
    func encodedQuery(_ searchText: String?) -> String {
        return searchText?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }

    func headers() -> HTTPHeaders {
        let accessToken = KeychainWrapper.loadString(forKey: SignIn.accessToken.rawValue) ?? ""
        return ["Authorization": "Bearer \(accessToken)"]
    }
}
