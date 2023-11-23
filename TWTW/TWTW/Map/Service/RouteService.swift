//
//  RouteViewModel.swift
//  TWTW
//
//  Created by 정호진 on 11/23/23.
//

import Alamofire
import RxSwift

final class RouteService: RouteProtocol {
    
    /// 자동차 경로 찾기
    /// - Parameter request: CarRouteRequest Model
    /// - Returns: CarRoute
    func carRoute(request: CarRouteRequest) -> Observable<CarRoute> {
        let url = Domain.RESTAPI + RoutePath.car.rawValue
        let headers = Header.header.getHeader()
        
        return Observable.create { observer in
            AF.request(url,
                       method: .post,
                       parameters: request,
                       encoder: JSONParameterEncoder.default,
                       headers: headers)
            .responseDecodable(of: CarRoute.self) { response in
                switch response.result {
                case .success(let data):
                    observer.onNext(data)
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
}
