//
//  SurroundSearchPlaces.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/20.
//

import Foundation

/// MARK: 주변 검색 결과 리스트
struct SurroundSearchPlaces: Codable {
    var results: [PlaceInformation]?
    var isLast: Bool?
}

/// MARK: - 주변지 정보
struct PlaceInformation: Codable {
    var placeName, distance: String?
    var placeURL: String?
    var categoryName, addressName, roadAddressName, categoryGroupCode: String?
    var x, y: String?

    enum CodingKeys: String, CodingKey {
        case placeName, distance
        case placeURL = "placeUrl"
        case categoryName, addressName, roadAddressName, categoryGroupCode, x, y
    }
}
