//
//  SurroundSearchService.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/20.
//


import Alamofire
import Foundation
import RxSwift

/// 주변  장소 검색 Service
final class SurroundSearchService: SurroundSearchProtocol {
    
    /// 검색어와 카테고리를 통한 장소 검색
    func surroundSearchPlaces(xPosition: Double,
                              yPosition: Double,
                              page: Int,
                              categoryGroupCode: String) -> Observable<SurroundSearchPlaces> {
        let url = Domain.RESTAPI + SearchPath.nearByPlace.rawValue
            .replacingOccurrences(of: "LONGITUDE", with: "\(xPosition)")
            .replacingOccurrences(of: "LATITUDE", with: "\(yPosition)")
            .replacingOccurrences(of: "pageNum", with: "\(page)")
        
        let headers = Header.header.getHeader()
        print(url)
        return Observable.create { observer in
            AF.request(url,
                       method: .get,
                       headers: headers)
            .validate(statusCode: 200..<201)
            .responseDecodable(of: SurroundSearchPlaces.self) { response in
                switch response.result {
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
