//
//  SearchPlacesMapService.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/26.
//

import Foundation
import UIKit
import Alamofire
import RxSwift

final class SearchPlacesMapService: SearchPlaceProtocol{
    
    func searchPlaceService(request: PlacesRequest) -> Observable<PlaceResponseModel> {
        return Observable.create { observer in
            
            let encodedQuery = SearchRequestConfig.encodedQuery(request.searchText)
            let headers = SearchRequestConfig.headers()
            let url = "\(Domain.REST_API)\(SearchPath.placeAndCategory)?query=\(encodedQuery)&page=1&categoryGroupCode=NONE"
            AF.request(url, method: .get, parameters: request, headers: headers)
                .validate(statusCode: 200..<205)
                .responseDecodable(of:PlaceResponseModel.self) {
                    response in
                    switch response.result {
                    case .success(let data):
                        let filteredPlaces = data.results
                        observer.onNext(data)
                        observer.onCompleted()
                    case .failure(let error):
                        if let statusCode = response.response?.statusCode, statusCode == 401 {
                            print("아직 검색과 일치하는 장소가 없음.")
                        } else {
                            observer.onError(error)
                        }
                    }
                }
            return Disposables.create()
        }
    }
}

