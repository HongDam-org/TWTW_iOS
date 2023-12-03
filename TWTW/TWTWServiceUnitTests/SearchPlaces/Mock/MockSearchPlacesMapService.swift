//
//  MockSearchPlacesMapService.swift
//  TWTW
//
//  Created by 박다미 on 2023/11/21.
//

import Foundation
import RxSwift

final class MockSearchPlacesMapService: SearchPlaceProtocol {
    var mockPlace1 = SearchPlace(placeName: "Place1", distance: 100, placeURL: "url",
                                 addressName: "Address", roadAddressName: "RoadAdd",
                                 categoryGroupCode: "CGC", longitude: 100.0, latitude: 200.0)
    var mockPlace2 = SearchPlace(placeName: "Place2", distance: 200, placeURL: "url2",
                                 addressName: "Address2", roadAddressName: "RoadAdd2",
                                 categoryGroupCode: "CGC2", longitude: 300.0, latitude: 400.0)

    func searchPlaceService(request: PlacesRequest) -> Observable<PlaceResponse> {
        if request.searchText == "Place1" {
            let response = PlaceResponse(results: [mockPlace1].compactMap { $0 }, isLast: false)
            return .just(response)
        } else if request.searchText == "Place2" {
            let response = PlaceResponse(results: [mockPlace2].compactMap { $0 }, isLast: false)
            return .just(response)
        } else if request.searchText == "Place" {
            switch request.pageNum {
            case 1:
                let response = PlaceResponse(results: [mockPlace1].compactMap { $0 }, isLast: false)
                return .just(response)
            case 2:
                let response = PlaceResponse(results: [mockPlace2].compactMap { $0 }, isLast: true)
                return .just(response)
            default:
                return .error(NSError(domain: "unitTest", code: -1, userInfo: nil))
            }
        }
        return .error(NSError(domain: "unitTest", code: -1, userInfo: nil))
    }
}
