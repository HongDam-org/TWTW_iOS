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
            
            let encodedQuery = request.query?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let accessToken = KeychainWrapper.loadString(forKey: SignIn.accessToken.rawValue) ?? ""
            let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
            let url = "\(Domain.REST_API)\(SearchPath.placeAndCategory)?query=\(encodedQuery)&page=1&categoryGroupCode=NONE"
            
            AF.request(url, method: .get, parameters: request, headers: headers)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: ResponseModel.self) { response in
                    switch response.result {
                    case .success(let data):
                        let filteredPlaces = data.results.map { $0 }
                        observer.onNext(PlaceResponse(placeInfo: filteredPlaces))
                        observer.onCompleted()
                        // print("성공 - 데이터: \(filteredPlaces)")
                    case .failure(let error):
                        //    print("에러 - \(error)")
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

