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
    func carRoute(request: CarRouteRequest1) -> Observable<CarRoute1> {
        let url = Domain.RESTAPI + RoutePath.car.rawValue
        let headers = Header.header.getHeader()
        
        return Observable.create { observer in
            AF.request(url,
                       method: .post,
                       parameters: request,
                       encoder: JSONParameterEncoder.default,
                       headers: headers)
            .responseDecodable(of: CarRoute1.self) { response in
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
protocol RouteProtocol {
    func carRoute(request: CarRouteRequest1) -> Observable<CarRoute1>
}
struct CarRoute1: Codable {
    let code: Int?
    let message, currentDateTime: String?
    let route: Route?
}

struct Route: Codable {
    let trafast: [Trafast]?
}

struct Trafast: Codable {
    let summary: Summary?
    let path: [[Double]]?
}

struct Summary: Codable {
    let start, goal: Goal?
    let waypoints: [Goal]?
    let distance, duration: Int?
    let bbox: [[Double]]?
    let tollFare, taxiFare, fuelPrice: Int?
}

struct Goal: Codable {
    let location: [[Double]]?
    let dir, distance, duration, pointIndex: Int?
}

/// 자동차 길찾기 Body
struct CarRouteRequest1: Codable {
    let start: String
    let end: String
    let way: String
    let option: String
    let fuel: String
    let car: Int
}
