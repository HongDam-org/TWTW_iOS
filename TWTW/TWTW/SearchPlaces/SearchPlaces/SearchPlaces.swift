//
//  SearchPlaces.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/24.
//

import Foundation

//
struct PlacesRequest: Codable {
    let query: String?//...보내는 url더 쓰기
}
//

struct PlaceResponse: Codable {
    let placeInfo: Place
}
/// MARK: 검색 결과 리스트
struct ResponseModel: Codable {
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