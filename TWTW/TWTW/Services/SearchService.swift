//
//  SearchService.swift
//  TWTW
//
//  Created by 정호진 on 2023/09/16.
//

import Foundation
import Alamofire
import RxSwift

///  검색 Service
final class SearchService {
    
    /// MARK: 검색어와 카테고리를 통한 장소 검색
    func searchPlaces(place: String, x: Double, y: Double, page: Int, categoryGroupCode: String) -> Observable<SearchPlaces>{
        let url = Domain.REST_API + Search.placeAndCategory
        
        return Observable.create { observer in
            AF.request(url,
                       method: .get)
            .validate(statusCode: 200..<201)
            .responseDecodable(of: SearchPlaces.self) { response in
                
                switch response.result{
                case .success(let data):
                    observer.onNext(data)
                case .failure(let error):
                    print("searchPlaces error!\n\(error)")
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
        
    }
    
}
