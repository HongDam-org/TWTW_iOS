//
//  RouteProtocol.swift
//  TWTW
//
//  Created by 정호진 on 11/23/23.
//

import Foundation
import RxSwift

protocol RouteProtocol {
    func carRoute(request: CarRouteRequest) -> Observable<CarRoute>
}
