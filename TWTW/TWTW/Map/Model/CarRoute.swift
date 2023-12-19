//
//  CarRoute.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/19.
//

import Foundation

// 자동차 경로 요청 구조체
struct CarRouteRequest: Codable {
    let start: String
    let end: String
    let way: String
    let option: String
    let fuel: String
    let car: Int
}

// 자동차 경로 응답 구조체
struct CarRouteResponse: Codable {
    struct Summary: Codable {
        let start: String?
        let goal: String?
        let waypoints: [String]?
        let distance: Double
        let duration: Double
        let bbox: [Double]?
        let tollFare: Int
        let taxiFare: Int
        let fuelPrice: Int
    }
    
    struct Path: Codable {
        let path: [[Double]]
    }
    
    let code: Int
    let message: String?
    let currentDateTime: String?
    let route: [String: [Path]]
    let summary: Summary
}
