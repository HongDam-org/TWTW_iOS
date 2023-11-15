//
//  SurroundSearchPlaces.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/20.
//

import Foundation

/// 주변 검색 결과 리스트
struct SurroundSearchPlaces: Codable {
    let results: [PlaceInformation]
    let isLast: Bool
}

/// 주변지 정보
struct PlaceInformation: Codable {
    let placeName, distance: String
    let placeURL: String
    let categoryName, addressName, roadAddressName, categoryGroupCode: String
    let xPosition, yPosition: String

    enum CodingKeys: String, CodingKey {
        case placeName, distance
        case placeURL = "placeUrl"
        case categoryName, addressName, roadAddressName, categoryGroupCode
        case xPosition = "x"
        case yPosition = "y"
    }
}
