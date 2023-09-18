//
//  SearchPlaces.swift
//  TWTW
//
//  Created by 정호진 on 2023/09/16.
//

import Foundation

/// MARK: 검색 결과 리스트
struct SearchPlaces: Codable {
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
