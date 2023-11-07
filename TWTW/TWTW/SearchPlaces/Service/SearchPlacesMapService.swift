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
    
    func searchPlaceService(request: PlacesRequest) -> Observable<PlaceResponse> {
        return Observable.create { observer in
            
            let encodedQuery = EncodedQueryConfig.encodedQuery(searchText: request.searchText).getEncodedQuery()
        
            let headers = Header.header.getHeader()
            
            var url = Domain.REST_API + SearchPath.placeAndCategory.rawValue
            
            url = url.replacingOccurrences(of: "encodedQuery", with: encodedQuery)
            
            AF.request(url, method: .get, parameters: request, headers: headers)
                .validate(statusCode: 200..<201)
                .responseDecodable(of:PlaceResponse.self) { response in
                    switch response.result {
                    case .success(let data):
                        observer.onNext(data)
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

