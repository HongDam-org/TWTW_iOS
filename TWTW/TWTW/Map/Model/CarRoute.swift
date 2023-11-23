//
//  CarRoute.swift
//  TWTW
//
//  Created by 정호진 on 11/23/23.
//

import Foundation

struct CarRoute: Codable {
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
struct CarRouteRequest: Codable {
    let start: String
    let end: String
    let way: String
    let option: String
    let fuel: String
    let car: Int
}
