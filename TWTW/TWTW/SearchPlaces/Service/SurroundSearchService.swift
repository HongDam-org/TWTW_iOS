//
//  SurroundSearchService.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/20.
//


import Foundation
import Alamofire
import RxSwift

///  주변  장소 검색 Service
final class SurroundSearchService {
    
    /// MARK: 검색어와 카테고리를 통한 장소 검색
    func surroundSearchPlaces(place: String, x: Double, y: Double, page: Int, categoryGroupCode: String) -> Observable<SurroundSearchPlaces>{
        let url = Domain.REST_API + SearchPath.placeAndCategory.rawValue
        
        return Observable.create { observer in
            AF.request(url,
                       method: .get)
            .validate(statusCode: 200..<201)
            .responseDecodable(of: SurroundSearchPlaces.self) { response in
                
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
