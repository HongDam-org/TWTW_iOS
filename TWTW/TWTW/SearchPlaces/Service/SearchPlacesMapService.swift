//
//  SearchPlacesMapService.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/26.
//

import Alamofire
import CoreLocation
import Foundation
import RxSwift
import UIKit

/// 서치장소 Service
final class SearchPlacesMapService: SearchPlaceProtocol {
    
    /// Service연결 - searchPlaceService
    func searchPlaceService(request: PlacesRequest) -> Observable<PlaceResponse> {
        return Observable.create { observer in
            
            let encodedQuery = EncodedQueryConfig.encodedQuery(searchText: request.searchText).getEncodedQuery()
            let headers = Header.header.getHeader()
            let longitude = KeychainWrapper.loadItem(forKey: "longitude") ?? ""
            let latitude = KeychainWrapper.loadItem(forKey: "latitude") ?? ""
            
            let url = Domain.RESTAPI + SearchPath.placeAndCategory.rawValue
                .replacingOccurrences(of: "LONGITUDE", with: longitude)
                .replacingOccurrences(of: "LATITUDE", with: latitude)
                .replacingOccurrences(of: "pageNum", with: "\(request.pageNum)")
                .replacingOccurrences(of: "encodedQuery", with: encodedQuery)
           // print(url)
            
            AF.request(url, method: .get, parameters: request, headers: headers)
                .validate(statusCode: 200..<201)
                .responseDecodable(of: PlaceResponse.self) { response in
                    switch response.result {
                    case .success(let data):
                        observer.onNext(data)
                        print(data)
                    case .failure(let error):
                        if let statusCode = response.response?.statusCode, statusCode == 401 {
                            print("아직 검색과 일치하는 장소가 없음.")
                        }
                        observer.onError(error)
                    }
                }
            return Disposables.create()
        }
    }
}
