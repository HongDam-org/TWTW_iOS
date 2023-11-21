//
//  MockSearchPlacesMapService.swift
//  TWTW
//
//  Created by 박다미 on 2023/11/21.
//

import Foundation
import RxSwift

final class MockSearchPlacesMapService: SearchPlaceProtocol {
    var mockResponse: PlaceResponse?

    func searchPlaceService(request: PlacesRequest) -> Observable<PlaceResponse> {
        return Observable.create { observer in
            if let mockResponse = self.mockResponse {
                observer.onNext(mockResponse)
            } else {
                observer.onError(NSError(domain: "unitTest", code: -1, userInfo: nil))
            }
            return Disposables.create()
        }
    }
}
