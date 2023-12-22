//
//  SearchPlaces.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/24.
//

import Alamofire
import Foundation

/// Request 저장 변수
struct SearchPlacesMapState {
    var pageNum: Int = 1
    var isLastPage: Bool = false

}

/// 보내는 장소명 text
struct PlacesRequest: Codable {
    let searchText: String?
    let pageNum: Int
}

/// 검색 결과 리스트
struct PlaceResponse: Codable {
    let results: [SearchPlace]
    let isLast: Bool?
}

/// 장소 정보
struct SearchPlace: Codable {
    let placeName: String?
    let distance: Int?
    let placeURL: String?
    let roadAddressName: String?
    let longitude, latitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case placeName, distance
        case placeURL = "placeUrl"
        case roadAddressName
        case longitude = "longitude"
        case latitude = "latitude"
    }
}
