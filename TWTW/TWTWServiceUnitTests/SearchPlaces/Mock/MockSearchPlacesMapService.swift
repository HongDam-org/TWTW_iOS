//
//  MockSearchPlacesMapService.swift
//  TWTW
//
//  Created by 박다미 on 2023/11/21.
//

import Foundation
import RxSwift

final class MockSearchPlacesMapService: SearchPlaceProtocol {
    var mockPlace1 = SearchPlace(placeName: "Place1", distance: "100m", placeURL: "url",
                                 categoryName: "Cafe", addressName: "Address", roadAddressName: "RoadAdd",
                                 categoryGroupCode: "CGC", xPosition: "100.0", yPosition: "200.0")
    var mockPlace2 = SearchPlace(placeName: "Place2", distance: "200m", placeURL: "url2",
                                 categoryName: "Cafe2", addressName: "Address2", roadAddressName: "RoadAdd2",
                                 categoryGroupCode: "CGC2", xPosition: "300.0", yPosition: "400.0")
    
    func searchPlaceService(request: PlacesRequest) -> Observable<PlaceResponse> {
        return Observable.create { [weak self] observer in
            if request.searchText == "Place1"{
                let response = PlaceResponse(results: [self?.mockPlace1].compactMap { $0 }, isLast: false)
                observer.onNext(response)
            } else if request.searchText == "Place2"{
                let response = PlaceResponse(results: [self?.mockPlace2].compactMap { $0 }, isLast: false)
                observer.onNext(response)
            } else if request.searchText == "Place" {
                switch request.pageNum {
                case 1:
                    let response = PlaceResponse(results: [self?.mockPlace1].compactMap { $0 }, isLast: false)
                    observer.onNext(response)
                case 2:
                    let response = PlaceResponse(results: [self?.mockPlace2].compactMap { $0 }, isLast: true)
                    observer.onNext(response)
                default:
                    observer.onError(NSError(domain: "unitTest", code: -1, userInfo: nil))
                }
            }
            
            else {
                observer.onError(NSError(domain: "unitTest", code: -1, userInfo: nil))
            }
            return Disposables.create()
        }
    }
}
