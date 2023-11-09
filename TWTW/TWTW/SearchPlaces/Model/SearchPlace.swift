//
//  SearchPlaces.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/24.
//

import Alamofire
import Foundation

///request 저장 변수
struct SearchPlacesMapState {
    var pageNum: Int = 1
    var currentSearchText: String = ""
}
/// 보내는 장소명 text
struct PlacesRequest: Codable {
    let searchText: String?
    let pageNum: Int
}
/// 검색 결과 리스트
struct PlaceResponse: Codable {
    let results: [SearchPlace]
    let isLast: Bool
}
/// 장소 정보
struct SearchPlace: Codable {
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
/// 임시 구조체
struct SearchNearByPlaces {
    let imageName: String?
    let title: String?
    let subTitle: String?
}
